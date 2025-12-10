// Quick Actions Widget - Modern grid of quick action buttons
// Displays large, visually appealing action buttons for common tasks

import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../main.dart';

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
    final s = context.scale;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16 * s,
        mainAxisSpacing: 16 * s,
        childAspectRatio: 1.1,
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

class _QuickActionButton extends StatefulWidget {
  final QuickAction action;
  final VoidCallback onTap;

  const _QuickActionButton({required this.action, required this.onTap});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isPressed = false;

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.local_taxi_rounded;
      case 'local_hospital':
        return Icons.medical_services_rounded;
      case 'wb_sunny':
        return Icons.cloud_rounded;
      case 'help_outline':
        return Icons.support_agent_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  List<Color> _getGradientColors(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return [const Color(0xFF00B14F), const Color(0xFF00D160)];
      case 'local_hospital':
        return [const Color(0xFFE53935), const Color(0xFFFF5252)];
      case 'wb_sunny':
        return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
      case 'help_outline':
        return [const Color(0xFF5C6BC0), const Color(0xFF7986CB)];
      default:
        return [const Color(0xFF00B14F), const Color(0xFF00D160)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.scale;
    final gradientColors = _getGradientColors(widget.action.icon);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isPressed
            ? (Matrix4.identity()..setEntry(0, 0, 0.95)..setEntry(1, 1, 0.95)..setEntry(2, 2, 0.95))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24 * s),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.4),
              blurRadius: _isPressed ? 8 * s : 16 * s,
              offset: Offset(0, _isPressed ? 4 * s : 8 * s),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20 * s,
              bottom: -20 * s,
              child: Icon(
                _getIcon(widget.action.icon),
                size: 120 * s,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(20 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon in rounded square
                  Container(
                    width: 56 * s,
                    height: 56 * s,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16 * s),
                    ),
                    child: Icon(
                      _getIcon(widget.action.icon),
                      size: 32 * s,
                      color: Colors.white,
                    ),
                  ),
                  // Labels
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.action.label,
                        style: TextStyle(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.action.sublabel != null) ...[
                        SizedBox(height: 4 * s),
                        Text(
                          widget.action.sublabel!,
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
