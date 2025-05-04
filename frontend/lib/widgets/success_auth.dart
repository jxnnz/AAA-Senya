import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SuccessDialog extends StatefulWidget {
  final String imagePath;
  final String title;
  final String message;
  final VoidCallback onPressed;

  const SuccessDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.message,
    required this.onPressed,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _jumpAnimation;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _jumpAnimation = Tween<double>(
      begin: 0,
      end: -20,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _controller.forward();
    _confettiController.play();

    // Automatically trigger onPressed after 2.5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
        widget.onPressed(); // Trigger navigation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _jumpAnimation,
                  builder:
                      (_, __) => Transform.translate(
                        offset: Offset(0, _jumpAnimation.value),
                        child: Image.asset(widget.imagePath, height: 100),
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 🎉 Confetti
          Positioned(
            top: 10,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
