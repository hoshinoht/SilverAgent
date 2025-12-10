// SilverAgent - Singapore Super App
// Main entry point for the application

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SilverAgentApp());
}

/// Provides scale factor to descendant widgets
class ScaleProvider extends InheritedWidget {
  final double scale;

  const ScaleProvider({
    super.key,
    required this.scale,
    required super.child,
  });

  static double of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ScaleProvider>();
    return provider?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(ScaleProvider oldWidget) => scale != oldWidget.scale;
}

class SilverAgentApp extends StatelessWidget {
  const SilverAgentApp({super.key});

  // Base design height (the default window height)
  static const double baseHeight = 1200.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'SilverAgent - Singapore Super App',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const ScaledApp(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B14F),
        primary: const Color(0xFF00B14F),
        secondary: const Color(0xFFFF7043),
        surface: const Color(0xFFF0F2F5),
        error: const Color(0xFFD32F2F),
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}

/// Widget that provides scale factor based on window size
class ScaledApp extends StatelessWidget {
  const ScaledApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale factor based on window height
        final double scaleFactor = constraints.maxHeight / SilverAgentApp.baseHeight;
        // Clamp scale factor to reasonable bounds
        final double scale = scaleFactor.clamp(0.8, 2.5);

        return ScaleProvider(
          scale: scale,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: const ChatScreen(),
          ),
        );
      },
    );
  }
}

// Extension to easily get scaled values
extension ScaledContext on BuildContext {
  double get scale => ScaleProvider.of(this);
  double scaled(double value) => value * ScaleProvider.of(this);
}
