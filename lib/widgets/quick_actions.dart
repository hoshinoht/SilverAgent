// Quick Actions Widget - Grid of quick action buttons
// Displays action buttons for common tasks on the welcome screen

import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;
  final Function(String) onActionClick;

  const QuickActionsWidget({
    super.key,
    required this.actions,
    required this.onActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _QuickActionButton(
          action: actions[index],
          onTap: () => onActionClick(actions[index].prompt),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;
  final VoidCallback onTap;

  const _QuickActionButton({required this.action, required this.onTap});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'polyclinic':
        return Icons.business;
      case 'singhealth':
        return Icons.local_hospital;
      case 'nuhs':
        return Icons.medical_services;
      case 'help':
        return Icons.help_outline;
      case 'calendar':
        return Icons.calendar_today;
      case 'call':
        return Icons.phone;
      case 'smart':
        return Icons.auto_awesome;
      case 'doctor':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(action.icon),
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                action.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.sublabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  action.sublabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
