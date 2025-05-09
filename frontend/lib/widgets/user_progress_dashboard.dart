// user_progress_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../themes/color.dart';

class UserProgressDashboard extends StatelessWidget {
  const UserProgressDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for testing
    final overallProgress = 0.75;
    final bestLessons = [
      {'lesson': 'Lesson 1', 'score': 90},
      {'lesson': 'Lesson 2', 'score': 88},
      {'lesson': 'Lesson 5', 'score': 85},
    ];
    final worstLessons = [
      {'lesson': 'Lesson 4', 'score': 40},
      {'lesson': 'Lesson 3', 'score': 45},
      {'lesson': 'Lesson 6', 'score': 50},
    ];
    final topMistakeWords = [
      {'word': 'Hello', 'count': 12},
      {'word': 'Thank you', 'count': 9},
      {'word': 'Sorry', 'count': 8},
      {'word': 'Yes', 'count': 7},
      {'word': 'No', 'count': 6},
      {'word': 'Name', 'count': 5},
      {'word': 'Please', 'count': 5},
      {'word': 'Love', 'count': 4},
      {'word': 'Eat', 'count': 4},
      {'word': 'Water', 'count': 3},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('User Overall Progress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overall Grade",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: overallProgress,
              color: AppColors.accentOrange,
              backgroundColor: Colors.grey[300],
              minHeight: 12,
            ),
            const SizedBox(height: 24),
            const Text(
              "Best Lessons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 200,
              child: _LessonBarGraph(
                dataKey: 'lesson',
                valueKey: 'score',
                items: [
                  {'lesson': 'Lesson 1', 'score': 90},
                  {'lesson': 'Lesson 2', 'score': 88},
                  {'lesson': 'Lesson 5', 'score': 85},
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Worst Lessons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 200,
              child: _LessonBarGraph(
                dataKey: 'lesson',
                valueKey: 'score',
                items: [
                  {'lesson': 'Lesson 4', 'score': 40},
                  {'lesson': 'Lesson 3', 'score': 45},
                  {'lesson': 'Lesson 6', 'score': 50},
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Top 10 Mistake Words",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 200,
              child: _LessonBarGraph(
                dataKey: 'word',
                valueKey: 'count',
                items: [
                  {'word': 'Hello', 'count': 12},
                  {'word': 'Thank you', 'count': 9},
                  {'word': 'Sorry', 'count': 8},
                  {'word': 'Yes', 'count': 7},
                  {'word': 'No', 'count': 6},
                  {'word': 'Name', 'count': 5},
                  {'word': 'Please', 'count': 5},
                  {'word': 'Love', 'count': 4},
                  {'word': 'Eat', 'count': 4},
                  {'word': 'Water', 'count': 3},
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonBarGraph extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String dataKey;
  final String valueKey;

  const _LessonBarGraph({
    required this.items,
    required this.dataKey,
    required this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return index < items.length
                    ? Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        items[index][dataKey],
                        style: const TextStyle(fontSize: 10),
                      ),
                    )
                    : const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (item[valueKey] as num).toDouble(),
                    color: AppColors.accentOrange,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
