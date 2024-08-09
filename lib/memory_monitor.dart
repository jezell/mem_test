import "package:flutter/material.dart";
import "memory_usage.dart" if (dart.library.js_interop) 'memory_usage_web.dart';
import "dart:async";

const showMemMonitor = bool.fromEnvironment("SHOW_MEM_MONITOR");

class MemoryMonitor extends StatefulWidget {
  const MemoryMonitor({super.key});

  @override
  State createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  @override
  void initState() {
    super.initState();

    bytes = getMemoryUsageBytes();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        bytes = getMemoryUsageBytes();
      });
    });
  }

  late Timer timer;

  int bytes = 0;

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: switch (bytes) {
              > 1024 * 1024 * 1024 => Colors.red,
              > 512 * 1024 * 1024 => Colors.orange,
              _ => Colors.green,
            },
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text("${(bytes / 1024.0 / 1024.0).ceil()}MB",
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Color.fromARGB(0xff, 0xff, 0xff, 0xff))));
  }
}
