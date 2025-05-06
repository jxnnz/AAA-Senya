// home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:http/http.dart' as http;
import '../../themes/color.dart';
import '../../services/api_service.dart';

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

  static const List<Color> lessonColors = [
    Color(0xFF2C3F6D),
    Color(0xFF83B100),
    Color(0xFFE82C36),
    Color(0xFF4C1199),
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() => isLoading = true);
      userId = await _apiService.getUserId();
      debugPrint("User ID: $userId");

      if (userId == null) throw Exception("User ID not found");

      final profileRes = await _apiService.get("/profile/$userId");
      debugPrint("Profile Response: ${profileRes.body}");
      profile = jsonDecode(profileRes.body);

      final unitsRes = await _apiService.get("/lessons/units/");
      debugPrint("Units Response: ${unitsRes.body}");
      units = jsonDecode(unitsRes.body);

      try {
        final challengeRes = await _apiService.get(
          "/lessons/daily-challenges/$userId",
        );
        debugPrint("Daily Challenge Response: ${challengeRes.body}");
        dailyChallenge = jsonDecode(challengeRes.body);
      } catch (e) {
        debugPrint("Failed to load daily challenge: $e");
      }

      for (var unit in units) {
        for (var lesson in unit['lessons']) {
          final lid = lesson['id'];
          try {
            final statusRes = await _apiService.get(
              "/lessons/lesson-status/$userId/$lid",
            );
            debugPrint("Lesson $lid status: ${statusRes.body}");
            lessonStatuses[lid] = jsonDecode(statusRes.body);
          } catch (e) {
            debugPrint("Lesson status fetch error (lesson $lid): $e");
            lessonStatuses[lid] = {"is_locked": false};
          }

          try {
            final progressRes = await _apiService.get(
              "/lessons/user-progress/$userId/$lid",
            );
            debugPrint("Lesson \$lid progress: ${progressRes.body}");
            lessonProgress[lid] = jsonDecode(progressRes.body);
          } catch (e) {
            debugPrint("Lesson progress fetch error (lesson $lid): $e");
            lessonProgress[lid] = {"progress": 0, "completed": false};
          }
        }
      }

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint('Home Load Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen(
        onComplete: (context) async {
          await _loadHomeData();
          Navigator.pushReplacementNamed(context, '/user');
        },
      );
    }

    if (hasError) {
      return const Center(
        child: Text('Failed to load. Check internet or try again.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    units
                        .asMap()
                        .entries
                        .map((entry) => _buildUnit(entry.value, entry.key))
                        .toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildDailyChallengeCard(),
                const SizedBox(height: 20),
                _buildHeartShopCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnit(Map unit, int unitIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          unit['title'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(
            unit['lessons'].length,
            (index) => _buildLessonCard(unit['lessons'][index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Map lesson, int index) {
    final isLocked = lessonStatuses[lesson['id']]?["is_locked"] ?? false;
    final progress = lessonProgress[lesson['id']]?["progress"] ?? 0;
    final color = lessonColors[index % lessonColors.length];

    return GestureDetector(
      onTap:
          isLocked
              ? null
              : () => Navigator.pushNamed(
                context,
                '/lesson',
                arguments: lesson['id'],
              ),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading:
                lesson['video_url'] != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        lesson['video_url'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                    : const Icon(Icons.image, color: Colors.white),
            title: Text(
              lesson['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (progress / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white30,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  "$progress% completed",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            trailing:
                isLocked ? const Icon(Icons.lock, color: Colors.white) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    if (dailyChallenge == null || dailyChallenge!.isEmpty) return Container();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/star_challenge.png',
              width: 80,
              height: 80,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.star, size: 60),
            ),
            const SizedBox(height: 12),
            const Text(
              "Daily Challenge",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/lesson', // 🔁 Change to '/daily-challenge' if needed
                    arguments: dailyChallenge!["id"],
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Start", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartShopCard() {
    return SizedBox(
      width: double.infinity, // take full width of right column
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(24), // wider padding
          child: Column(
            children: [
              Image.asset(
                'assets/images/shop_cart.png',
                width: 100,
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.shopping_cart, size: 60),
              ),
              const SizedBox(height: 16),
              const Text(
                "SenShop",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/heart-shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Buy More Hearts",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
