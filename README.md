# SilverAgent - Singapore Super App

A senior-friendly AI-powered super app built with Flutter, designed to help Singaporeans (especially seniors) manage healthcare appointments, book rides, order food, and access essential services through natural conversational AI.

## Overview

SilverAgent is Singapore's first AI-powered super app that combines:
- **Advanced AI Assistant**: Powered by a fine-tuned SEA-LION language model optimized for Singapore context
- **Multi-Service Integration**: Healthcare (NUH), Transportation (Grab), Weather, and more
- **Senior-Friendly Design**: Adaptive scaling, large text, clear buttons, and simple navigation
- **Natural Language Understanding**: Supports English and Singlish with context-aware responses
- **Multi-Agent System**: Specialized agents for different service portals (NUH, Grab, Weather)
- **Proactive Assistance**: Smart suggestions for weather and transport based on appointments

## AI Model

SilverAgent uses a **fine-tuned SEA-LION language model** specifically optimized for Singapore healthcare and service interactions:

### Model Details
- **Model**: [LLJYY/SEALION-TC-v1](https://huggingface.co/LLJYY/SEALION-TC-v1)
- **Base**: SEA-LION (Southeast Asian Languages In One Network)
- **Fine-tuning**: Custom dataset for Singapore healthcare, Singlish understanding, and senior-friendly interactions
- **Capabilities**:
  - Intent detection for healthcare appointments, ride booking, food ordering
  - Context-aware conversation management
  - Singlish and colloquial language understanding
  - Proactive suggestions (weather checks before appointments, transport booking)
  - Error handling and retry logic for service failures

### Why SEA-LION?
- Trained on Southeast Asian languages and contexts
- Better understanding of Singlish and local expressions
- Optimized for Singapore-specific entities (hospitals, locations, services)
- Lower latency for regional deployments

## Architecture

### New Design Features

#### 1. **Adaptive Scaling System**
The app automatically scales UI elements based on device and window size:
- Base design height: 1200px
- Dynamic scale factor: 0.8x to 2.5x
- Text and spacing scale proportionally
- Optimized for tablets, phones, and accessibility modes

#### 2. **Multi-Agent Architecture**
```
SilverAgent (Main)
├── NUH Agent (Healthcare Portal)
│   ├── Appointments
│   ├── Medical Records
│   ├── Prescriptions
│   └── Lab Results
├── Grab Agent (Transport & Food)
│   ├── Ride Booking
│   ├── Food Ordering
│   └── Service Tracking
└── Weather Agent (Proactive)
    ├── Current Conditions
    ├── Forecasts
    └── UV Index
```

#### 3. **Strategy-Based Reasoning**
Every AI response follows a structured reasoning pattern:
- **Intent Detection**: What does the user want?
- **Task Status Tracking**: Is the primary request complete?
- **Tool Selection**: Which single tool to call next?
- **Proactive Logic**: When to offer additional help (weather, transport)

#### 4. **Enhanced Chat Interface**
- **Thinking Blocks**: Visual representation of AI reasoning process
- **Tool Call Cards**: Display service integrations in real-time
- **Retry Logic**: Automatic retries with user-friendly error messages
- **Status Indicators**: Loading, success, error, and retry states

## Features

### Core Capabilities
- ✅ Natural language conversation in English and Singlish
- ✅ Voice input with speech-to-text (planned)
- ✅ Quick action buttons for common tasks
- ✅ Multi-service integration (Healthcare, Transport, Weather)
- ✅ Conversation history with task tracking
- ✅ Adaptive UI scaling for accessibility
- ✅ Proactive assistance and suggestions
- ✅ Context-aware error handling

### Service Integrations

#### Healthcare (NUH MCP)
- Book, reschedule, and cancel appointments
- View medical records and prescriptions
- Check lab results
- Monitor clinic queue status
- Get doctor information

#### Transportation & Food (Grab MCP)
- Book rides (GrabCar, GrabShare, Premium)
- Track ride status and ETA
- Order food delivery
- Search restaurants
- View order history

#### Weather Services
- Current weather conditions
- Multi-day forecasts
- Weather alerts
- UV index for outdoor activities

### User Experience
- Material Design 3 components
- Smooth animations and transitions
- Responsive layouts for all screen sizes
- Accessibility-friendly design with adaptive scaling
- Safe area handling for modern devices
- Dark mode support (planned)

## Project Structure

```
lib/
├── main.dart                      # App entry point with scaling system
├── models/                        # Data models
│   ├── chat_models.dart          # Chat, Message, Conversation models
│   └── medical_history.dart      # Medical history models (legacy)
├── providers/                     # State management
│   └── chat_provider.dart        # Chat state with multi-agent support
├── screens/                       # App screens
│   └── chat_screen.dart          # Main chat interface
├── services/                      # Business logic
│   ├── medical_history_service.dart  # Legacy medical service
│   └── silver_agent_service.dart     # AI intent detection & responses
├── utils/                         # Utilities
│   └── (utility functions)
└── widgets/                       # Reusable components
    ├── message_bubble.dart       # Chat message bubbles
    ├── quick_actions.dart        # Quick action buttons
    ├── thinking_block.dart       # AI reasoning visualization
    └── tool_call_card.dart       # Service integration cards
```

## Getting Started

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK (3.9.0 or higher)
- iOS/Android development environment set up
- For iOS: Xcode 14+
- For Android: Android Studio with SDK 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd refusedbequest-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys** (when integrating real services)
   
   Create a `.env` file in the project root:
   ```env
   HUGGINGFACE_API_KEY=your_hf_api_key_here
   NUH_API_KEY=your_nuh_api_key
   GRAB_API_KEY=your_grab_api_key
   ```

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
| `intl` | Internationalization and date formatting |
| `shared_preferences` | Local data persistence |
| `uuid` | Unique ID generation |
| `http` | HTTP client for API calls |

## Troubleshooting

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

- [ ] Real API integration with NUH, Grab, Weather services
- [ ] Voice input with speech-to-text
- [ ] Multi-language support (Mandarin, Malay, Tamil)
- [ ] Offline mode with local caching
- [ ] Push notifications for appointments and reminders
- [ ] Calendar integration
- [ ] Medication reminders
- [ ] Video call with doctors
- [ ] Dark mode support
- [ ] Accessibility enhancements

## License

This project is licensed under the MIT License.

## Contributors

This project was built by Team RefusedBequest for HackRift 2025:

- **Lucas** - AI/ML Engineering & Model Fine-tuning
- **William** - System Design & Multi-Agent Architecture
- **Haoting** - Flutter Development & UI/UX
- **Keiren** - UI/UX Design
- **Annaqi** - Product Design & User Research



## Acknowledgments

- SEA-LION team for the base language model
- Singapore healthcare system for inspiration
- Seniors who provided valuable feedback during user testing
- HackRift 2025 organizers and mentors

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: team@silveragent.sg

---

**Made with ❤️ for Singapore's seniors**
