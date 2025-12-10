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
  bool _isKeyboardVisible = false;

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
            debugPrint('Speech recognition error: $error');
            setState(() => _isListening = false);
          },
          onStatus: (status) {
            debugPrint('Speech recognition status: $status');
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
        );
        debugPrint('Speech available: $_speechAvailable');
      } else {
        debugPrint('Microphone permission denied');
        _speechAvailable = false;
      }
    } catch (e) {
      debugPrint('Error initializing speech (likely missing plugin): $e');
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
      backgroundColor: theme.colorScheme.surface,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            if (Navigator.canPop(context) || !context.watch<ChatProvider>().isNewConversation)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                color: Colors.black87,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.read<ChatProvider>().startNewConversation();
                  }
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
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Healthcare Helper',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Profile button
            IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, size: 20, color: theme.colorScheme.primary),
              ),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, ChatProvider chatProvider) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      // Add extra bottom padding to avoid floating input covering content
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          // Greeting
          Text(
            'Hello ${chatProvider.medicalHistory?.name ?? "there"}! 👋',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "I'm your SilverAgent helper. I can help you book doctor appointments easily.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Section title
          Text(
            'What do you need help with today?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
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



  Widget _buildInputArea(BuildContext context, ThemeData theme) {
    final chatProvider = context.watch<ChatProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Listening indicator
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentTranscript.isEmpty
                        ? 'Listening...'
                        : '"$_currentTranscript"',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Floating Input Island
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isKeyboardVisible 
              ? // Text Input Mode
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isKeyboardVisible = false),
                      icon: const Icon(Icons.mic_rounded),
                      color: theme.colorScheme.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                )
              : // Voice Input Mode
                Row(
                  children: [
                    // Huge Voice Button (Floating)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: chatProvider.isLoading ? null : _toggleListening,
                        borderRadius: BorderRadius.circular(32),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isListening
                                  ? [const Color(0xFFFF5252), const Color(0xFFD32F2F)]
                                  : [theme.colorScheme.primary, const Color(0xFF00695C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? theme.colorScheme.error : theme.colorScheme.primary).withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Text prompt
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isListening ? 'Listening...' : 'Tap to Speak',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'or type your request',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Keyboard Button
                    IconButton(
                      onPressed: () => setState(() => _isKeyboardVisible = true),
                      icon: const Icon(Icons.keyboard_alt_rounded),
                      color: Colors.grey.shade600,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade50,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          ),
          
          if (_speechAvailable && !_isKeyboardVisible) ...[
            const SizedBox(height: 16),
            Text(
              'Try saying: "Book appointment at SGH"',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
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
