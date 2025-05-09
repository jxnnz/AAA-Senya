import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../themes/color.dart';
import '../../../services/api_service.dart';

class LessonCard extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final int userId;

  const LessonCard({super.key, required this.lesson, required this.userId});

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool isLocked = false;
  int progress = 0;
  bool isLoading = true;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadLessonStatus();
  }

  Future<void> _loadLessonStatus() async {
    final lessonId = widget.lesson['id'];

    try {
      final res = await _apiService.get(
        '/lessons/lesson-status/${widget.userId}/$lessonId',
      );
      final progressRes = await _apiService.get(
        '/lessons/lesson-progress/${widget.userId}/$lessonId',
      );

      if (!mounted) return;
      setState(() {
        isLocked = jsonDecode(res.body)['is_locked'];
        progress = jsonDecode(progressRes.body)['progress'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading lesson status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? '';
    final imageUrl = widget.lesson['image_url'];
    final lessonNumber = (widget.lesson['order_index'] ?? 0) + 1;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showLockDialog(context);
        } else {
          // TODO: Navigate to lesson detail screen
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.softOrange,
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // 📸 Lesson Image
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.network(
                      'http://localhost:8000$imageUrl',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, _, __) => const SizedBox(height: 150),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 📊 Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Completed $progress%",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            backgroundColor: AppColors.lightBlue.withOpacity(
                              0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🔒 Lock Overlay
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, size: 50, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 60, color: Colors.orange),
                const SizedBox(height: 12),
                const Text(
                  "Lesson Lock",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sorry, you cannot access the lesson.\nFinish current lesson to get access.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
    );
  }
}
