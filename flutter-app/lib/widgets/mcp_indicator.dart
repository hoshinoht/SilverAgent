import 'package:flutter/material.dart';
import '../utils/theme.dart';

class MCPIndicator extends StatelessWidget {
  final bool connected;
  final bool processing;

  const MCPIndicator({
    super.key,
    required this.connected,
    required this.processing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connection indicator dot
          SizedBox(
            width: 8,
            height: 8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (connected) _PulsingDot(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: connected ? AppTheme.primary : AppTheme.slate400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Text label
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MCP LINK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate700,
                  letterSpacing: 0.5,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                processing
                    ? 'PROCESSING...'
                    : connected
                    ? 'ONLINE'
                    : 'OFFLINE',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slate400,
                  height: 1,
                ),
              ),
            ],
          ),
          if (processing) ...[
            const SizedBox(width: 8),
            const Icon(Icons.bolt, size: 12, color: Colors.amber),
          ],
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.5),
          child: Opacity(
            opacity: 1.0 - _controller.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
