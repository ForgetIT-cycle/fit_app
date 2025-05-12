import "package:fit_app/services/database_helper.dart";
import "package:flutter/material.dart";
import "package:fl_chart/fl_chart.dart";
import "package:intl/intl.dart";
import "dart:math"; // Still used for some placeholders if DB is empty

class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Random random = Random();
  List<BarChartGroupData> _barGroups = [];
  List<Map<String, dynamic>> _dailySummaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch data for the bar chart (e.g., total calories for last 4 months)
    // This requires a new method in DatabaseHelper or complex query here.
    // For simplicity, let's simulate fetching monthly aggregated data.
    // In a real app, DatabaseHelper would have a method like `getMonthlyCaloriesBurned()`
    final List<Map<String, dynamic>> monthlyData =
        await _dbHelper.getMonthlyAggregatedDataForCharts();

    if (mounted) {
      if (monthlyData.isNotEmpty) {
        _barGroups = List.generate(
          monthlyData.length > 4 ? 4 : monthlyData.length,
          (index) {
            final monthData = monthlyData[index]; // Assuming sorted by month
            return BarChartGroupData(
              x: index, // Represents month index
              barRods: [
                BarChartRodData(
                  toY: (monthData["totalCalories"] as num? ?? 0).toDouble(),
                  color: Theme.of(context).colorScheme.secondary,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          },
        );
      } else {
        // Fallback to random data if DB is empty or no aggregated data
        _generatePlaceholderChartData();
      }

      // Fetch recent activities for daily summaries
      final recentActivities = await _dbHelper.getRecentWorkoutLogs(limit: 5);
      _dailySummaries =
          recentActivities.map((activity) {
            final date = DateTime.parse(
              activity[DatabaseHelper.columnDateCompleted] as String,
            );
            return {
              "date": date,
              "day": DateFormat.E().format(date).toUpperCase(), // e.g., THU
              "dayOfMonth": date.day.toString(),
              "activityName": activity[DatabaseHelper.columnActivityName],
              "calories": activity[DatabaseHelper.columnCaloriesBurned] ?? 0,
              "duration":
                  "${activity[DatabaseHelper.columnDurationMinutes] ?? 0}m",
            };
          }).toList();

      if (_dailySummaries.isEmpty) {
        _generatePlaceholderDailySummaries();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generatePlaceholderChartData() {
    _barGroups = List.generate(4, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (random.nextInt(1500) + 500).toDouble(), // Calories range
            color: Theme.of(context).colorScheme.secondary,
            width: 22,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  void _generatePlaceholderDailySummaries() {
    _dailySummaries = List.generate(3, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return {
        "date": date,
        "day": DateFormat.E().format(date).toUpperCase(),
        "dayOfMonth": date.day.toString(),
        "activityName": "Sample Activity ${index + 1}",
        "calories": random.nextInt(300) + 100,
        "duration": "${random.nextInt(30) + 15}m",
      };
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    // This should map to actual month names based on the data
    // For now, using placeholder based on index if monthlyData is available
    if (_barGroups.isNotEmpty && value.toInt() < _barGroups.length) {
      // Ideally, the monthlyData would contain month names/numbers
      text = DateFormat.MMM().format(
        DateTime(
          DateTime.now().year,
          DateTime.now().month - (_barGroups.length - 1 - value.toInt()),
          1,
        ),
      );
    } else {
      text = "Mon ${value.toInt() + 1}"; // Fallback
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    // Adjust based on expected calorie range
    if (value % 500 == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(meta.formattedValue, style: const TextStyle(fontSize: 10)),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Ensure chart colors are updated if theme changes, might need a more robust way
    if (_barGroups.isNotEmpty &&
        _barGroups[0].barRods[0].color !=
            Theme.of(context).colorScheme.secondary) {
      _barGroups =
          _barGroups.map((group) {
            return group.copyWith(
              barRods: [
                group.barRods[0].copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            );
          }).toList();
    }

    return RefreshIndicator(
      onRefresh: _loadChartData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Activity",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child:
                  _barGroups.isEmpty
                      ? Center(
                        child: Text(
                          "No chart data available.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                      : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              _barGroups.isNotEmpty
                                  ? (_barGroups
                                              .map((g) => g.barRods[0].toY)
                                              .reduce(max) *
                                          1.2)
                                      .clamp(500, double.infinity)
                                  : 500, // Dynamic maxY
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                return BarTooltipItem(
                                  "${rod.toY.round()} kcal",
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: _bottomTitles,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: _leftTitles,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups: _barGroups,
                        ),
                      ),
            ),
            const Divider(height: 48),
            Text(
              "Recent Activities",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _dailySummaries.isEmpty
                ? Center(
                  child: Text(
                    "No recent activities.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dailySummaries.length,
                  itemBuilder: (context, index) {
                    final summary = _dailySummaries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    summary["day"],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    summary["dayOfMonth"],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary["activityName"].toString(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Calories: ${summary["calories"]}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "Duration: ${summary["duration"]}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            // Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
