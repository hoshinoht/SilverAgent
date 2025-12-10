// Message Bubble Widget - Displays individual chat messages
// Supports user and assistant messages with different styling

import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    // Show typing indicator
    if (message.isTyping) {
      return _buildTypingIndicator(theme);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent badge for assistant messages
            if (!isUser &&
                message.agentType != null &&
                message.agentType != AgentType.general)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAgentBadge(message.agentType!, theme),
              ),

            // Message content
            Text(
              message.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isUser ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 4),

            // Status and timestamp
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status icon
                if (message.status != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _buildStatusIcon(message.status!, isUser),
                  ),

                // Timestamp
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            // Appointment details if available
            if (message.metadata?.appointmentDetails != null)
              _buildAppointmentCard(
                message.metadata!.appointmentDetails!,
                theme,
              ),

            // Error retry info
            if (message.status == MessageStatus.retrying)
              _buildRetryInfo(message.metadata, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(delay: 0),
            const SizedBox(width: 4),
            _buildTypingDot(delay: 200),
            const SizedBox(width: 4),
            _buildTypingDot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot({required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 2).clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgentBadge(AgentType agentType, ThemeData theme) {
    String label;
    IconData icon;

    switch (agentType) {
      case AgentType.singhealth:
        label = 'SingHealth Portal';
        icon = Icons.local_hospital;
        break;
      case AgentType.nuhs:
        label = 'NUHS Portal';
        icon = Icons.medical_services;
        break;
      case AgentType.polyclinic:
        label = 'Polyclinic Portal';
        icon = Icons.health_and_safety;
        break;
      default:
        label = 'SilverAgent';
        icon = Icons.favorite;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status, bool isUser) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.success:
        icon = Icons.check_circle;
        color = isUser ? Colors.white70 : Colors.green;
        break;
      case MessageStatus.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case MessageStatus.retrying:
        icon = Icons.refresh;
        color = Colors.orange;
        break;
      default:
        icon = Icons.access_time;
        color = isUser ? Colors.white70 : Colors.grey;
    }

    return Icon(icon, size: 12, color: color);
  }

  Widget _buildAppointmentCard(AppointmentDetails details, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.local_hospital, 'Hospital', details.hospital),
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.medical_services,
            'Department',
            details.department,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.calendar_today, 'Date', details.date),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.access_time, 'Time', details.time),
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.confirmation_number,
            'Ref',
            details.referenceNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRetryInfo(MessageMetadata? metadata, ThemeData theme) {
    if (metadata == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Retrying (${metadata.retryCount}/${metadata.maxRetries})...',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
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
