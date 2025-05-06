import 'package:flutter/material.dart';
import '../../themes/color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage(
                    'assets/images/avatar_default.png',
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SEN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@senya', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('❤️', '3', 'Hearts', actionLabel: 'BUY'),
                _buildStatCard('💎', '240', 'Rubies'),
                _buildStatCard('🔥', '5', 'Streak'),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              'Overall Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.6,
              minHeight: 12,
              color: AppColors.primaryColor,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 30),

            const Text(
              'Lesson Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildLessonProgress('Lesson 1', 0.9),
            _buildLessonProgress('Lesson 2', 0.7),
            _buildLessonProgress('Lesson 3', 0.4),
            _buildLessonProgress('Lesson 4', 0.0),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock, size: 40, color: Colors.grey),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Complete the course to unlock your certificate!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Logout only on mobile view
            if (isMobile) ...[
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.logout,
                        color: AppColors.selectedColor,
                        size: 20,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String emoji,
    String value,
    String label, {
    String? actionLabel,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
            if (actionLabel != null)
              TextButton(onPressed: () {}, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonProgress(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          color: AppColors.primaryColor,
          backgroundColor: Colors.grey[300],
          minHeight: 10,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
