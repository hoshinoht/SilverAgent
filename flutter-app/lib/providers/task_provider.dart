import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/gemini_service.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  Timer? _simulationTimer;
  bool _isProcessing = false;
  GeminiService? _geminiService;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isProcessing => _isProcessing;

  TaskProvider() {
    _initializeMockData();
    _startSimulation();
  }

  void setGeminiService(GeminiService service) {
    _geminiService = service;
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Grocery Delivery',
        description: 'FairPrice Finest - 12 items',
        status: TaskStatus.completed,
        serviceType: ServiceType.mart,
        timestamp: now.subtract(const Duration(minutes: 100)),
        mcpAgentName: 'MartBot',
        price: 'S\$45.20',
        executionSteps: [
          ExecutionStep(
            id: '1-1',
            label: 'Order Received',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 100)),
          ),
          ExecutionStep(
            id: '1-2',
            label: 'Shopper Assigned',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 90)),
          ),
          ExecutionStep(
            id: '1-3',
            label: 'Items Packed',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 80)),
          ),
          ExecutionStep(
            id: '1-4',
            label: 'Delivered',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 60)),
          ),
        ],
      ),
      Task(
        id: '2',
        title: 'Ride to Changi Airport',
        description: 'Terminal 3, Door 4',
        status: TaskStatus.completed,
        serviceType: ServiceType.transport,
        timestamp: now.subtract(const Duration(minutes: 2000)),
        mcpAgentName: 'TransportBot',
        price: 'S\$24.50',
        executionSteps: [
          ExecutionStep(
            id: '2-1',
            label: 'Request Received',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 2000)),
          ),
          ExecutionStep(
            id: '2-2',
            label: 'Driver Assigned',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 1900)),
          ),
          ExecutionStep(
            id: '2-3',
            label: 'Arrived at Destination',
            status: TaskStatus.completed,
            timestamp: now.subtract(const Duration(minutes: 1500)),
          ),
        ],
      ),
    ]);
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _updateInProgressTasks(),
    );
  }

  void _updateInProgressTasks() {
    bool hasChanges = false;

    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.status != TaskStatus.inProgress) continue;

      final steps = List<ExecutionStep>.from(task.executionSteps);
      final activeStepIndex = steps.indexWhere(
        (s) => s.status != TaskStatus.completed,
      );

      // If all steps completed, mark task as completed
      if (activeStepIndex == -1) {
        _tasks[i] = task.copyWith(status: TaskStatus.completed);
        hasChanges = true;
        continue;
      }

      final activeStep = steps[activeStepIndex];

      // Progress the step
      if (activeStep.status == TaskStatus.pending) {
        steps[activeStepIndex] = activeStep.copyWith(
          status: TaskStatus.inProgress,
          timestamp: DateTime.now(),
        );
        _tasks[i] = task.copyWith(executionSteps: steps);
        hasChanges = true;
      } else if (activeStep.status == TaskStatus.inProgress) {
        // Random chance to complete the step
        if (DateTime.now().millisecond % 3 != 0) {
          steps[activeStepIndex] = activeStep.copyWith(
            status: TaskStatus.completed,
          );
          _tasks[i] = task.copyWith(executionSteps: steps);
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> createTaskFromText(String text) async {
    if (_geminiService == null) {
      throw Exception('GeminiService not initialized');
    }

    _isProcessing = true;
    notifyListeners();

    try {
      // Simulate initial latency
      await Future.delayed(const Duration(milliseconds: 600));

      final task = await _geminiService!.createTaskFromIntent(text);
      _tasks.add(task);
      notifyListeners();
    } catch (error) {
      print('Task creation failed: $error');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Task> getFilteredTasks(TaskStatus? status) {
    if (status == null) return tasks;
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getRecentTasks({int limit = 3}) {
    final reversed = _tasks.reversed.toList();
    return reversed.take(limit).toList();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
