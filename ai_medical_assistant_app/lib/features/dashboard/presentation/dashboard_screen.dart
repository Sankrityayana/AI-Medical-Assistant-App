import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/widgets/blue_gradient_background.dart';
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
    final scheme = Theme.of(context).colorScheme;

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
      body: BlueGradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: healthAsync.when(
            data: (health) {
              final bars = [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: health.steps / 1000,
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(6),
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: health.heartRate.toDouble(),
                      color: scheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                      width: 20,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: health.sleepHours,
                      color: scheme.tertiary,
                      borderRadius: BorderRadius.circular(6),
                      width: 20,
                    ),
                  ],
                ),
              ];

              Widget statCard({required IconData icon, required String label, required String value}) {
                return Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: scheme.primary),
                          const SizedBox(height: 10),
                          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Health Snapshot',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track key activity and wellness signals in one place.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        statCard(icon: Icons.directions_walk_rounded, label: 'Steps', value: '${health.steps}'),
                        const SizedBox(width: 10),
                        statCard(icon: Icons.favorite_rounded, label: 'Heart Rate', value: '${health.heartRate} bpm'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        statCard(
                          icon: Icons.nights_stay_rounded,
                          label: 'Sleep',
                          value: '${health.sleepHours.toStringAsFixed(1)} h',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.insights_rounded, color: scheme.secondary),
                                  const SizedBox(height: 10),
                                  Text('Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text('Balanced', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitals Overview',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  barGroups: bars,
                                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) {
                                          const labels = ['Steps(k)', 'BPM', 'Sleep'];
                                          final index = value.toInt();
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(index >= 0 && index < labels.length ? labels[index] : ''),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load dashboard data')),
          ),
        ),
      ),
    );
  }
}
