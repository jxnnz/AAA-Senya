// unit_progress_screen.dart
import 'package:flutter/material.dart';
import '../../themes/color.dart';

class UnitProgressScreen extends StatelessWidget {
  final List<Map<String, dynamic>> unitProgress;

  const UnitProgressScreen({super.key, required this.unitProgress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Your Progress"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unitProgress.length,
        itemBuilder: (context, index) {
          final unit = unitProgress[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(unit['name']),
              subtitle: LinearProgressIndicator(
                value: unit['progress'] / 100,
                backgroundColor: Colors.grey[300],
                color: AppColors.accentOrange,
              ),
              trailing: Text('${unit['progress'].toStringAsFixed(0)}%'),
              children: [
                ...unit['lessons'].map<Widget>((lesson) {
                  return ListTile(
                    title: Text(lesson['title']),
                    subtitle: LinearProgressIndicator(
                      value: ['A', 'B', 'C', 'D'].indexOf(lesson['grade']) / 4,
                      backgroundColor: Colors.grey[300],
                      color: AppColors.accentOrange,
                    ),
                    trailing: Text('Mistake: ${lesson['grade']}'),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
