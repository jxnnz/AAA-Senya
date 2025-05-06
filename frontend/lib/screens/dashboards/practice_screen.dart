import 'package:flutter/material.dart';
import '../../themes/color.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildPracticeCard(
              title: "Game Mode",
              iconPath: "assets/images/game.png",
              onTap: () {
                Navigator.pushNamed(context, '/gamemode');
              },
              color: const Color(0xFF83B100),
              width: 600,
              height: 600,
            ),
            _buildPracticeCard(
              title: "Fingerspelling",
              iconPath: "assets/images/fingerspelling.png",
              onTap: () {
                Navigator.pushNamed(context, '/fingerspelling');
              },
              color: const Color(0xFF2C3F6D),
              width: 600,
              height: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard({
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
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
