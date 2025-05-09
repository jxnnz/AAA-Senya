// 📁 flashcard_set_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../services/api_service.dart';
import '../../themes/color.dart';

class FlashcardSetScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  const FlashcardSetScreen({super.key, required this.lesson});

  @override
  State<FlashcardSetScreen> createState() => _FlashcardSetScreenState();
}

class _FlashcardSetScreenState extends State<FlashcardSetScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> signs = [];
  List<Map<String, dynamic>> reviewPool = [];
  Map<int, bool> learnedMap = {};
  List<Map<String, dynamic>> learnedStats = [];

  late VideoPlayerController _controller;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late PageController _pageController;
  late ConfettiController _confettiController;

  bool isFlipped = false;
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
    _pageController = PageController();
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          !isFlipped &&
          !_controller.value.isPlaying) {
        _controller.play();
      }
    });
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    final response = await _apiService.get('/lessons/${widget.lesson['id']}');
    final data = jsonDecode(response.body);

    final List<Map<String, dynamic>> loadedSigns =
        List<Map<String, dynamic>>.from(data['signs']);

    loadedSigns.shuffle(Random());
    signs = [...loadedSigns];
    reviewPool = [...loadedSigns];
    for (var sign in loadedSigns) {
      learnedMap[sign['id']] = false;
    }

    _initializeVideo(reviewPool[0]['video_url']);
  }

  void _initializeVideo(String url) {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(url))
          ..setLooping(true)
          ..setVolume(0.0)
          ..initialize().then((_) {
            setState(() => isLoading = false);
            if (!isFlipped) _controller.play();
          });
  }

  void _nextCard() async {
    await _flipController.reverse();
    setState(() => isFlipped = false);

    if (reviewPool.isNotEmpty) {
      setState(() {
        currentIndex = (currentIndex + 1) % reviewPool.length;
        _controller.dispose();
        _initializeVideo(reviewPool[currentIndex]['video_url']);
      });
    }
  }

  void _markLearned(bool learned) {
    final currentSign = reviewPool[currentIndex];
    learnedMap[currentSign['id']] = learned;

    learnedStats.add({
      'sign_id': currentSign['id'],
      'text': currentSign['text'],
      'status': learned ? 'learned' : 'still_learning',
    });

    setState(() {
      final removed = reviewPool.removeAt(currentIndex);
      if (!learned) {
        reviewPool.add(removed);
      }

      if (reviewPool.isEmpty) {
        _saveReviewStats();
        _showCongratsDialog();
        return;
      }

      currentIndex = currentIndex % reviewPool.length;
      _controller.dispose();
      _initializeVideo(reviewPool[currentIndex]['video_url']);
      isFlipped = false;
      _flipController.reset();
    });
  }

  Future<void> _saveReviewStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'flashcard_stats_lesson_${widget.lesson['id']}',
      jsonEncode(learnedStats),
    );
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _confettiController.play();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(context, '/user', (route) => false);
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎉 Congratulations!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You have mastered all the signs in this lesson!',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _flipController.dispose();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleFlip() {
    setState(() => isFlipped = !isFlipped);
    if (isFlipped) {
      _flipController.forward();
      _controller.pause();
    } else {
      _flipController.reverse();
    }
  }

  Widget _buildFlashcard(bool isBack, String text) {
    return Center(
      child: SizedBox(
        width: 800,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side:
                isBack
                    ? BorderSide.none
                    : BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          color: isBack ? AppColors.primaryBlue : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child:
                  isBack
                      ? Center(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : _controller.value.isInitialized
                      ? AbsorbPointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: VideoPlayer(_controller),
                        ),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSign =
        reviewPool.isNotEmpty ? reviewPool[currentIndex] : signs[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accentOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lesson['title'],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final isUnder = (_flipAnimation.value >= 0.5);
                          final transform = Matrix4.rotationY(
                            _flipAnimation.value * 3.14,
                          );
                          return GestureDetector(
                            onTap: _handleFlip,
                            child: Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child:
                                  isUnder
                                      ? Transform(
                                        transform: Matrix4.rotationY(3.14),
                                        alignment: Alignment.center,
                                        child: _buildFlashcard(
                                          true,
                                          currentSign['text'],
                                        ),
                                      )
                                      : _buildFlashcard(false, ''),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, size: 24),
                          label: const Text('Still Learning'),
                          onPressed: () => _markLearned(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle, size: 24),
                          label: const Text('Got it'),
                          onPressed: () => _markLearned(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
