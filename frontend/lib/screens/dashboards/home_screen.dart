import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../themes/color.dart';
import '../../services/api_service.dart';
import '../dashboards/based_user_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  int? userId;
  Map<String, dynamic>? profile;
  List<dynamic> units = [];
  Map<int, Map<String, dynamic>> lessonStatuses = {};
  Map<int, Map<String, dynamic>> lessonProgress = {};
  Map<String, dynamic>? dailyChallenge;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      userId = await _apiService.getUserId();
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final profileRes = await _apiService.get('/profile/$userId');
      final unitRes = await _apiService.get('/lessons/units/');
      final challengeRes = await _apiService.get(
        '/lessons/daily-challenges/$userId',
      );

      setState(() {
        profile = jsonDecode(profileRes.body);
        units = jsonDecode(unitRes.body);
        dailyChallenge = jsonDecode(challengeRes.body);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseUserScaffold(
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? const Center(child: Text("Something went wrong."))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDailyChallenge(),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Lessons',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...units.map(
                    (unit) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...unit['lessons']
                            .map<Widget>((lesson) => _buildLessonCard(lesson))
                            .toList(),
                        const Divider(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildDailyChallenge() {
    if (dailyChallenge == null) return const SizedBox.shrink();
    return Card(
      color: AppColors.softOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.flash_on, color: Colors.white),
        title: Text(dailyChallenge!['title'] ?? "Daily Challenge"),
        subtitle: const Text("Test your skills with today's quiz!"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.pushNamed(context, '/lesson/${dailyChallenge!['id']}');
        },
      ),
    );
  }

  Widget _buildLessonCard(dynamic lesson) {
    final isLocked = lesson['is_locked'] ?? false;
    return Card(
      color: isLocked ? Colors.grey[300] : AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(lesson['title']),
        subtitle: LinearProgressIndicator(
          value: (lesson['progress_bar'] ?? 0) / 100,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.accentOrange,
          ),
        ),
        trailing:
            isLocked
                ? const Icon(Icons.lock, color: AppColors.lockedGray)
                : const Icon(Icons.play_arrow, color: AppColors.primaryBlue),
        onTap:
            isLocked
                ? null
                : () {
                  Navigator.pushNamed(context, '/lesson/${lesson['id']}');
                },
      ),
    );
  }
}
