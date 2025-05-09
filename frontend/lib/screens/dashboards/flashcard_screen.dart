import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../themes/color.dart';
import '../dashboards/based_user_scaffold.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final ApiService _apiService = ApiService();
  int? userId;
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    userId = await _apiService.getUserId();
    final List<Map<String, dynamic>> tempLessons = [];

    final response = await _apiService.get('/lessons/units/');
    final units = jsonDecode(response.body);

    for (var unit in units) {
      for (var lesson in unit['lessons']) {
        final statusRes = await _apiService.get(
          '/lessons/lesson-status/$userId/${lesson['id']}',
        );
        final statusData = jsonDecode(statusRes.body);
        tempLessons.add({
          'id': lesson['id'],
          'title': lesson['title'],
          'isLocked': statusData['is_locked'],
        });
      }
    }

    setState(() {
      lessons = tempLessons;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;
    final double lockIconSize = isWide ? 60 : 40;
    final double fontSize = isWide ? 32 : 18;

    return BaseUserScaffold(
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  crossAxisSpacing: 36,
                  mainAxisSpacing: 36,
                  children:
                      lessons.map((lesson) {
                        final isLocked = lesson['isLocked'];
                        return GestureDetector(
                          onTap:
                              isLocked
                                  ? null
                                  : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/flashcard-set',
                                      arguments: lesson,
                                    );
                                  },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isLocked
                                      ? AppColors.lockedGray.withOpacity(0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.accentOrange,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child:
                                  isLocked
                                      ? Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                        size: lockIconSize,
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          lesson['title'],
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
