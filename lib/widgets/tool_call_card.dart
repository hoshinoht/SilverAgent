// ToolCallCard - Widget for displaying tool calls with accept/decline buttons
// Supports collapsible results and compact view for auto-executed tools

import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/chat_models.dart';
import '../main.dart';

class ToolCallCard extends StatelessWidget {
  final ToolCallData toolCall;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onToggleResult;

  const ToolCallCard({
    super.key,
    required this.toolCall,
    this.onAccept,
    this.onDecline,
    this.onToggleResult,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-executed tools get a compact display
    if (toolCall.isAutoExecuted) {
      return _buildCompactView(context);
    }
    return _buildFullView(context);
  }

  /// Compact inline view for auto-executed tools (like weather)
  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.scale;
    final isCompleted = toolCall.status == ToolCallStatus.completed;
    final isExecuting = toolCall.status == ToolCallStatus.executing;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4 * s, horizontal: 16 * s),
      child: InkWell(
        onTap: isCompleted ? onToggleResult : null,
        borderRadius: BorderRadius.circular(12 * s),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: _getCompactBgColor(theme),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: _getCompactBorderColor(theme)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCompactIcon(),
                    color: _getCompactColor(theme),
                    size: 18 * s,
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Text(
                      _getCompactLabel(),
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: _getCompactColor(theme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isCompleted && toolCall.result != null) ...[
                    Icon(
                      toolCall.isResultExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade500,
                      size: 20 * s,
                    ),
                  ],
                  if (isExecuting)
                    SizedBox(
                      width: 16 * s,
                      height: 16 * s,
                      child: CircularProgressIndicator(
                        strokeWidth: 2 * s,
                        valueColor: AlwaysStoppedAnimation(Colors.orange),
                      ),
                    ),
                ],
              ),
              // Expandable result
              if (isCompleted && toolCall.result != null && toolCall.isResultExpanded)
                _buildCollapsedResult(context, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedResult(BuildContext context, double s) {
    return Container(
      margin: EdgeInsets.only(top: 12 * s),
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        _formatResult(toolCall.result),
        style: TextStyle(
          fontSize: 12 * s,
          fontFamily: 'monospace',
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  String _getCompactLabel() {
    final name = _formatToolName(toolCall.name);
    return switch (toolCall.status) {
      ToolCallStatus.executing => '$name...',
      ToolCallStatus.completed => '$name ✓',
      ToolCallStatus.error => '$name ✗',
      _ => name,
    };
  }

  IconData _getCompactIcon() {
    // Tool-specific icons
    if (toolCall.name.contains('weather')) return Icons.wb_sunny;
    if (toolCall.name.contains('forecast')) return Icons.calendar_today;
    if (toolCall.name.contains('uv')) return Icons.wb_twilight;
    if (toolCall.name.contains('alert')) return Icons.warning_amber;
    return Icons.auto_awesome;
  }

  Color _getCompactColor(ThemeData theme) {
    return switch (toolCall.status) {
      ToolCallStatus.executing => Colors.orange.shade700,
      ToolCallStatus.completed => Colors.blue.shade700,
      ToolCallStatus.error => Colors.red.shade700,
      _ => Colors.grey.shade600,
    };
  }

  Color _getCompactBgColor(ThemeData theme) {
    return switch (toolCall.status) {
      ToolCallStatus.executing => Colors.orange.shade50,
      ToolCallStatus.completed => Colors.blue.shade50,
      ToolCallStatus.error => Colors.red.shade50,
      _ => Colors.grey.shade50,
    };
  }

  Color _getCompactBorderColor(ThemeData theme) {
    return switch (toolCall.status) {
      ToolCallStatus.executing => Colors.orange.shade200,
      ToolCallStatus.completed => Colors.blue.shade200,
      ToolCallStatus.error => Colors.red.shade200,
      _ => Colors.grey.shade200,
    };
  }

  /// Full card view for manual approval tools
  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.scale;
    final isPending = toolCall.status == ToolCallStatus.pending;
    final isExecuting = toolCall.status == ToolCallStatus.executing;
    final isCompleted = toolCall.status == ToolCallStatus.completed;
    final isError = toolCall.status == ToolCallStatus.error;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: _getBorderColor(theme),
          width: 2 * s,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: _getHeaderColor(theme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18 * s)),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getHeaderColor(theme),
                  size: 32 * s,
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tool Call',
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: _getHeaderColor(theme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatToolName(toolCall.name),
                        style: TextStyle(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, theme),
              ],
            ),
          ),

          // Arguments
          Padding(
            padding: EdgeInsets.all(20 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arguments:',
                  style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12 * s),
                Container(
                  padding: EdgeInsets.all(16 * s),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12 * s),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    _formatArguments(toolCall.arguments),
                    style: TextStyle(
                      fontSize: 15 * s,
                      fontFamily: 'monospace',
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result (if completed) - now collapsible
          if (isCompleted && toolCall.result != null)
            _buildResultSection(context, theme),

          // Error (if failed)
          if (isError && toolCall.error != null)
            _buildErrorSection(context, theme),

          // Action buttons (only if pending)
          if (isPending)
            _buildActionButtons(context, theme),

          // Executing indicator
          if (isExecuting)
            _buildExecutingIndicator(context, theme),
        ],
      ),
    );
  }

  Color _getBorderColor(ThemeData theme) {
    return switch (toolCall.status) {
      ToolCallStatus.pending => theme.colorScheme.primary,
      ToolCallStatus.executing => Colors.orange,
      ToolCallStatus.completed => Colors.green,
      ToolCallStatus.declined => Colors.grey,
      ToolCallStatus.error => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getHeaderColor(ThemeData theme) {
    return switch (toolCall.status) {
      ToolCallStatus.pending => theme.colorScheme.primary,
      ToolCallStatus.executing => Colors.orange,
      ToolCallStatus.completed => Colors.green,
      ToolCallStatus.declined => Colors.grey,
      ToolCallStatus.error => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _getStatusIcon() {
    return switch (toolCall.status) {
      ToolCallStatus.pending => Icons.pending_actions,
      ToolCallStatus.executing => Icons.sync,
      ToolCallStatus.completed => Icons.check_circle,
      ToolCallStatus.declined => Icons.cancel,
      ToolCallStatus.error => Icons.error,
      _ => Icons.help_outline,
    };
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme) {
    final s = context.scale;
    final (label, color) = switch (toolCall.status) {
      ToolCallStatus.pending => ('Awaiting Approval', theme.colorScheme.primary),
      ToolCallStatus.executing => ('Executing...', Colors.orange),
      ToolCallStatus.completed => ('Completed', Colors.green),
      ToolCallStatus.declined => ('Declined', Colors.grey),
      ToolCallStatus.error => ('Error', Colors.red),
      _ => ('Unknown', Colors.grey),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14 * s,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatToolName(String name) {
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _formatArguments(Map<String, dynamic> args) {
    return const JsonEncoder.withIndent('  ').convert(args);
  }

  String _formatResult(Map<String, dynamic>? result) {
    if (result == null) return '';
    // Extract structuredContent if present
    final data = result['structuredContent'] ?? result['content'] ?? result;
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Widget _buildResultSection(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      margin: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
      child: InkWell(
        onTap: onToggleResult,
        borderRadius: BorderRadius.circular(12 * s),
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 22 * s),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 16 * s,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    toolCall.isResultExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.green.shade700,
                    size: 24 * s,
                  ),
                ],
              ),
              if (toolCall.isResultExpanded) ...[
                SizedBox(height: 12 * s),
                Text(
                  _formatResult(toolCall.result),
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontFamily: 'monospace',
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      margin: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700, size: 22 * s),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              toolCall.error!,
              style: TextStyle(
                fontSize: 16 * s,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDecline,
              icon: Icon(Icons.close, size: 22 * s),
              label: Text('Decline', style: TextStyle(fontSize: 16 * s)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 2 * s),
                padding: EdgeInsets.symmetric(vertical: 16 * s),
              ),
            ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: Icon(Icons.check, size: 22 * s),
              label: Text('Accept & Run', style: TextStyle(fontSize: 16 * s)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutingIndicator(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24 * s,
            height: 24 * s,
            child: CircularProgressIndicator(
              strokeWidth: 3 * s,
              valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
            ),
          ),
          SizedBox(width: 16 * s),
          Text(
            'Executing tool...',
            style: TextStyle(
              fontSize: 18 * s,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
