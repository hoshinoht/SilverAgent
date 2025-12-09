import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class TaskDetailModal extends StatelessWidget {
  final Task task;

  const TaskDetailModal({super.key, required this.task});

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.yellow.shade600;
      case TaskStatus.inProgress:
        return AppTheme.primary;
      case TaskStatus.completed:
        return AppTheme.primary;
      case TaskStatus.failed:
        return Colors.red.shade500;
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.yellow.shade100;
      case TaskStatus.inProgress:
        return Colors.blue.shade100;
      case TaskStatus.completed:
        return Colors.green.shade100;
      case TaskStatus.failed:
        return Colors.red.shade100;
    }
  }

  Color _getTaskStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.yellow.shade700;
      case TaskStatus.inProgress:
        return Colors.blue.shade700;
      case TaskStatus.completed:
        return Colors.green.shade700;
      case TaskStatus.failed:
        return Colors.red.shade700;
    }
  }

  Widget _buildStepIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Icon(Icons.check, size: 14, color: Colors.white);
      case TaskStatus.inProgress:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        );
      case TaskStatus.failed:
        return const Icon(Icons.error, size: 14, color: Colors.white);
      default:
        return const Icon(
          Icons.circle_outlined,
          size: 14,
          color: AppTheme.slate300,
        );
    }
  }

  Color _getStepColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return AppTheme.primary;
      case TaskStatus.inProgress:
        return Colors.white;
      case TaskStatus.failed:
        return Colors.red.shade500;
      default:
        return AppTheme.slate50;
    }
  }

  Color _getStepBorderColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return AppTheme.primary;
      case TaskStatus.inProgress:
        return AppTheme.primary;
      case TaskStatus.failed:
        return Colors.red.shade500;
      default:
        return AppTheme.slate300;
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.modalShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppTheme.slate100)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${task.id.substring(task.id.length - 6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.slate100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.slate800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTaskStatusColor(task.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.status.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getTaskStatusTextColor(task.status),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppTheme.slate100),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ESTIMATED COST',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.slate400,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.price ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.slate700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'AGENT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.slate400,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.mcpAgentName ?? 'System',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Execution Timeline
                    Row(
                      children: [
                        Icon(
                          task.status == TaskStatus.inProgress
                              ? Icons.sync
                              : Icons.check_circle_outline,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Execution Process',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Timeline
                    _buildTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: task.executionSteps.length,
      itemBuilder: (context, index) {
        final step = task.executionSteps[index];
        final isLast = index == task.executionSteps.length - 1;
        final isPending = step.status == TaskStatus.pending;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getStepColor(step.status),
                      border: Border.all(
                        color: _getStepBorderColor(step.status),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: _buildStepIcon(step.status)),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 48, color: AppTheme.slate200),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Opacity(
                  opacity: isPending ? 0.5 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              step.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slate800,
                              ),
                            ),
                          ),
                          if (step.timestamp != null &&
                              step.status != TaskStatus.pending)
                            Text(
                              _formatTime(step.timestamp!),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.slate400,
                              ),
                            ),
                        ],
                      ),
                      if (step.details != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          step.details!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
