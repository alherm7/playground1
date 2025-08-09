import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final String centerText;
  const ProgressRing({super.key, required this.progress, required this.centerText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 16,
          ),
          Text(centerText, style: Theme.of(context).textTheme.displaySmall),
        ],
      ),
    );
  }
}
