# SilverAgent - Flutter Healthcare Assistant

A senior-friendly healthcare appointment booking assistant app built with Flutter. This is a complete Flutter implementation of the React-based SilverAgent application.

## Overview

SilverAgent is designed to help seniors in Singapore book healthcare appointments easily through:
- **Voice Recognition**: Speak naturally in English or Singlish
- **Smart Routing**: Automatically routes to the right hospital based on medical history
- **Multi-Agent System**: Integrates with SingHealth, NUHS, and Polyclinic portals
- **Family Loop**: Automatically notifies family members of bookings
- **Senior-Friendly UI**: Large text, clear buttons, and simple navigation

## Features

### Core Features
- ✅ Chat-based interface with AI assistant
- ✅ Voice input with speech-to-text
- ✅ Quick action buttons for common tasks
- ✅ Medical history integration (simulated MCP server)
- ✅ Smart hospital recommendations
- ✅ Conversation history with task tracking
- ✅ Profile management
- ✅ Family notification system

### User Experience
- Material Design 3 components
- Smooth animations and transitions
- Responsive layouts for different screen sizes
- Accessibility-friendly design
- Safe area handling for iOS notches

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── chat_models.dart      # Chat, Message, Conversation models
│   └── medical_history.dart  # Medical history models
├── providers/                # State management
│   └── chat_provider.dart    # Chat state provider
├── screens/                  # App screens
│   ├── chat_screen.dart      # Main chat interface
│   └── profile_screen.dart   # User profile
├── services/                 # Business logic
│   ├── medical_history_service.dart  # MCP server simulation
│   └── silver_agent_service.dart     # AI intent detection
└── widgets/                  # Reusable components
    ├── message_bubble.dart   # Chat message bubbles
    └── quick_actions.dart    # Quick action buttons
```

## Getting Started

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK (included with Flutter)
- iOS/Android development environment set up
- For iOS: Xcode 14+
- For Android: Android Studio with SDK 21+

### Installation

1. **Clone the repository**
   ```bash
   cd refusedbequest/flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   
   **For iOS**: Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>We need microphone access for voice input to help you book appointments</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>We need speech recognition to understand your voice commands</string>
   ```

   **For Android**: Permissions are already configured in `android/app/src/main/AndroidManifest.xml`

4. **Run the app**
   ```bash
   flutter run
   ```

### Development

**Run in debug mode:**
```bash
flutter run
```

**Run with hot reload:**
Press `r` in the terminal after making changes

**Run tests:**
```bash
flutter test
```

**Build for release:**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `speech_to_text` | Voice recognition |
| `permission_handler` | Runtime permissions |
| `intl` | Internationalization and date formatting |
| `shared_preferences` | Local data persistence |
| `uuid` | Unique ID generation |
| `http` | HTTP client for API calls |

## Architecture

### State Management
Uses `provider` package for reactive state management:
- `ChatProvider`: Manages chat messages, conversations, and interactions

### Services Layer
- `MedicalHistoryService`: Simulates MCP server data retrieval
- `SilverAgentService`: AI-powered intent detection and response generation

### Models
- `Message`: Individual chat messages
- `Conversation`: Chat conversation threads
- `MedicalHistory`: User's medical records
- `QuickAction`: Quick action button definitions

## Configuration

### Theme Customization
Edit `lib/main.dart` to customize colors and typography:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFFE8754F), // Primary color
  // ... other colors
)
```

### Quick Actions
Modify quick action buttons in `lib/providers/chat_provider.dart`:
```dart
final List<QuickAction> quickActions = [
  QuickAction(
    id: '1',
    label: 'Your Action',
    // ... configuration
  ),
];
```

## Voice Recognition Setup

The app uses `speech_to_text` package for voice input:
- Supports English (Singapore) locale by default
- Automatically handles permissions
- Provides real-time transcription feedback
- Falls back to text input if unavailable

**Supported Languages:**
- English (Singapore) - `en_SG`
- Can be configured for other locales

## Medical History Integration

The app simulates integration with healthcare MCP (Model Context Protocol) servers:

```dart
// Fetch medical history
final history = await MedicalHistoryService.fetchMedicalHistory();

// Get smart recommendations
final recommendation = MedicalHistoryService.getSmartHospitalRecommendation(
  history,
  symptoms,
);
```

In production, replace the mock service with actual API calls to healthcare systems.

## AI Agent System

### Intent Detection
The app uses rule-based intent detection (can be replaced with ML models):
```dart
final intent = SilverAgentService.detectIntent(userInput);
```

### Multi-Agent Routing
- **General Agent**: Initial triage
- **SingHealth Portal**: SGH and affiliated hospitals
- **NUHS Portal**: NUH and affiliated hospitals
- **Polyclinic Portal**: General healthcare

### Smart Recommendations
Based on:
- Medical history
- Previous appointments
- Symptom analysis
- User preferences

## Family Loop Feature

Automatically notifies family members when appointments are booked:
- Configured in user profile
- Toggle on/off per booking
- Shows notification status in chat

## Testing

### Unit Tests
```bash
flutter test test/models/
flutter test test/services/
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widgets/
```

## Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release APK: `flutter build apk --release`
3. Or build App Bundle: `flutter build appbundle --release`

### iOS
1. Configure signing in Xcode
2. Build: `flutter build ios --release`
3. Archive and upload via Xcode or Transporter

## Troubleshooting

### Speech Recognition Not Working
- Check microphone permissions
- Ensure device has internet (some recognition requires cloud)
- Test on physical device (may not work on simulators)

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Hot Reload Issues
```bash
# Stop the app and restart
flutter run
```

## Roadmap

- [ ] Real MCP server integration
- [ ] Advanced ML-based intent recognition
- [ ] Multi-language support (Mandarin, Malay, Tamil)
- [ ] Offline mode
- [ ] Push notifications
- [ ] Calendar integration
- [ ] Medication reminders
- [ ] Video call with doctors

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Original React implementation of SilverAgent
- Flutter and Dart teams for excellent documentation
- Singapore healthcare system for inspiration
- Seniors who provided valuable feedback

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: support@silveragent.sg
- Documentation: https://docs.silveragent.sg

---

**Made with ❤️ for Singapore's seniors**