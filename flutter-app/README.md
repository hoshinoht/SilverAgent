# SingaSuper - AI-Powered Super App

A Flutter Android application that demonstrates MCP (Model Context Protocol) automation for a Singaporean Super App. This app allows users to book rides, order food, manage deliveries, and more through natural language commands powered by Google's Gemini AI.

## Features

- 🤖 **AI-Powered Task Creation**: Use natural language to create tasks across multiple services
- 🚗 **Multi-Service Support**: Transport, Food, Mart, Health, Finance, Delivery, and more
- 📊 **Real-time Task Tracking**: Monitor task execution with step-by-step progress
- 🎯 **MCP Agent Automation**: Automated task delegation to specialized agents
- 💳 **Integrated Services**: All-in-one super app experience

## Services Supported

- **Transport**: Book rides to any location
- **Food**: Order meals from restaurants
- **Mart**: Grocery shopping and delivery
- **Health**: Medical appointments and health services
- **Finance**: Payment and wallet management
- **Delivery**: Express delivery services
- **General**: Other automated tasks

## Screenshots

The app includes:
- Home screen with service cards
- Active task queue with real-time updates
- AI assistant modal for natural language input
- Detailed task execution timeline
- Bottom navigation for easy access to all features

## Prerequisites

- Flutter SDK (>=3.10.1)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Google Gemini API Key

## Installation

1. **Clone the repository**
   ```bash
   cd flutter-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Gemini API Key**
   
   Open `lib/main.dart` and replace the placeholder API key:
   ```dart
   const apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
   
   Get your API key from: https://aistudio.google.com/app/apikey

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/
│   └── task.dart              # Task and execution step models
├── providers/
│   └── task_provider.dart     # State management for tasks
├── screens/
│   └── home_screen.dart       # Main home screen
├── services/
│   └── gemini_service.dart    # Gemini AI integration
├── utils/
│   └── theme.dart             # App theme and colors
├── widgets/
│   ├── ai_assistant_modal.dart    # AI input modal
│   ├── mcp_indicator.dart         # MCP connection indicator
│   ├── service_card.dart          # Service grid cards
│   ├── task_card.dart             # Task list items
│   └── task_detail_modal.dart     # Task detail view
└── main.dart                  # App entry point
```

## Usage

### Creating Tasks with AI

1. Tap the **+** button or search bar
2. Enter your request in natural language, e.g.:
   - "Book a ride to Changi Airport"
   - "Order chicken rice from Maxwell Food Centre"
   - "Schedule a doctor appointment tomorrow"
3. The AI will parse your intent and create a structured task
4. Watch as MCP agents execute the task step-by-step

### Monitoring Tasks

- **Active Tasks**: View ongoing tasks on the home screen
- **Filters**: Filter by Pending, Running, Completed, or Failed
- **Details**: Tap any task to see detailed execution timeline
- **Real-time Updates**: Tasks update automatically as they progress

## Key Components

### Task Model
Defines the structure of tasks with status, service type, execution steps, and metadata.

### Gemini Service
Integrates with Google's Gemini API to parse natural language into structured task intents using JSON schema output.

### Task Provider
Manages app state using Provider pattern, handles task creation, and simulates real-time task execution.

### AI Assistant Modal
Beautiful modal interface for natural language input with quick suggestion chips.

### Task Detail Modal
Detailed view showing task information and step-by-step execution timeline.

## Customization

### Adding New Services

1. Add service type to `models/task.dart`:
   ```dart
   enum ServiceType { ..., yourNewService }
   ```

2. Add execution steps in `services/gemini_service.dart`:
   ```dart
   case ServiceType.yourNewService:
     labels = ['Step 1', 'Step 2', ...];
   ```

3. Add service card to home screen with appropriate icon and color

### Theming

Modify colors and styles in `utils/theme.dart`:
```dart
static const Color primary = Color(0xFF00B140);
static const Color coral = Color(0xFFFF6B6B);
```

## Migration from React/TypeScript

This Flutter app is a migration of the original React/TypeScript AI Studio app. Key differences:

- **State Management**: React hooks → Flutter Provider pattern
- **UI Framework**: React components → Flutter widgets
- **API Integration**: @google/genai → google_generative_ai package
- **Styling**: Tailwind CSS → Flutter theme system
- **Navigation**: React state → Flutter bottom navigation

## API Integration

The app uses Google's Gemini 2.0 Flash model with structured output:

```dart
GenerativeModel(
  model: 'gemini-2.0-flash-exp',
  systemInstruction: '...',
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    responseSchema: Schema.object(...),
  ),
)
```

## Performance

- Lightweight state management with Provider
- Efficient list rendering with ListView.builder
- Optimized animations with built-in Flutter animations
- Automatic task simulation runs every 1.5 seconds

## Known Issues

- API key needs to be hardcoded (consider using flutter_dotenv for production)
- Activity, Pay, and Account screens are placeholder implementations
- Task simulation is client-side only (needs backend integration)

## Future Enhancements

- [ ] Backend integration for real MCP agents
- [ ] User authentication and profiles
- [ ] Payment gateway integration
- [ ] Push notifications for task updates
- [ ] Location-based services
- [ ] Historical task analytics
- [ ] Multi-language support

## Contributing

This is a demonstration app for the HackRift25 competition. Feel free to fork and customize for your needs.

## License

MIT License - feel free to use this code for learning and development.

## Credits

- Original React app design by the AI Studio team
- Migrated to Flutter by the SingaSuper team
- Powered by Google Gemini AI

## Support

For issues or questions, please refer to the Flutter documentation:
- https://docs.flutter.dev/
- https://pub.dev/packages/google_generative_ai

---

**Built with ❤️ using Flutter and Gemini AI**