import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../dashboards/lessonScreen/learning_top_bar.dart';
import '../../dashboards/lessonScreen/video_section.dart';

class LessonModuleScreen extends StatefulWidget {
  final int lessonId;

  const LessonModuleScreen({super.key, required this.lessonId});

  @override
  State<LessonModuleScreen> createState() => _LessonModuleScreenState();
}

class _LessonModuleScreenState extends State<LessonModuleScreen> {
  int hearts = 3;
  List<Map<String, dynamic>> lessonContent = [];
  int currentIndex = 0;
  bool isLoading = true;
  double _videoSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    try {
      final quizData = await ApiService().fetchGeneratedQuiz(widget.lessonId);

      final List<Map<String, dynamic>> mergedContent = [];
      for (final item in quizData) {
        if (item['type'] == 'video_to_text') {
          mergedContent.add({
            "type": "sign",
            "word": item['correct_answer'],
            "videoUrl": item['video_url'],
          });
        }
        mergedContent.add(item);
      }

      setState(() {
        lessonContent = mergedContent;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching quiz: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showCongratsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "🎉 Congratulations!",
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "You’ve completed the lesson!",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/user',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Back to Home"),
              ),
            ],
          ),
    );
  }

  void handleNext() {
    if (currentIndex < lessonContent.length - 1) {
      setState(() => currentIndex++);
    } else {
      _showCongratsDialog();
    }
  }

  void handleSlowMotion() {
    setState(() {
      _videoSpeed = (_videoSpeed == 1.0) ? 0.5 : 1.0;
    });
  }

  void handleMirror() {
    print("Mirror pressed");
  }

  void checkAnswer(bool isCorrect) {
    if (!isCorrect) {
      setState(() {
        hearts = (hearts > 0) ? hearts - 1 : 0;
      });
    }

    Future.delayed(const Duration(seconds: 1), handleNext);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentItem = lessonContent[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Lesson ${widget.lessonId}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LearningTopBar(
              currentStep: currentIndex + 1,
              totalSteps: lessonContent.length,
              hearts: hearts,
            ),
            const SizedBox(height: 20),

            if (currentItem['type'] == 'sign')
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoSection(
                        videoUrl: currentItem['videoUrl'],
                        playbackSpeed: _videoSpeed,
                        onMirrorPressed: handleMirror,
                        onSlowMotionPressed: handleSlowMotion,
                        height: 240,
                      ),

                      const SizedBox(height: 24),
                      Text(
                        currentItem['word'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleNext,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildQuiz(currentItem),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(Map<String, dynamic> item) {
    bool isAnswered = false;
    String? selectedOption;
    final choices = item['choices'];
    if (choices == null || choices.isEmpty) {
      // Show message for 2 seconds, then auto-skip
      Future.delayed(const Duration(seconds: 2), handleNext);

      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Text(
          "No choices available. Skipping...",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Guess the sign",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // 🎞️ Video Section with null-safe check
                if (item['video_url'] != null &&
                    item['video_url'].toString().isNotEmpty)
                  VideoSection(
                    videoUrl: item['video_url'],
                    onMirrorPressed: null,
                    onSlowMotionPressed: null,
                    height: 240,
                  )
                else
                  Container(
                    height: 240,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black12,
                    ),
                    child: const Text(
                      "No video available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 24),

                // 🔘 Answer Options
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(item['choices'].length, (index) {
                    final option = item['choices'][index];
                    final isCorrect = option == item['correct_answer'];
                    final isSelected = option == selectedOption;

                    Color borderColor() {
                      if (!isAnswered) return Colors.orange;
                      if (isSelected && isCorrect) return Colors.green;
                      if (isSelected && !isCorrect) return Colors.red;
                      return Colors.orange;
                    }

                    return OutlinedButton(
                      onPressed:
                          isAnswered
                              ? null
                              : () {
                                setInnerState(() {
                                  selectedOption = option;
                                  isAnswered = true;
                                });
                                checkAnswer(isCorrect);
                              },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor(), width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
