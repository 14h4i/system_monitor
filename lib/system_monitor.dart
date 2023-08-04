library system_monitor;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path/path.dart' as path;

class SystemMonitor {
  final String _host;
  final int _port;
  late WebSocketChannel _realtimeChannel;
  late WebSocketChannel _requestChannel;

  Completer completer = Completer();

  SystemMonitor._({String host = 'localhost', int port = 8765})
      : _host = host,
        _port = port;

  static SystemMonitor? _instance;

  static SystemMonitor get instance {
    _instance ??= SystemMonitor._();
    return _instance!;
  }

  Future<void> init() async {
    await runServer();

    final url = 'ws://$_host:$_port';
    _realtimeChannel = WebSocketChannel.connect(Uri.parse(url));
    _requestChannel = WebSocketChannel.connect(Uri.parse(url));

    _requestChannel.stream.listen((event) {
      completer.complete(event);
    });
  }

  Future<double> getRamUsage() async {
    completer = Completer();
    _requestChannel.sink.add('get_ram');
    final response = await completer.future;
    if (response.startsWith('ram,')) {
      final ramUsedGB = double.tryParse(response.substring(4));
      return ramUsedGB ?? 0;
    }
    return 0;
  }

  Future<double> getCpuUsage() async {
    completer = Completer();
    _requestChannel.sink.add('get_cpu');
    final response = await completer.future;
    if (response.startsWith('cpu,')) {
      final cpuPercentage = double.tryParse(response.substring(4));
      return cpuPercentage ?? 0;
    }
    return 0;
  }

  Stream<Map<String, double>> startRealtimeMonitoring() async* {
    _realtimeChannel.sink.add('realtime');
    await for (var message in _realtimeChannel.stream) {
      if (message.contains(',')) {
        final data = message.split(',');
        final ramUsedGB = double.tryParse(data[0]);
        final cpuPercentage = double.tryParse(data[1]);

        if (ramUsedGB != null && cpuPercentage != null) {
          yield {'ram': ramUsedGB, 'cpu': cpuPercentage};
        }
      }
    }
  }

  Future<bool> isServerRunning() async {
    try {
      final url = 'ws://$_host:$_port';
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.sink.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> runServer() async {
    final String currentDirectory = Directory.current.path;
    final String serverFilePath = path.join(currentDirectory, '../server.py');

    if (await File(serverFilePath).exists()) {
      final bool isRunning = await isServerRunning();

      if (isRunning) {
        log('Server is already running on port 8765.');
      } else {
        log('Running server.py...');
        Process.start('python', [serverFilePath]).then((process) {
          process.stdout.transform(utf8.decoder).listen((data) {
            log('server.py: $data');
          });
          process.stderr.transform(utf8.decoder).listen((data) {
            log('server.py error: $data');
          });
        });
      }
    } else {
      log('server.py not found.');
    }
  }

  Future<void> stopServer() async {
    final bool isRunning = await isServerRunning();

    if (isRunning) {
      log('Stopping server...');

      Process.start('pkill', ['-f', 'python server.py']).then((process) {
        process.stdout.transform(utf8.decoder).listen((data) {
          log('Stop server output: $data');
        });
        process.stderr.transform(utf8.decoder).listen((data) {
          log('Stop server error: $data');
        });
      });
    } else {
      log('Server is not running.');
    }
  }

  void close() {
    _realtimeChannel.sink.close();
    _requestChannel.sink.close();
    stopServer();
  }
}
