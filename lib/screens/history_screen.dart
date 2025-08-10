import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/logging.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider);
    final fmt = DateFormat('EEE, MMM d • HH:mm');
    if (logs.isEmpty) {
      return const Center(child: Text('No workouts yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final l = logs[i];
        final weather = l.temperatureC != null
            ? '• ${l.temperatureC!.toStringAsFixed(0)}°C wind ${l.windKph?.toStringAsFixed(0) ?? '-'}'
            : '';
        final where = l.latitude != null
            ? '(@ ${l.latitude!.toStringAsFixed(2)}, ${l.longitude!.toStringAsFixed(2)})'
            : '';
        return Card(
          child: ListTile(
            title: Text(l.planName),
            subtitle: Text('${fmt.format(l.startedAt)} $weather\n$where'),
            isThreeLine: true,
            trailing: Text('${(l.totalSeconds / 60).floor()}m'),
          ),
        );
      },
    );
  }
}
