// unit_detail_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../themes/color.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class UnitDetailWidget extends StatefulWidget {
  final Map<String, dynamic> unit;
  const UnitDetailWidget({super.key, required this.unit});

  @override
  State<UnitDetailWidget> createState() => _UnitDetailWidgetState();
}

class _UnitDetailWidgetState extends State<UnitDetailWidget> {
  final ApiService _apiService = ApiService();
  Map<int, List<Map<String, dynamic>>> lessonMistakes = {};
  Map<int, List<Map<String, dynamic>>> lessonTopWords = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    for (var lesson in widget.unit['lessons']) {
      final resMistakes = await _apiService.get(
        '/analytics/lesson-mistakes/${lesson['id']}',
      );
      final resTopWords = await _apiService.get(
        '/analytics/lesson-top-words/${lesson['id']}',
      );

      if (resMistakes.statusCode == 200) {
        final data = json.decode(resMistakes.body);
        lessonMistakes[lesson['id']] = List<Map<String, dynamic>>.from(
          data['mistakes'],
        );
      }

      if (resTopWords.statusCode == 200) {
        final data = json.decode(resTopWords.body);
        lessonTopWords[lesson['id']] = List<Map<String, dynamic>>.from(
          data['top_words'],
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.unit['name'])),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: widget.unit['lessons'].length,
                itemBuilder: (context, index) {
                  final lesson = widget.unit['lessons'][index];
                  final grade = lesson['grade'];
                  final mistakes = lessonMistakes[lesson['id']] ?? [];
                  final topWords = lessonTopWords[lesson['id']] ?? [];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Grade: $grade"),
                          const SizedBox(height: 16),
                          const Text("Top 10 Words with Mistakes"),
                          mistakes.isNotEmpty
                              ? SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            return index < mistakes.length
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 6,
                                                      ),
                                                  child: Text(
                                                    mistakes[index]['word'],
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                )
                                                : const SizedBox();
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups:
                                        mistakes.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final wordData = entry.value;
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY:
                                                    (wordData['count'] as num)
                                                        .toDouble(),
                                                color: AppColors.accentOrange,
                                                width: 18,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                              )
                              : const Text("No mistake data available."),
                          const SizedBox(height: 24),
                          const Text("Top 10 Words with Best Performance"),
                          topWords.isNotEmpty
                              ? Wrap(
                                spacing: 8,
                                children:
                                    topWords
                                        .map(
                                          (word) =>
                                              Chip(label: Text(word['word'])),
                                        )
                                        .toList(),
                              )
                              : const Text("No top word data available."),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
