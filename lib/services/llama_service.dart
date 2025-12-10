// LlamaService - HTTP client for external llama-server
// Handles streaming chat completions and system prompt management

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LlamaService {
  static const String _defaultHost = 'localhost';
  static const int _defaultPort = 8080;

  final String host;
  final int port;
  String? _systemPrompt;
  bool _isConnected = false;

  LlamaService({
    this.host = _defaultHost,
    this.port = _defaultPort,
  });

  String get baseUrl => 'http://$host:$port';
  bool get isConnected => _isConnected;

  /// Initialize the service and load system prompt
  Future<void> initialize() async {
    await _loadSystemPrompt();
    await checkConnection();
  }

  /// Load system prompt from file
  Future<void> _loadSystemPrompt() async {
    try {
      // Try to load from relative path (for development)
      final file = File('systemprompt2');
      if (await file.exists()) {
        _systemPrompt = await file.readAsString();
        debugPrint('Loaded system prompt from systemprompt2');
      } else {
        // Fallback to embedded default
        _systemPrompt = _defaultSystemPrompt;
        debugPrint('Using default system prompt');
      }
    } catch (e) {
      debugPrint('Error loading system prompt: $e');
      _systemPrompt = _defaultSystemPrompt;
    }
  }

  /// Check if llama-server is reachable
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      _isConnected = response.statusCode == 200;
      debugPrint('Llama server connection: $_isConnected');
      return _isConnected;
    } catch (e) {
      debugPrint('Llama server not reachable: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Send a chat completion request and stream the response
  Stream<String> streamChatCompletion(List<Map<String, String>> messages) async* {
    if (!_isConnected) {
      await checkConnection();
      if (!_isConnected) {
        yield '[Error: Llama server not connected. Please start llama-server at $baseUrl]';
        return;
      }
    }

    // Prepend system prompt
    final fullMessages = [
      {'role': 'system', 'content': _systemPrompt ?? _defaultSystemPrompt},
      ...messages,
    ];

    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/v1/chat/completions'),
    );

    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'messages': fullMessages,
      'stream': true,
      'temperature': 0.7,
      'max_tokens': 2048,
    });

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );

      if (streamedResponse.statusCode != 200) {
        yield '[Error: Server returned ${streamedResponse.statusCode}]';
        return;
      }

      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // Parse SSE format: "data: {...}\n\n"
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') {
              return;
            }
            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            } catch (e) {
              // Skip malformed JSON chunks
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Streaming error: $e');
      _isConnected = false;
      yield '[Error: Connection lost - $e]';
    }
  }

  /// Non-streaming chat completion (for simpler use cases)
  Future<String> chatCompletion(List<Map<String, String>> messages) async {
    final buffer = StringBuffer();
    await for (final chunk in streamChatCompletion(messages)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  /// Default system prompt (fallback)
  static const String _defaultSystemPrompt = '''
You are "SilverAgent", a helpful, empathetic, and proactive AI assistant for Singapore.

**USER CONTEXT:**
- Name: User
- Location: Singapore

**CORE BEHAVIORS:**
1. **Persona & Language:** You understand Singlish perfectly. Respond in the same language and tone used by the user.
2. **Strict Reasoning (ReAct):** Use the <strategy> tag for planning before acting.
3. **Tool Usage:** When you need to use a tool, output it in this format:
   <tool_call> {"name": "tool_name", "arguments": {...}} </tool_call>

**FORMATTING:**
- **Think:** <strategy>Your reasoning here</strategy>
- **Act:** <tool_call> {"name": "tool_name", "arguments": {...}} </tool_call>
- **Speak:** [Your friendly response to the user]

**AVAILABLE TOOLS:**
- get_current_weather: Get weather for Singapore
- book_ride: Book a Grab ride
- get_appointments: Get upcoming appointments
- reschedule_appointment: Reschedule an appointment
''';
}
