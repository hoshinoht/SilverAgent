import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isPromo;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.isPromo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 56, maxHeight: 56),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.slate100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, size: 24, color: iconColor)),
                  if (isPromo)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.slate700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
