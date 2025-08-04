// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/timer_home_page.dart';

void main() {
  runApp(const ProviderScope(child: WorkoutTimerApp()));
}

class WorkoutTimerApp extends StatelessWidget {
  const WorkoutTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerHomePage(),
    );
  }
}
