// Chat Screen - Main chat interface for SilverAgent Super App
// Features: messages list, keyboard input, tool call cards, thinking blocks

import 'package:flutter/material.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button for history drawer
          IconButton(
            icon: Icon(Icons.menu_rounded, size: 24 * s),
            color: Colors.black87,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          // Back button (when in conversation)
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (!provider.isNewConversation) {
                return IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * s),
                  color: Colors.black87,
                  onPressed: () => provider.startNewConversation(),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Centered Title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SilverAgent',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    fontSize: 20 * s,
                  ),
                ),
                Text(
                  'Singapore Super App',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontSize: 12 * s,
                  ),
                ),
              ],
            ),
          ),

          // Connection indicator
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return Container(
                padding: EdgeInsets.all(8 * s),
                child: Icon(
                  provider.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: provider.isConnected ? Colors.green : Colors.orange,
                  size: 20 * s,
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

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24 * s, 24 * s, 24 * s, 100 * s),
      child: Column(
        children: [
          SizedBox(height: 20 * s),
          // Logo
          Container(
            width: 80 * s,
            height: 80 * s,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24 * s),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16 * s,
                  offset: Offset(0, 6 * s),
                ),
              ],
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 40 * s),
          ),
          SizedBox(height: 24 * s),
          // Greeting
          Text(
            'Hello! I\'m SilverAgent',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 28 * s,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * s),
          Text(
            'Your Singapore super assistant. I can help you with Grab rides, healthcare appointments, weather checks, and more!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 16 * s,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40 * s),

          // Section title
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              fontSize: 18 * s,
            ),
          ),
          SizedBox(height: 16 * s),
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
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    final chatProvider = context.watch<ChatProvider>();
    // Allow input when there's a pending decline (user needs to respond)
    final isDisabled = chatProvider.isLoading || chatProvider.hasPendingToolCall;
    final hasPendingDecline = chatProvider.hasPendingDecline;
    final s = context.scale;

    // Determine hint text
    String hintText;
    if (hasPendingDecline) {
      hintText = 'What would you like instead?';
    } else if (isDisabled) {
      hintText = chatProvider.hasPendingToolCall
          ? 'Respond to tool call above...'
          : 'Waiting for response...';
    } else {
      hintText = 'Type your message...';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 24 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10 * s,
            offset: Offset(0, -2 * s),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24 * s),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: !isDisabled,
                style: TextStyle(fontSize: 16 * s),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20 * s,
                    vertical: 14 * s,
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16 * s),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          // Send button
          Material(
            color: isDisabled
                ? Colors.grey.shade300
                : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24 * s),
            child: InkWell(
              onTap: isDisabled ? null : _sendMessage,
              borderRadius: BorderRadius.circular(24 * s),
              child: Container(
                width: 48 * s,
                height: 48 * s,
                alignment: Alignment.center,
                child: chatProvider.isLoading
                    ? SizedBox(
                        width: 20 * s,
                        height: 20 * s,
                        child: CircularProgressIndicator(
                          strokeWidth: 2 * s,
                          valueColor: AlwaysStoppedAnimation(
                            isDisabled ? Colors.grey : Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: isDisabled ? Colors.grey.shade500 : Colors.white,
                        size: 22 * s,
                      ),
              ),
            ),
          ),
        ],
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
