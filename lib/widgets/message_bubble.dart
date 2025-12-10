// Message Bubble Widget - Displays individual chat messages
// Supports text, thinking blocks, tool calls, and results

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../providers/chat_provider.dart';
import '../main.dart';
import 'tool_call_card.dart';
import 'thinking_block.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle different message types
    return switch (message.type) {
      MessageType.thinking => _buildThinkingMessage(context),
      MessageType.toolCall => _buildToolCallMessage(context),
      MessageType.toolResult => _buildToolResultMessage(context, theme),
      MessageType.systemMessage => _buildSystemMessage(context, theme),
      MessageType.text => _buildTextMessage(context, theme),
    };
  }

  Widget _buildThinkingMessage(BuildContext context) {
    if (message.metadata?.thinking == null) {
      return const SizedBox.shrink();
    }

    return ThinkingBlock(
      thinking: message.metadata!.thinking!,
      isStreaming: message.isStreaming,
      onToggle: () {
        context.read<ChatProvider>().toggleThinkingExpanded(message.id);
      },
    );
  }

  Widget _buildToolCallMessage(BuildContext context) {
    if (message.metadata?.toolCall == null) {
      return const SizedBox.shrink();
    }

    final toolCall = message.metadata!.toolCall!;
    final chatProvider = context.read<ChatProvider>();

    return ToolCallCard(
      toolCall: toolCall,
      onAccept: toolCall.status == ToolCallStatus.pending
          ? () => chatProvider.acceptToolCall()
          : null,
      onDecline: toolCall.status == ToolCallStatus.pending
          ? () => chatProvider.declineToolCall()
          : null,
      onToggleResult: () => chatProvider.toggleToolResultExpanded(message.id),
    );
  }

  Widget _buildToolResultMessage(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 16 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.output, color: Colors.blue.shade700, size: 26 * s),
          SizedBox(width: 14 * s),
          Expanded(
            child: Text(
              'Tool result received',
              style: TextStyle(
                fontSize: 17 * s,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 16 * s),
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 12 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade500,
            size: 20 * s,
          ),
          SizedBox(width: 10 * s),
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 16 * s,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, ThemeData theme) {
    final s = context.scale;
    final isUser = message.role == 'user';

    // Show typing/streaming indicator
    if (message.isTyping || (message.isStreaming && message.content.isEmpty)) {
      return _buildTypingIndicator(context, theme);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Agent badge for assistant
          if (!isUser) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8 * s),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    size: 22 * s,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 10 * s),
                Text(
                  'SilverAgent',
                  style: TextStyle(
                    fontSize: 16 * s,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (message.isStreaming) ...[
                  SizedBox(width: 10 * s),
                  SizedBox(
                    width: 18 * s,
                    height: 18 * s,
                    child: CircularProgressIndicator(
                      strokeWidth: 2 * s,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8 * s),
          ],

          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 18 * s),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        const Color(0xFF00695C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUser ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24 * s),
                topRight: Radius.circular(24 * s),
                bottomLeft: Radius.circular(isUser ? 24 * s : 4 * s),
                bottomRight: Radius.circular(isUser ? 4 * s : 24 * s),
              ),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                SelectableText(
                  message.content,
                  style: TextStyle(
                    fontSize: 18 * s,
                    color: isUser ? Colors.white : const Color(0xFF2C2C2C),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 8 * s),
                // Timestamp and status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.status != null)
                      Padding(
                        padding: EdgeInsets.only(right: 6 * s),
                        child: _buildStatusIcon(context, message.status!, isUser),
                      ),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 16 * s),
        padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 18 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24 * s,
              height: 24 * s,
              child: CircularProgressIndicator(
                strokeWidth: 3 * s,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
            SizedBox(width: 14 * s),
            Text(
              'Thinking...',
              style: TextStyle(
                fontSize: 18 * s,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MessageStatus status, bool isUser) {
    final s = context.scale;
    final (icon, color) = switch (status) {
      MessageStatus.success => (Icons.check_circle, isUser ? Colors.white70 : Colors.green),
      MessageStatus.error => (Icons.error, Colors.red),
      MessageStatus.retrying => (Icons.refresh, Colors.orange),
      MessageStatus.pending => (Icons.access_time, isUser ? Colors.white70 : Colors.grey),
    };

    return Icon(icon, size: 16 * s, color: color);
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}
