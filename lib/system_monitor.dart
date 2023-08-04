library system_monitor;

import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class SystemMonitor {
  final String _host;
  final int _port;
  late WebSocketChannel _realtimeChannel;
  late WebSocketChannel _requestChannel;

  Completer completer = Completer();

  SystemMonitor({String host = 'localhost', int port = 8765})
      : _host = host,
        _port = port;

  Future<void> connect() async {
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

  void close() {
    _realtimeChannel.sink.close();
    _requestChannel.sink.close();
  }
}
