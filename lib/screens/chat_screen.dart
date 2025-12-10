// Chat Screen - Main screen with chat interface
// Features: messages list, input field with voice recognition, history drawer

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_models.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_actions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _currentTranscript = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      // Request microphone permission first
      // Wrap in try-catch for Linux/Desktop where plugin might be missing
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        _speechAvailable = await _speech.initialize(
          onError: (error) {
            print('Speech recognition error: $error');
            setState(() => _isListening = false);
          },
          onStatus: (status) {
            print('Speech recognition status: $status');
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
        );
        print('Speech available: $_speechAvailable');
      } else {
        print('Microphone permission denied');
        _speechAvailable = false;
      }
    } catch (e) {
      print('Error initializing speech (likely missing plugin): $e');
      _speechAvailable = false;
    }
    setState(() {});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _currentTranscript = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _currentTranscript = result.recognizedWords;
            if (result.finalResult) {
              _textController.text +=
                  (_textController.text.isNotEmpty ? ' ' : '') +
                  _currentTranscript;
              _currentTranscript = '';
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_SG',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Listening... Speak now!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
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
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      drawer: _buildHistoryDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

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

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
    final chatProvider = context.watch<ChatProvider>();
    final showBackButton = Navigator.canPop(context) || !chatProvider.isNewConversation;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button (if can pop or in active conversation)
            if (showBackButton)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      chatProvider.startNewConversation();
                    }
                  },
                ),
              ),
            // Menu button
            if (!showBackButton)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            
            // Logo & Title
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SilverAgent',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Healthcare Helper',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Profile button
            IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                child: Icon(Icons.person_rounded, size: 20, color: theme.colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          // Greeting
          Text(
            'Hello ${chatProvider.medicalHistory?.name ?? "there"}! 👋',
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "I'm your SilverAgent helper. I can help you book doctor appointments easily.",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Features
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureIcon(Icons.mic, 'Speak to me'),
              _buildFeatureIcon(Icons.message, 'Easy booking'),
              _buildFeatureIcon(Icons.people, 'Family notified'),
            ],
          ),
          const SizedBox(height: 32),
          // Section title
          Text(
            'What do you need help with today?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildFeatureIcon(IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    final chatProvider = context.watch<ChatProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Listening indicator
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentTranscript.isEmpty
                        ? 'Listening... Speak now'
                        : '"$_currentTranscript"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
          // Input row
          Row(
            children: [
              // Voice button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: chatProvider.isLoading ? null : _toggleListening,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _isListening
                          ? Colors.white
                          : theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !chatProvider.isLoading,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening...'
                                : 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      // Send button
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: IconButton(
                          onPressed:
                              _textController.text.trim().isEmpty ||
                                  chatProvider.isLoading
                              ? null
                              : _sendMessage,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _textController.text.trim().isEmpty
                                ? Colors.grey.shade400
                                : theme.colorScheme.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: _textController.text.trim().isNotEmpty
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          if (_speechAvailable) ...[
            const SizedBox(height: 8),
            Text(
              'Tap mic and say: "Book SGH appointment next week"',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 24),
                  const SizedBox(width: 12),
                  Text('Task History', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.read<ChatProvider>().startNewConversation();
                      Navigator.pop(context);
                    },
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
                            Icons.message_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation to\ncreate your first task',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = chatProvider.conversations[index];
                      final isActive =
                          conv.id == chatProvider.activeConversationId;

                      return ListTile(
                        selected: isActive,
                        leading: Icon(
                          _getStatusIcon(conv.status),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          conv.title,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          conv.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _formatDate(conv.timestamp),
                          style: theme.textTheme.labelSmall,
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

  IconData _getStatusIcon(ConversationStatus status) {
    if (status == ConversationStatus.completed) {
      return Icons.check_circle;
    } else if (status == ConversationStatus.active) {
      return Icons.chat_bubble;
    } else if (status == ConversationStatus.error) {
      return Icons.error;
    } else {
      return Icons.access_time;
    }
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
