import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';
import '../widgets/service_card.dart';
import '../widgets/task_card.dart';
import '../widgets/ai_assistant_modal.dart';
import '../widgets/task_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskStatus? _filterStatus;

  void _showAIModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        return AIAssistantModal(
          onSubmit: (text) async {
            try {
              await taskProvider.createTaskFromText(text);
              if (mounted) Navigator.of(context).pop();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          isProcessing: taskProvider.isProcessing,
        );
      },
    );
  }

  void _showTaskDetail(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailModal(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ServiceCard(
                  icon: Icons.directions_car,
                  label: 'Transport',
                  iconColor: AppTheme.primary,
                  onTap: () => _showAIModal(),
                ),
                ServiceCard(
                  icon: Icons.restaurant,
                  label: 'Food',
                  iconColor: AppTheme.coral,
                  onTap: () => _showAIModal(),
                  isPromo: true,
                ),
                ServiceCard(
                  icon: Icons.shopping_bag,
                  label: 'Mart',
                  iconColor: Colors.purple.shade500,
                  onTap: () => _showAIModal(),
                ),
                ServiceCard(
                  icon: Icons.local_hospital,
                  label: 'Health',
                  iconColor: Colors.blue.shade500,
                  onTap: () => _showAIModal(),
                ),
                ServiceCard(
                  icon: Icons.local_shipping,
                  label: 'Express',
                  iconColor: Colors.orange.shade500,
                  onTap: () => _showAIModal(),
                ),
                ServiceCard(
                  icon: Icons.account_balance_wallet,
                  label: 'Finance',
                  iconColor: Colors.indigo.shade500,
                  onTap: () => _showAIModal(),
                ),
                ServiceCard(
                  icon: Icons.more_horiz,
                  label: 'More',
                  iconColor: AppTheme.slate400,
                  onTap: () => _showAIModal(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Active Tasks Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isActive: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    isActive: _filterStatus == TaskStatus.pending,
                    onTap: () =>
                        setState(() => _filterStatus = TaskStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Running',
                    isActive: _filterStatus == TaskStatus.inProgress,
                    onTap: () =>
                        setState(() => _filterStatus = TaskStatus.inProgress),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Completed',
                    isActive: _filterStatus == TaskStatus.completed,
                    onTap: () =>
                        setState(() => _filterStatus = TaskStatus.completed),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Failed',
                    isActive: _filterStatus == TaskStatus.failed,
                    onTap: () =>
                        setState(() => _filterStatus = TaskStatus.failed),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Task Queue
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              final tasks = _filterStatus == null
                  ? taskProvider.getRecentTasks()
                  : taskProvider
                        .getFilteredTasks(_filterStatus)
                        .reversed
                        .take(3)
                        .toList();

              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                    child: const Column(
                      children: [
                        Icon(Icons.bolt, size: 48, color: AppTheme.slate400),
                        SizedBox(height: 12),
                        Text(
                          'No active tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slate500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ask MCP to start automating',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: tasks
                      .map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            onTap: () => _showTaskDetail(task),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Promotional Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 128,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF00D863)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.bolt,
                      size: 120,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'MCP Auto-Topup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let AI manage your EZ-Link card\nbalance automatically.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Activate',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // For You Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ForYouCard(
                        icon: Icons.restaurant,
                        iconColor: AppTheme.coral,
                        title: 'Reorder Lunch',
                        subtitle: 'Chicken Rice Set A',
                        onTap: () => _showAIModal(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ForYouCard(
                        icon: Icons.directions_car,
                        iconColor: Colors.blue.shade500,
                        title: 'Home to Office',
                        subtitle: 'S\$14.20 • 25 mins',
                        onTap: () => _showAIModal(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.slate800 : Colors.white,
          border: Border.all(
            color: isActive ? AppTheme.slate800 : AppTheme.slate200,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.slate500,
          ),
        ),
      ),
    );
  }
}

class _ForYouCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ForYouCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
