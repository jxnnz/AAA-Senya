import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../themes/color.dart';
import '../../services/admin_dashboard_service.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final AdminDashboardService _dashboardService = AdminDashboardService();
  Map<String, dynamic>? summaryData;
  List<Map<String, dynamic>> lessonData = [];
  Map<String, dynamic> userPerformance = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadLessonsPerUnit();
    _loadUserPerformance();
  }

  Future<void> _loadUserPerformance() async {
    try {
      final data = await _dashboardService.fetchUserPerformance();
      setState(() {
        userPerformance = data;
      });
    } catch (e) {
      print("Error fetching user performance: $e");
    }
  }

  Future<void> _loadLessonsPerUnit() async {
    try {
      final data = await _dashboardService.fetchLessonsPerUnit();
      setState(() {
        lessonData = data;
      });
    } catch (e) {
      print('Error fetching lessons per unit: \$e');
    }
  }

  Future<void> _loadSummary() async {
    try {
      final data = await _dashboardService.fetchSummary();
      setState(() {
        summaryData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching summary: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧱 Section 1: Summary Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard(
                "Units",
                summaryData?['units']?.toString() ?? '-',
                Icons.layers,
              ),
              _buildSummaryCard(
                "Lessons",
                summaryData?['lessons']?.toString() ?? '-',
                Icons.menu_book,
              ),
              _buildSummaryCard(
                "Signs",
                summaryData?['signs']?.toString() ?? '-',
                Icons.sign_language,
              ),
              _buildSummaryCard(
                "Rubies",
                summaryData?['total_rubies']?.toString() ?? '-',
                Icons.diamond,
              ),
              _buildSummaryCard(
                "Archived",
                ((summaryData?['archived']?['units'] ?? 0) +
                        (summaryData?['archived']?['lessons'] ?? 0) +
                        (summaryData?['archived']?['signs'] ?? 0))
                    .toString(),
                Icons.archive,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 📊 Section 2: Content Distribution
          const Text("Lessons per Unit", style: _sectionHeaderStyle),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups:
                    lessonData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final unit = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (unit['lesson_count'] as num).toDouble(),
                            width: 16,
                          ),
                        ],
                      );
                    }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() < lessonData.length) {
                          return Text(lessonData[value.toInt()]['unit_title']);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🧠 Section 3: User Performance
          const Text("Most Failed Lessons", style: _sectionHeaderStyle),
          const SizedBox(height: 16),
          _buildPerformanceList(userPerformance['most_failed'] ?? []),

          const SizedBox(height: 30),

          // 📈 Section 4: Progress Insights
          const Text("Lesson Completion Rates", style: _sectionHeaderStyle),
          const SizedBox(height: 16),
          _buildCompletionChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceList(List<Map<String, dynamic>> lessons) {
    return Column(
      children:
          lessons.map((lesson) {
            return ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.red),
              title: Text(
                "Lesson ${lesson['lesson_id']} - ${lesson['lesson_title'] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                "Incorrect attempts: ${lesson['fail_count'] ?? 'N/A'}",
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCompletionChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 80, width: 18)],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 60, width: 18)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 90, width: 18)],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("L1");
                    case 1:
                      return const Text("L2");
                    case 2:
                      return const Text("L3");
                  }
                  return const Text("");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const TextStyle _sectionHeaderStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);
