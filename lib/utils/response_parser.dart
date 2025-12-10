// ResponseParser - Parse LLM output into structured segments
// Handles <strategy>, <tool_call>, and plain text extraction

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';

/// Represents a parsed segment from LLM output
sealed class ParsedSegment {
  const ParsedSegment();
}

class TextSegment extends ParsedSegment {
  final String content;
  const TextSegment(this.content);
}

class ThinkingSegment extends ParsedSegment {
  final String content;
  const ThinkingSegment(this.content);
}

class ToolCallSegment extends ParsedSegment {
  final String name;
  final Map<String, dynamic> arguments;
  const ToolCallSegment(this.name, this.arguments);
}

class ResponseParser {
  static const _uuid = Uuid();

  // Regex patterns for parsing
  static final RegExp _strategyPattern = RegExp(
    r'<strategy>([\s\S]*?)</strategy>',
    caseSensitive: false,
  );

  static final RegExp _toolCallPattern = RegExp(
    r'<tool_call>\s*([\s\S]*?)\s*</tool_call>',
    caseSensitive: false,
  );

  /// Extract balanced JSON object from a string that may have extra braces
  static String? _extractJsonObject(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('{')) return null;

    int braceCount = 0;
    int endIndex = -1;

    for (int i = 0; i < trimmed.length; i++) {
      if (trimmed[i] == '{') {
        braceCount++;
      } else if (trimmed[i] == '}') {
        braceCount--;
        if (braceCount == 0) {
          endIndex = i;
          break;
        }
      }
    }

    if (endIndex == -1) return null;
    return trimmed.substring(0, endIndex + 1);
  }

  /// Parse LLM response into structured segments
  static List<ParsedSegment> parse(String response) {
    final segments = <ParsedSegment>[];

    // Track positions of all matches
    final matches = <({int start, int end, ParsedSegment segment})>[];

    // Find all strategy blocks
    for (final match in _strategyPattern.allMatches(response)) {
      final content = match.group(1)?.trim() ?? '';
      if (content.isNotEmpty) {
        matches.add((
          start: match.start,
          end: match.end,
          segment: ThinkingSegment(content),
        ));
      }
    }

    // Find all tool calls
    for (final match in _toolCallPattern.allMatches(response)) {
      final rawContent = match.group(1) ?? '';
      final jsonStr = _extractJsonObject(rawContent);
      if (jsonStr == null) continue;

      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final name = json['name'] as String?;
        final arguments = json['arguments'] as Map<String, dynamic>? ?? {};
        if (name != null) {
          matches.add((
            start: match.start,
            end: match.end,
            segment: ToolCallSegment(name, arguments),
          ));
        }
      } catch (e) {
        // Invalid JSON, skip this match
      }
    }

    // Sort matches by position
    matches.sort((a, b) => a.start.compareTo(b.start));

    // Extract text between matches
    var currentIndex = 0;
    for (final match in matches) {
      // Add any text before this match
      if (match.start > currentIndex) {
        final text = response.substring(currentIndex, match.start).trim();
        if (text.isNotEmpty) {
          segments.add(TextSegment(text));
        }
      }
      segments.add(match.segment);
      currentIndex = match.end;
    }

    // Add any remaining text after last match
    if (currentIndex < response.length) {
      final text = response.substring(currentIndex).trim();
      if (text.isNotEmpty) {
        segments.add(TextSegment(text));
      }
    }

    // If no matches found, return the whole response as text
    if (segments.isEmpty && response.trim().isNotEmpty) {
      segments.add(TextSegment(response.trim()));
    }

    return segments;
  }

  /// Convert parsed segments to Message objects
  static List<Message> toMessages(List<ParsedSegment> segments) {
    return segments.map((segment) {
      final now = DateTime.now();

      return switch (segment) {
        TextSegment(:final content) => Message(
          id: _uuid.v4(),
          content: content,
          role: 'assistant',
          timestamp: now,
          type: MessageType.text,
        ),
        ThinkingSegment(:final content) => Message(
          id: _uuid.v4(),
          content: content,
          role: 'assistant',
          timestamp: now,
          type: MessageType.thinking,
          metadata: MessageMetadata(
            thinking: ThinkingData(content: content),
          ),
        ),
        ToolCallSegment(:final name, :final arguments) => Message(
          id: _uuid.v4(),
          content: 'Tool: $name',
          role: 'assistant',
          timestamp: now,
          type: MessageType.toolCall,
          metadata: MessageMetadata(
            toolCall: ToolCallData(
              id: _uuid.v4(),
              name: name,
              arguments: arguments,
            ),
          ),
        ),
      };
    }).toList();
  }

  /// Check if a response contains a tool call
  static bool hasToolCall(String response) {
    return _toolCallPattern.hasMatch(response);
  }

  /// Check if a response contains a thinking block
  static bool hasThinking(String response) {
    return _strategyPattern.hasMatch(response);
  }

  /// Extract just the tool calls from a response
  static List<ToolCallData> extractToolCalls(String response) {
    final toolCalls = <ToolCallData>[];

    for (final match in _toolCallPattern.allMatches(response)) {
      final rawContent = match.group(1) ?? '';
      final jsonStr = _extractJsonObject(rawContent);
      if (jsonStr == null) continue;

      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final name = json['name'] as String?;
        final arguments = json['arguments'] as Map<String, dynamic>? ?? {};
        if (name != null) {
          toolCalls.add(ToolCallData(
            id: _uuid.v4(),
            name: name,
            arguments: arguments,
          ));
        }
      } catch (e) {
        // Invalid JSON, skip
      }
    }

    return toolCalls;
  }

  /// Extract plain text (removing strategy and tool_call tags)
  static String extractPlainText(String response) {
    var text = response;
    text = text.replaceAll(_strategyPattern, '');
    text = text.replaceAll(_toolCallPattern, '');
    return text.trim();
  }

  /// Format tool result for injection into conversation
  /// Prefers structuredContent, falls back to content, then raw result
  static String formatToolResult(String toolName, Map<String, dynamic> result) {
    dynamic extractedData;

    if (result.containsKey('structuredContent')) {
      extractedData = result['structuredContent'];
    } else if (result.containsKey('content')) {
      extractedData = result['content'];
    } else {
      extractedData = result;
    }

    final jsonStr = const JsonEncoder.withIndent('  ').convert(extractedData);
    return '<tool_result name="$toolName">\n$jsonStr\n</tool_result>';
  }

  /// Format a decline message for injection into conversation
  static String formatDeclineMessage(String toolName) {
    return '<system_message>User has declined the tool call for $toolName</system_message>';
  }
}
