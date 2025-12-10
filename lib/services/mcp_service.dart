// McpService - MCP subprocess management and tool execution
// Spawns MCP servers as stdio subprocesses and handles JSON-RPC communication

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Represents a running MCP server process
class McpServerProcess {
  final String name;
  final Process process;
  final StreamController<String> _outputController = StreamController.broadcast();
  final Map<int, Completer<Map<String, dynamic>>> _pendingRequests = {};
  int _requestId = 0;
  StringBuffer _buffer = StringBuffer();

  McpServerProcess({required this.name, required this.process}) {
    // Listen to stdout and parse JSON-RPC responses
    process.stdout.transform(utf8.decoder).listen(_handleOutput);
    process.stderr.transform(utf8.decoder).listen((data) {
      debugPrint('[$name stderr] $data');
    });
  }

  void _handleOutput(String data) {
    _buffer.write(data);

    // Try to parse complete JSON messages
    final content = _buffer.toString();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final json = jsonDecode(line);
        _handleJsonRpcResponse(json);
      } catch (e) {
        // Not valid JSON, might be partial
        debugPrint('[$name] Non-JSON output: $line');
      }
    }

    // Keep the last incomplete line in buffer
    _buffer = StringBuffer(lines.last);
  }

  void _handleJsonRpcResponse(Map<String, dynamic> response) {
    final id = response['id'];
    if (id != null && _pendingRequests.containsKey(id)) {
      final completer = _pendingRequests.remove(id)!;
      if (response.containsKey('error')) {
        completer.completeError(response['error']);
      } else {
        completer.complete(response['result'] ?? {});
      }
    }
  }

  /// Send a JSON-RPC request and wait for response
  Future<Map<String, dynamic>> sendRequest(String method, Map<String, dynamic> params) async {
    final id = ++_requestId;
    final request = {
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    };

    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[id] = completer;

    final jsonStr = jsonEncode(request);
    debugPrint('[$name] Sending: $jsonStr');
    process.stdin.writeln(jsonStr);

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(id);
        throw TimeoutException('Request timed out');
      },
    );
  }

  /// Call a tool on this MCP server
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    return sendRequest('tools/call', {
      'name': toolName,
      'arguments': arguments,
    });
  }

  /// List available tools
  Future<List<Map<String, dynamic>>> listTools() async {
    final result = await sendRequest('tools/list', {});
    return List<Map<String, dynamic>>.from(result['tools'] ?? []);
  }

  void dispose() {
    _outputController.close();
    process.kill();
  }
}

/// Service to manage all MCP servers
class McpService {
  final Map<String, McpServerProcess> _servers = {};
  final String mcpBasePath;
  bool _initialized = false;

  // Tool name to server mapping
  final Map<String, String> _toolToServer = {};

  // Weather tools are auto-approved (safe, read-only operations)
  static const _autoApprovedTools = {
    'get_current_weather',
    'get_forecast',
    'get_weather_alerts',
    'get_uv_index',
  };

  McpService({
    this.mcpBasePath = '../mcps',
  });

  /// Check if a tool is auto-approved (doesn't need user confirmation)
  bool isAutoApproved(String toolName) => _autoApprovedTools.contains(toolName);

  bool get isInitialized => _initialized;

  /// Available tools from all servers
  Map<String, String> get toolToServer => Map.unmodifiable(_toolToServer);

  /// Initialize and start all MCP servers
  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('Initializing MCP servers...');

    // Start each MCP server
    await _startServer('grab-mcp', '$mcpBasePath/grab-mcp');
    await _startServer('nuh-mcp', '$mcpBasePath/nuh-mcp');
    await _startServer('weather-mcp', '$mcpBasePath/weather-mcp');

    // Initialize each server and get tool lists
    for (final entry in _servers.entries) {
      try {
        // Send initialize request
        await entry.value.sendRequest('initialize', {
          'protocolVersion': '2024-11-05',
          'capabilities': {},
          'clientInfo': {
            'name': 'SilverAgent',
            'version': '1.0.0',
          },
        });

        // Send initialized notification
        final initNotification = {
          'jsonrpc': '2.0',
          'method': 'notifications/initialized',
        };
        entry.value.process.stdin.writeln(jsonEncode(initNotification));

        // Get tool list
        final tools = await entry.value.listTools();
        for (final tool in tools) {
          final toolName = tool['name'] as String;
          _toolToServer[toolName] = entry.key;
          debugPrint('Registered tool: $toolName -> ${entry.key}');
        }
      } catch (e) {
        debugPrint('Error initializing ${entry.key}: $e');
      }
    }

    _initialized = true;
    debugPrint('MCP servers initialized. Tools: ${_toolToServer.keys.join(', ')}');
  }

  Future<void> _startServer(String name, String path) async {
    try {
      debugPrint('Starting MCP server: $name at $path');

      // Use the project script entry point defined in pyproject.toml
      // e.g., grab-mcp = "grab_mcp.server:mcp.run"
      final process = await Process.start(
        'uv',
        ['run', name],  // 'uv run grab-mcp' uses the installed package entry point
        workingDirectory: path,
        environment: {
          ...Platform.environment,
        },
      );

      _servers[name] = McpServerProcess(name: name, process: process);
      debugPrint('Started $name (PID: ${process.pid})');

      // Give server time to start (first run needs longer for venv setup)
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      debugPrint('Failed to start $name: $e');
    }
  }

  /// Execute a tool call
  Future<Map<String, dynamic>> executeTool(String toolName, Map<String, dynamic> arguments) async {
    final serverName = _toolToServer[toolName];
    if (serverName == null) {
      return {
        'error': 'Unknown tool: $toolName',
        'available_tools': _toolToServer.keys.toList(),
      };
    }

    final server = _servers[serverName];
    if (server == null) {
      return {'error': 'Server not running: $serverName'};
    }

    try {
      debugPrint('Executing tool: $toolName with args: $arguments');
      final result = await server.callTool(toolName, arguments);
      debugPrint('Tool result: $result');
      return result;
    } catch (e) {
      debugPrint('Tool execution error: $e');
      return {'error': 'Tool execution failed: $e'};
    }
  }

  /// Check if a tool is available
  bool hasTools(String toolName) {
    return _toolToServer.containsKey(toolName);
  }

  /// Get all available tool names
  List<String> get availableTools => _toolToServer.keys.toList();

  /// Dispose all server processes
  void dispose() {
    debugPrint('Disposing MCP servers...');
    for (final server in _servers.values) {
      server.dispose();
    }
    _servers.clear();
    _toolToServer.clear();
    _initialized = false;
  }
}

// ToolCall and ToolCallStatus are now in chat_models.dart
