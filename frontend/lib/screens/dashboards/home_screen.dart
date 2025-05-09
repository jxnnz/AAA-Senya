import 'dart:convert';
import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../../services/api_service.dart';
import 'based_user_scaffold.dart';
import '../../screens/loading_screen.dart';
import '../../screens/dashboards/lessonScreen/lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> units = [];
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    userId = await _apiService.getUserId();
    if (!mounted) return;

    try {
      final res = await _apiService.get('/lessons/units/');
      if (!mounted) return;
      setState(() {
        units = List.from(jsonDecode(res.body));
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading home screen: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BaseUserScaffold(
      child:
          isLoading
              ? LoadingScreen(onComplete: (_) async {})
              : Padding(
                padding: const EdgeInsets.all(16),
                child:
                    isMobile
                        ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildMobileDailyCard(),
                              const SizedBox(height: 16),
                              ...units
                                  .map((unit) => _buildUnitSection(unit))
                                  .toList(),
                            ],
                          ),
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📚 Lessons Column
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    ...units
                                        .map((unit) => _buildUnitSection(unit))
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // 🔥 Sidebar Cards (Desktop Only)
                            Column(
                              children: [
                                _buildActionCard(
                                  icon: 'assets/images/daily-challenges.png',
                                  label: "Daily Challenge",
                                  height: 200,
                                  width: 200,
                                  onTap: () {
                                    // TODO: Navigate to daily challenge
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildActionCard(
                                  icon: 'assets/images/shop.png',
                                  label: "SenShop",
                                  height: 200,
                                  width: 200,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/heart-shop');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
              ),
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
    double height = 200,
    double width = 200,
  }) {
    final buttonText = label == "Daily Challenge" ? "Start" : "Shop";

    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setInnerState(() => isHovered = true),
          onExit: (_) => setInnerState(() => isHovered = false),
          child: AnimatedScale(
            scale: isHovered ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              elevation: 6,
              child: SizedBox(
                height: height,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticOut,
                              builder: (_, value, child) {
                                return Transform.scale(
                                  scale: 1 + (0.05 * value),
                                  child: child,
                                );
                              },
                              child: Image.asset(icon, width: 80, height: 80),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isHovered
                                  ? AppColors.softOrange
                                  : AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: onTap,
                          child: Center(
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileDailyCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildActionCard(
          icon: 'assets/images/daily-challenges.png',
          label: "Daily Challenge",
          height: 160,
          width: MediaQuery.of(context).size.width * 0.9,
          onTap: () {
            // TODO: Navigate to daily challenge
          },
        ),
      ),
    );
  }

  Widget _buildUnitSection(Map<String, dynamic> unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Divider(color: AppColors.primaryBlue, thickness: 5),
        const SizedBox(height: 12),
        Text(unit['title'], style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...List.generate(unit['lessons'].length, (index) {
          final lesson = unit['lessons'][index];
          return LessonCard(lesson: lesson, userId: userId!);
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
