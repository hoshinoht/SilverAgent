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
        return Icons.business_rounded;
      case 'singhealth':
        return Icons.local_hospital_rounded;
      case 'nuhs':
        return Icons.medical_services_rounded;
      case 'help':
        return Icons.support_agent_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'call':
        return Icons.phone_in_talk_rounded;
      case 'smart':
        return Icons.auto_awesome_rounded;
      case 'doctor':
        return Icons.person_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(action.icon),
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Label
              Text(
                action.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.sublabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  action.sublabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
