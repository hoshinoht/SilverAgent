// ThinkingBlock - Collapsible widget for displaying LLM thinking/strategy

import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../main.dart';

class ThinkingBlock extends StatelessWidget {
  final ThinkingData thinking;
  final VoidCallback? onToggle;

  const ThinkingBlock({
    super.key,
    required this.thinking,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.scale;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16 * s),
              bottom: Radius.circular(thinking.isExpanded ? 0 : 16 * s),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 16 * s),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10 * s),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.purple.shade700,
                      size: 28 * s,
                    ),
                  ),
                  SizedBox(width: 16 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thinking',
                          style: TextStyle(
                            fontSize: 18 * s,
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!thinking.isExpanded)
                          Text(
                            _getPreview(),
                            style: TextStyle(
                              fontSize: 15 * s,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    thinking.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                    size: 32 * s,
                  ),
                ],
              ),
            ),
          ),

          // Content (collapsible)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: thinking.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16 * s),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SelectableText(
                  thinking.content,
                  style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.grey.shade800,
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPreview() {
    // Get first line or first 50 characters
    final firstLine = thinking.content.split('\n').first;
    if (firstLine.length > 60) {
      return '${firstLine.substring(0, 60)}...';
    }
    return firstLine;
  }
}
