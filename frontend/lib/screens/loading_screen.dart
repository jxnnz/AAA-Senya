// loading_screen.dart
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../themes/color.dart';

class LoadingScreen extends StatefulWidget {
  final Future<void> Function(BuildContext context) onComplete;

  const LoadingScreen({super.key, required this.onComplete});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late String randomFact;

  final List<String> funFacts = const [
    "Filipino Sign Language is officially recognized by law in the Philippines!",
    "Your brain processes signs faster when paired with visual learning.",
    "Practicing daily improves retention by up to 80%.",
    "Fingerspelling helps boost your vocabulary.",
    "Even 5 minutes of practice a day makes a difference!",
    "The Deaf community values expressive signing—use those eyebrows!",
    "Sign language can be your superpower in accessibility advocacy!",
    "FSL isn’t just any sign language—it’s officially the national sign language of the Philippines!",
    "Forget spoken Filipino—FSL is its own thing, using hand movements, facial expressions, and even body language to tell a story!",
    "Even though ASL influenced it, FSL has grown into a totally unique sign language that reflects Filipino culture! 🤟",
    "There’s no “one sign language” for the whole world—there are over 400 different ones, and FSL is proudly one of them! 🌍",
    "FSL doesn’t just translate Filipino words—it paints pictures with signs, making it a super visual and expressive language! 🎨",
    "The Deaf community in the Philippines is full of talented storytellers who use FSL to bring stories to life with emotions and movement! 📖✨",
    "Want to be polite in Deaf culture? Keep eye contact—looking away while signing is like ignoring someone mid-conversation! 👀",
    "November is a big deal for the Deaf community—it’s Deaf Awareness Week, a time to celebrate, educate, and advocate for accessibility! 🎉",
    "Deaf Filipinos don’t just sign—they run businesses, host events, and build amazing social networks within their community! 💼",
    "FSL has some cool history—it even has signs influenced by Spanish words from way back in the day! 🇪🇸➡️🇵🇭",
  ];

  @override
  void initState() {
    super.initState();
    randomFact = funFacts[Random().nextInt(funFacts.length)];

    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        await widget.onComplete(context);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 5,
            ),
            const SizedBox(height: 24),
            Image.asset('assets/images/LOGO.png', width: 70, height: 70),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Fun Fact: $randomFact",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
