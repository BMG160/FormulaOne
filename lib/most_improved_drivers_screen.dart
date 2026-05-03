import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'most_improved_driver.dart';

class MostImprovedDriversScreen extends StatefulWidget {
  const MostImprovedDriversScreen({super.key});

  @override
  State<MostImprovedDriversScreen> createState() =>
      _MostImprovedDriversScreenState();
}

class _MostImprovedDriversScreenState
    extends State<MostImprovedDriversScreen> {
  late Future<List<MostImprovedDriver>> futureDrivers;

  @override
  void initState() {
    super.initState();
    futureDrivers = ApiService.fetchMostImprovedDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Most Improved Drivers'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MostImprovedDriver>>(
        future: futureDrivers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final drivers = snapshot.data;

          if (drivers == null || drivers.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final topDriver = drivers.first;
          final maxY = drivers
              .map((e) => e.avgPositionsGained)
              .reduce((a, b) => a > b ? a : b) +
              1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Most Improved Driver',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                topDriver.driverName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Avg positions gained: ${topDriver.avgPositionsGained.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Total positions gained: ${topDriver.totalPositionsGained.toStringAsFixed(0)}',
                              ),
                              Text(
                                'Races: ${topDriver.races}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Top 10 Most Improved Drivers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 420,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 || index >= drivers.length) {
                                return const SizedBox.shrink();
                              }

                              return SideTitleWidget(
                                space: 8,
                                axisSide: meta.axisSide,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    drivers[index].driverName,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        drivers.length,
                            (index) {
                          final driver = drivers[index];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: driver.avgPositionsGained,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Driver Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...drivers.map(
                      (driver) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${drivers.indexOf(driver) + 1}',
                        ),
                      ),
                      title: Text(driver.driverName),
                      subtitle: Text(
                        'Avg gained: ${driver.avgPositionsGained.toStringAsFixed(2)} | Total gained: ${driver.totalPositionsGained.toStringAsFixed(0)} | Races: ${driver.races}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}