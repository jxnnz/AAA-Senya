import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../dashboards/based_user_scaffold.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseUserScaffold(
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildPracticeCard(
              context,
              title: "Game Mode",
              iconPath: "assets/images/game.png",
              onTap: () => Navigator.pushNamed(context, '/gamemode'),
              color: const Color(0xFF83B100),
              width: 600,
              height: 600,
            ),
            _buildPracticeCard(
              context,
              title: "Fingerspelling",
              iconPath: "assets/images/fingerspelling.png",
              onTap: () => Navigator.pushNamed(context, '/fingerspelling'),
              color: const Color(0xFF2C3F6D),
              width: 600,
              height: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    required Color color,
    double width = 250,
    double height = 200,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 400),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
