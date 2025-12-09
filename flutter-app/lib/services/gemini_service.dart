import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String apiKey;

  static const String _systemInstruction = '''
You are the automation engine for a Singaporean Super App called "SingaSuper".
Your job is to interpret user requests and convert them into structured tasks.
The user might say "Get me a car to Changi" or "Order chicken rice from Maxwell".
You must return a JSON object representing the task.
If the request is unclear, default to GENERAL service type.
The description should be concise.
Generate a realistic Singapore dollar price (e.g. S\$15.50) and ETA (e.g. 15 mins) if applicable.
Valid Service Types: TRANSPORT, FOOD, MART, HEALTH, FINANCE, DELIVERY, GENERAL.
''';

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'title': Schema.string(description: 'Short title of the task'),
            'description': Schema.string(description: 'Details of the task'),
            'serviceType': Schema.string(
              description: 'One of the valid service types',
            ),
            'price': Schema.string(
              description: 'Estimated price in SGD, e.g. S\$12.00',
            ),
            'eta': Schema.string(
              description: 'Estimated time of arrival or completion',
            ),
            'mcpAgentName': Schema.string(
              description:
                  'Name of the sub-agent handling this, e.g. TransportBot, FoodRunner',
            ),
          },
          requiredProperties: ['title', 'description', 'serviceType'],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> parseUserIntent(String userText) async {
    try {
      final response = await _model.generateContent([Content.text(userText)]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('No response from AI');
      }

      return json.decode(text) as Map<String, dynamic>;
    } catch (error) {
      print('Gemini Intent Error: $error');
      // Fallback task if AI fails
      return {
        'title': 'Request Received',
        'description': userText,
        'serviceType': 'GENERAL',
        'price': '-',
        'eta': 'Calculating...',
        'mcpAgentName': 'SupportAgent',
      };
    }
  }

  ServiceType _parseServiceType(String typeString) {
    final upperType = typeString.toUpperCase();
    switch (upperType) {
      case 'TRANSPORT':
        return ServiceType.transport;
      case 'FOOD':
        return ServiceType.food;
      case 'MART':
        return ServiceType.mart;
      case 'HEALTH':
        return ServiceType.health;
      case 'FINANCE':
        return ServiceType.finance;
      case 'DELIVERY':
        return ServiceType.delivery;
      default:
        return ServiceType.general;
    }
  }

  List<ExecutionStep> generateStepsForType(ServiceType type) {
    List<String> labels;

    switch (type) {
      case ServiceType.transport:
        labels = [
          'Request Received',
          'Locating Nearby Drivers',
          'Driver Assigned',
          'Driver En Route',
          'Arrived at Pickup',
        ];
        break;
      case ServiceType.food:
        labels = [
          'Order Placed',
          'Merchant Confirming',
          'Preparing Food',
          'Rider Picked Up',
          'Delivered',
        ];
        break;
      case ServiceType.mart:
        labels = [
          'Order Received',
          'Shopper Assigned',
          'Picking Items',
          'Checkout Complete',
          'Out for Delivery',
        ];
        break;
      case ServiceType.health:
        labels = [
          'Appointment Requested',
          'Checking Doctor Availability',
          'Slot Reserved',
          'Confirmation Sent',
        ];
        break;
      default:
        labels = [
          'Analyzing Request',
          'Identifying Agent',
          'Processing',
          'Finalizing Task',
        ];
    }

    return labels.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      return ExecutionStep(
        id: 'step-${DateTime.now().millisecondsSinceEpoch}-$index',
        label: label,
        status: index == 0 ? TaskStatus.inProgress : TaskStatus.pending,
        timestamp: index == 0 ? DateTime.now() : null,
      );
    }).toList();
  }

  Future<Task> createTaskFromIntent(String userText) async {
    final intent = await parseUserIntent(userText);
    final serviceType = _parseServiceType(intent['serviceType'] as String);

    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: intent['title'] as String,
      description: intent['description'] as String,
      status: TaskStatus.inProgress,
      serviceType: serviceType,
      timestamp: DateTime.now(),
      mcpAgentName: intent['mcpAgentName'] as String?,
      price: intent['price'] as String?,
      eta: intent['eta'] as String?,
      executionSteps: generateStepsForType(serviceType),
    );
  }
}
