import 'package:flutter/material.dart';
import 'package:system_monitor/system_monitor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SystemMonitor _systemMonitor = SystemMonitor();

  @override
  void initState() {
    super.initState();
    _systemMonitor.connect();
  }

  @override
  void dispose() {
    _systemMonitor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('System Monitor Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final ramUsedGB = await _systemMonitor.getRamUsage();
                  print("RAM Usage: $ramUsedGB GB");
                },
                child: const Text('Get RAM Usage'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final cpuPercentage = await _systemMonitor.getCpuUsage();
                  print("CPU Usage: $cpuPercentage %");
                },
                child: const Text('Get CPU Usage'),
              ),
              StreamBuilder<Map<String, double>>(
                stream: _systemMonitor.startRealtimeMonitoring(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final ramUsedGB = snapshot.data?['ram'];
                    final cpuPercentage = snapshot.data?['cpu'];
                    return Column(
                      children: [
                        Text("Realtime RAM Usage: $ramUsedGB GB"),
                        Text("Realtime CPU Usage: $cpuPercentage %"),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
