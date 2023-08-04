library system_monitor;

import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class SystemMonitor {
  final String _host;
  final int _port;
  late WebSocketChannel _channel;

  SystemMonitor({String host = 'localhost', int port = 8765})
      : _host = host,
        _port = port;

  Future<void> connect() async {
    final url = 'ws://$_host:$_port';
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Future<double> getRamUsage() async {
    _channel.sink.add('get_ram');
    final response = await _channel.stream.first;
    if (response.startsWith('ram,')) {
      final ramUsedGB = double.tryParse(response.substring(4));
      return ramUsedGB ?? 0;
    }
    return 0;
  }

  Future<double> getCpuUsage() async {
    _channel.sink.add('get_cpu');
    final response = await _channel.stream.first;
    if (response.startsWith('cpu,')) {
      final cpuPercentage = double.tryParse(response.substring(4));
      return cpuPercentage ?? 0;
    }
    return 0;
  }

  Stream<Map<String, double>> startRealtimeMonitoring() async* {
    _channel.sink.add('realtime');
    await for (var message in _channel.stream) {
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

  void close() {
    _channel.sink.close();
  }
}
