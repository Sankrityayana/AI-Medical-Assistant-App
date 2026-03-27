import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/health_repository.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.read(dioProvider));
});

final healthDataProvider = FutureProvider((ref) async {
  return ref.read(healthRepositoryProvider).fetchHealthData();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: healthAsync.when(
          data: (health) {
            final bars = [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: health.steps / 1000)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: health.heartRate.toDouble())]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: health.sleepHours)]),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Steps: ${health.steps}', style: Theme.of(context).textTheme.titleMedium),
                Text('Heart rate: ${health.heartRate} bpm'),
                Text('Sleep: ${health.sleepHours.toStringAsFixed(1)} h'),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      barGroups: bars,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              const labels = ['Steps(k)', 'BPM', 'Sleep'];
                              final index = value.toInt();
                              return Text(index >= 0 && index < labels.length ? labels[index] : '');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Failed to load dashboard data')),
        ),
      ),
    );
  }
}
