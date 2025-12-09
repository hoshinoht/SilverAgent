import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AIAssistantModal extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isProcessing;

  const AIAssistantModal({
    super.key,
    required this.onSubmit,
    required this.isProcessing,
  });

  @override
  State<AIAssistantModal> createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends State<AIAssistantModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _quickSuggestions = [
    'Ride to Office',
    'Chicken Rice @ Maxwell',
    'Pay Bills',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty && !widget.isProcessing) {
      widget.onSubmit(_controller.text);
      _controller.clear();
    }
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose,
      child: Material(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping modal content
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: AppTheme.modalShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, Color(0xFF00D863)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'SingaSuper MCP',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _handleClose,
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'I can help you book rides, order food, or schedule appointments. Try asking "Book a ride to Marina Bay".',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Input Area
                    Container(
                      color: AppTheme.slate50,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Text Input
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.slate900,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    enabled: !widget.isProcessing,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'What do you need done?',
                                      hintStyle: TextStyle(
                                        color: AppTheme.slate400,
                                        fontSize: 15,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _handleSubmit(),
                                    autofocus: true,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          _controller.text.isNotEmpty &&
                                              !widget.isProcessing
                                          ? AppTheme.primary
                                          : AppTheme.slate700,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _handleSubmit,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          alignment: Alignment.center,
                                          child: widget.isProcessing
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.send,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Quick Suggestions
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _quickSuggestions
                                  .map(
                                    (suggestion) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _controller.text = suggestion;
                                            setState(() {});
                                          },
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: AppTheme.slate200,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              suggestion,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.slate600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
