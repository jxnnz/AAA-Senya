import 'package:flutter/material.dart';

class LearningTopBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final int hearts;

  const LearningTopBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.hearts,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress Bar - Centered
          Expanded(
            child: Column(
              children: [
                Text(
                  '$currentStep / $totalSteps',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Heart Count - Right
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.redAccent),
                SizedBox(width: 4),
                Text(
                  'x$hearts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
