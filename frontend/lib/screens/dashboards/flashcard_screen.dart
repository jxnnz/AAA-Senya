import 'package:flutter/material.dart';
import '../../themes/color.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(6, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/flashcard-set');
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      AppColors.lessonColors[index %
                          AppColors.lessonColors.length],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Set ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
