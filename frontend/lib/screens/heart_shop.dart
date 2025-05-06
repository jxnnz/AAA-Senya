// heart_shop.dart
import 'package:flutter/material.dart';
import '../themes/color.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import 'dart:convert';

class HeartShop extends StatefulWidget {
  final bool isDialog;
  final int userId;

  const HeartShop({super.key, required this.isDialog, required this.userId});

  @override
  State<HeartShop> createState() => _HeartShopState();
}

class _HeartShopState extends State<HeartShop> {
  late ConfettiController _confettiController;
  bool _isLoading = true;
  List<dynamic> _packages = [];
  int _rubies = 0;
  int _hearts = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final userRes = await api.get('/profile/${widget.userId}');
      final user = jsonDecode(userRes.body);

      final packages = await api.getHeartPackages();

      setState(() {
        _rubies = user['profile']['rubies'] ?? 0;
        _hearts = user['profile']['hearts'] ?? 0;
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load shop: $e')));
      }
    }
  }

  Future<void> _confirmPurchase(Map<String, dynamic> package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Purchase'),
            content: Text(
              'Buy ${package['hearts_amount']} hearts for ${package['ruby_cost']} rubies?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buy'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final api = ApiService();
        final result = await api.purchaseHearts(widget.userId, package['id']);
        setState(() {
          _rubies = result['rubies'];
          _hearts = result['hearts'];
        });
        _confettiController.play();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Purchase failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content =
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                // Header showing user balance
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.red[300]),
                      const SizedBox(width: 4),
                      Text(
                        '$_hearts',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset('assets/images/ruby.png', height: 24),
                      const SizedBox(width: 4),
                      Text(
                        '$_rubies',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: widget.isDialog ? 2 : 3,
                    padding: const EdgeInsets.all(16.0),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children:
                        _packages.map((pkg) {
                          return GestureDetector(
                            onTap: () => _confirmPurchase(pkg),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.pink[50],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 40,
                                  ).animate().scale(),
                                  const SizedBox(height: 8),
                                  Text(
                                    '+${pkg['hearts_amount']} Hearts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/ruby.png',
                                        height: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pkg['ruby_cost']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            );

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.isDialog
            ? Dialog(child: SizedBox(width: 300, height: 400, child: content))
            : Scaffold(
              appBar: AppBar(title: const Text('Heart Shop')),
              body: SafeArea(child: content),
            ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2,
          emissionFrequency: 0.08,
          numberOfParticles: 20,
          gravity: 0.4,
          shouldLoop: false,
        ),
      ],
    );
  }
}
