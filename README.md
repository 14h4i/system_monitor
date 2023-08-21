# system_monitor

[![pub package](https://img.shields.io/pub/v/system_monitor.svg)](https://pub.dev/packages/system_monitor)

A Flutter package to monitor system CPU and RAM usage using a WebSocket connection to a Python backend. This package works in conjunction with the `system_monitor_cli` package, which provides a command-line interface for managing the Python server.

## Using system_monitor_cli
This package can be used in conjunction with the [system_monitor_cli](https://pub.dev/packages/system_monitor_cli) package, which provides a command-line interface for managing the Python server. For more details on how to use the CLI tool, please refer to the [system_monitor_cli README](https://pub.dev/packages/system_monitor_cli).

## Getting Started

### Prerequisites

Before using this package, make sure you have Python installed on your computer. You can download Python from the official website: https://www.python.org/

You also need to install the following Python libraries:

- psutil: A cross-platform library for accessing system details and process utilities.
- websockets: A library for building WebSocket servers and clients in Python.

### Installing Python Libraries

#### Using pip

```bash
pip install psutil
pip install websockets
```

Using pip3 (for Python 3)

```bash
pip3 install psutil
pip3 install websockets
```

### Installation

To use this package, add `system_monitor` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  system_monitor: ^1.0.0
```

### Usage

Import the package

```dart
import 'package:system_monitor/system_monitor.dart';
```

Initialize the monitor

Before using the package, you need to initialize the monitor by creating an instance of `SystemMonitor` and calling its `init()` method:

```dart
SystemMonitor monitor = SystemMonitor();
await monitor.init();
```

### Get RAM Usage

To get the current RAM usage in GB, you can call the `getRamUsage()` method:

```dart
double ramUsage = await monitor.getRamUsage();
print('RAM Usage: $ramUsage GB');
```

### Get CPU Usage

To get the current CPU usage in percentage, you can call the `getCpuUsage()` method:

```dart
double cpuUsage = await monitor.getCpuUsage();
print('CPU Usage: $cpuUsage%');
```

### Realtime Monitoring

You can also start realtime monitoring of CPU and RAM usage using the `startRealtimeMonitoring()` method:

```dart
StreamSubscription<Map<String, double>> subscription = monitor.startRealtimeMonitoring().listen((data) {
  double ramUsage = data['ram'];
  double cpuUsage = data['cpu'];
  print('Realtime RAM Usage: $ramUsage GB, CPU Usage: $cpuUsage%');
});
```

Don't forget to cancel the subscription when you no longer need realtime monitoring:

```dart
subscription.cancel();
```

### Closing the Connection

When you are done using the monitor, make sure to close the connection to the Python backend:

```dart
monitor.close();
```

## Example

For a complete example, check out the `example` folder in this repository.

## License

This package is licensed under the MIT License - see the [LICENSE](https://github.com/14h4i/system_monitor/blob/main/LICENSE) file for details.
