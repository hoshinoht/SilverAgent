// Chat Screen - Main chat interface for SilverAgent Super App
// Features: messages list, keyboard input, tool call cards, thinking blocks

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_actions.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      drawer: _buildHistoryDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

            // Connection status banner
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (!provider.servicesInitialized) {
                  return _buildStatusBanner(
                    context,
                    theme,
                    'Initializing services...',
                    Colors.blue,
                    Icons.sync,
                    isLoading: true,
                  );
                }
                if (!provider.isConnected) {
                  return _buildStatusBanner(
                    context,
                    theme,
                    'LLM server not connected',
                    Colors.orange,
                    Icons.warning_amber,
                    action: TextButton(
                      onPressed: () => provider.retryConnection(),
                      child: const Text('Retry'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Messages area
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  if (chatProvider.isNewConversation) {
                    return _buildWelcomeScreen(context, chatProvider);
                  }

                  final s = context.scale;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: chatProvider.messages[index],
                      );
                    },
                  );
                },
              ),
            ),

            // Input area
            _buildInputArea(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final s = context.scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button - modern pill style
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: IconButton(
              icon: Icon(Icons.menu_rounded, size: 22 * s),
              color: Colors.grey.shade700,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              splashRadius: 24 * s,
            ),
          ),

          SizedBox(width: 4 * s),

          // Back button (when in conversation)
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (!provider.isNewConversation) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, size: 22 * s),
                    color: Colors.grey.shade700,
                    onPressed: () => provider.startNewConversation(),
                    splashRadius: 24 * s,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Centered Title with logo
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32 * s,
                  height: 32 * s,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        const Color(0xFF00695C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18 * s,
                  ),
                ),
                SizedBox(width: 10 * s),
                Text(
                  'SilverAgent',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    fontSize: 18 * s,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Connection indicator - modern style
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              final isConnected = provider.isConnected;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20 * s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8 * s,
                      height: 8 * s,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Text(
                      isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w600,
                        color: isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    ThemeData theme,
    String message,
    Color color,
    IconData icon, {
    bool isLoading = false,
    Widget? action,
  }) {
    final s = context.scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 16 * s,
              height: 16 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2 * s,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          else
            Icon(icon, color: color, size: 18 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14 * s,
              ),
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final s = context.scale;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface,
            theme.colorScheme.primary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24 * s, 32 * s, 24 * s, 120 * s),
        child: Column(
          children: [
            SizedBox(height: 24 * s),
            // Modern animated-style logo with glow
            Container(
              padding: EdgeInsets.all(4 * s),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.6),
                    const Color(0xFF00695C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 32 * s,
                    spreadRadius: 2 * s,
                  ),
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 64 * s,
                    spreadRadius: 8 * s,
                  ),
                ],
              ),
              child: Container(
                width: 88 * s,
                height: 88 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 44 * s,
                ),
              ),
            ),
            SizedBox(height: 32 * s),
            // Modern greeting with gradient text effect
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  const Color(0xFF1A1A1A),
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ).createShader(bounds),
              child: Text(
                'SilverAgent',
                style: TextStyle(
                  fontSize: 36 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20 * s),
              ),
              child: Text(
                'Your Singapore Super Assistant',
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 20 * s),
            Text(
              'I can help you book Grab rides, manage healthcare appointments, check weather, and more.',
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.6,
                fontSize: 16 * s,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48 * s),

            // Section title with line accents
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  child: Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 13 * s,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              ],
            ),
            SizedBox(height: 24 * s),
            // Quick actions
            QuickActionsWidget(
              actions: chatProvider.quickActions,
              onActionClick: (prompt) {
                chatProvider.sendMessage(prompt);
                _scrollToBottom();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    final chatProvider = context.watch<ChatProvider>();
    final isDisabled = chatProvider.isLoading || chatProvider.hasPendingToolCall;
    final hasPendingDecline = chatProvider.hasPendingDecline;
    final s = context.scale;
    final hasText = _textController.text.trim().isNotEmpty;

    // Determine hint text
    String hintText;
    if (hasPendingDecline) {
      hintText = 'What would you like instead?';
    } else if (isDisabled) {
      hintText = chatProvider.hasPendingToolCall
          ? 'Respond to tool call above...'
          : 'Waiting for response...';
    } else {
      hintText = 'Message SilverAgent...';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 20 * s),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16 * s,
              offset: Offset(0, 2 * s),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 24 * s,
              spreadRadius: -4 * s,
            ),
          ],
          border: Border.all(
            color: _focusNode.hasFocus
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  // Send on Enter (without Shift), allow Shift+Enter for new line
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    if (!isDisabled && hasText) {
                      _sendMessage();
                    }
                    return KeyEventResult.handled; // Prevent newline
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !isDisabled,
                  style: TextStyle(
                    fontSize: 16 * s,
                    color: const Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(20 * s, 16 * s, 8 * s, 16 * s),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16 * s,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}), // Rebuild to update button state
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            // Send button
            Padding(
              padding: EdgeInsets.only(right: 6 * s, bottom: 6 * s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  gradient: (isDisabled || !hasText)
                      ? null
                      : LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            const Color(0xFF00695C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: (isDisabled || !hasText) ? Colors.grey.shade100 : null,
                  shape: BoxShape.circle,
                  boxShadow: (isDisabled || !hasText)
                      ? null
                      : [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8 * s,
                            offset: Offset(0, 2 * s),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (isDisabled || !hasText) ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(22 * s),
                    child: Center(
                      child: chatProvider.isLoading
                          ? SizedBox(
                              width: 20 * s,
                              height: 20 * s,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5 * s,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              color: (isDisabled || !hasText)
                                  ? Colors.grey.shade400
                                  : Colors.white,
                              size: 24 * s,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.scale;

    return Drawer(
      width: 280 * s,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, size: 24 * s, color: theme.colorScheme.primary),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Text(
                      'Conversation History',
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 16 * s),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: theme.colorScheme.primary, size: 24 * s),
                    onPressed: () {
                      context.read<ChatProvider>().startNewConversation();
                      Navigator.pop(context);
                    },
                    tooltip: 'New Conversation',
                  ),
                ],
              ),
            ),
            // Conversations list
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  if (chatProvider.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64 * s,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16 * s),
                          Text(
                            'No conversations yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 16 * s,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            'Start chatting to create one',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: 14 * s,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = chatProvider.conversations[index];
                      final isActive = conv.id == chatProvider.activeConversationId;

                      return ListTile(
                        selected: isActive,
                        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 4 * s),
                        leading: Icon(
                          _getConversationIcon(conv.title),
                          color: isActive
                              ? theme.colorScheme.primary
                              : Colors.grey.shade600,
                          size: 24 * s,
                        ),
                        title: Text(
                          conv.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 15 * s,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          conv.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 13 * s),
                        ),
                        trailing: Text(
                          _formatDate(conv.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 12 * s,
                          ),
                        ),
                        onTap: () {
                          chatProvider.selectConversation(conv.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getConversationIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('grab') || lower.contains('ride')) {
      return Icons.directions_car;
    } else if (lower.contains('health') || lower.contains('doctor') || lower.contains('hospital')) {
      return Icons.local_hospital;
    } else if (lower.contains('weather')) {
      return Icons.wb_sunny;
    }
    return Icons.chat_bubble_outline;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}
