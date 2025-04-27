import 'package:flutter/material.dart';
import '../../dashboards/lessonScreen/learning_top_bar.dart';
import '../../dashboards/lessonScreen/video_section.dart';

class LessonModuleScreen extends StatefulWidget {
  final int lessonId;

  const LessonModuleScreen({super.key, required this.lessonId});

  @override
  State<LessonModuleScreen> createState() => _LessonModuleScreenState();
}

class _LessonModuleScreenState extends State<LessonModuleScreen> {
  int currentStep = 1;
  int totalSteps = 10;
  int hearts = 3;

  bool isQuiz = false; // toggle between sign/quiz
  String currentWord = "Hearing"; // will be dynamic later

  List<Map<String, dynamic>> lessonContent = [];
  int currentIndex = 0;
  bool isLoading = true;

  void handleNext() {
    setState(() {
      if (isQuiz) {
        currentStep++;
      }
      isQuiz = !isQuiz;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API call

    setState(() {
      lessonContent = [
        {
          "type": "sign",
          "word": "Hearing",
          "videoUrl": "assets/videos/hearing.mp4",
        },
        {
          "type": "quiz",
          "question": "What is the sign for 'Hearing'?",
          "options": ["Seeing", "Hearing", "Feeling", "Touch"],
          "answer": "Hearing",
        },
        {
          "type": "sign",
          "word": "Seeing",
          "videoUrl": "assets/videos/seeing.mp4",
        },
        {
          "type": "quiz",
          "question": "Which of these means 'Seeing'?",
          "options": ["Looking", "Listening", "Hearing", "Seeing"],
          "answer": "Seeing",
        },
      ];
      isLoading = false;
    });
  }

  void handleSlowMotion() {
    // TODO: slow down video playback
    print("Slow motion pressed");
  }

  void handleMirror() {
    // TODO: open camera for mirror
    print("Mirror pressed");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentItem = lessonContent[currentIndex];
    final isQuiz = currentItem['type'] == 'quiz';

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
            SizedBox(height: 20),

            if (currentItem['type'] == 'sign')
              VideoSection(
                onSlowMotionPressed: handleSlowMotion,
                onMirrorPressed: handleMirror,
              )
            else
              _buildQuiz(currentItem), // implement this next

            SizedBox(height: 20),
            if (currentItem['type'] == 'sign')
              Text(
                currentItem['word'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleNext,
                child: Text(isQuiz ? "Check" : "Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['question'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...List.generate(item['options'].length, (index) {
          final option = item['options'][index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () {
                // You can check if it's correct here later
              },
              child: Text(option),
            ),
          );
        }),
      ],
    );
  }
}
