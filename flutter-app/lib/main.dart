import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'services/gemini_service.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';
import 'widgets/mcp_indicator.dart';
import 'widgets/ai_assistant_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'SingaSuper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late GeminiService _geminiService;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ActivityScreen(),
    const PayScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Gemini service
    // TODO: Replace with your actual API key from environment
    const apiKey = 'YOUR_GEMINI_API_KEY_HERE';
    _geminiService = GeminiService(apiKey: apiKey);

    // Set Gemini service in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(
        context,
        listen: false,
      ).setGeminiService(_geminiService);
    });
  }

  void _showAIModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        return AIAssistantModal(
          onSubmit: (text) async {
            try {
              await taskProvider.createTaskFromText(text);
              if (mounted) Navigator.of(context).pop();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          isProcessing: taskProvider.isProcessing,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Current Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.slate500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text(
                                  'Marina One, Singapore',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.slate800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppTheme.slate400,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Consumer<TaskProvider>(
                              builder: (context, taskProvider, _) {
                                return MCPIndicator(
                                  connected: true,
                                  processing: taskProvider.isProcessing,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  size: 22,
                                  color: AppTheme.slate700,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Search Bar (only on home screen)
                  if (_selectedIndex == 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: GestureDetector(
                        onTap: _showAIModal,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.slate100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 20,
                                color: AppTheme.slate500,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Where to? What to eat?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const Divider(height: 1, color: AppTheme.slate100),
                ],
              ),
            ),
            // Content
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),
      // Bottom Navigation with FAB
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.slate100, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.explore, 'Activity', 1),
                const SizedBox(width: 60), // Space for FAB
                _buildNavItem(Icons.account_balance_wallet, 'Pay', 2),
                _buildNavItem(Icons.person, 'Account', 3),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.slate50, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.slate900.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAIModal,
          backgroundColor: AppTheme.slate900,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.primary : AppTheme.slate400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 64, color: AppTheme.slate300),
          SizedBox(height: 16),
          Text(
            'Activity Feed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'View all your tasks and history',
            style: TextStyle(fontSize: 14, color: AppTheme.slate500),
          ),
        ],
      ),
    );
  }
}

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: AppTheme.slate300,
          ),
          SizedBox(height: 16),
          Text(
            'Payment Hub',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your wallet and payments',
            style: TextStyle(fontSize: 14, color: AppTheme.slate500),
          ),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: AppTheme.slate300),
          SizedBox(height: 16),
          Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Profile settings and preferences',
            style: TextStyle(fontSize: 14, color: AppTheme.slate500),
          ),
        ],
      ),
    );
  }
}
