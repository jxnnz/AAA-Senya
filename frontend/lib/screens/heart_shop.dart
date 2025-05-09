// 🛒 HeartShopWidget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/api_service.dart';
import '../../themes/color.dart';

class HeartShop extends StatefulWidget {
  final int userId;
  final bool isDialog;

  const HeartShop({super.key, required this.userId, this.isDialog = false});

  @override
  State<HeartShop> createState() => _HeartShopState();
}

class _HeartShopState extends State<HeartShop> {
  final ApiService _apiService = ApiService();
  List<dynamic> _packages = [];
  int _rubies = 0;
  int _hearts = 0;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final status = await _apiService.getUserProfile(widget.userId);
    final packages = await _apiService.getHeartPackages();
    if (mounted) {
      setState(() {
        _rubies = status['rubies'];
        _hearts = status['hearts'];
        _packages = packages;
        _loading = false;
      });
    }
  }

  Future<void> _purchase(int packageId) async {
    setState(() => _purchasing = true);
    final response = await _apiService.purchaseHearts(widget.userId, packageId);
    if (mounted) {
      setState(() {
        _rubies = response['rubies'];
        _hearts = response['hearts'];
        _purchasing = false;
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Purchase Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/lottie/confetti.json', repeat: false),
                const Text("Hearts added to your account!"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopContent =
        _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hearts: $_hearts ❤️",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Rubies: $_rubies 💎",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _packages.length,
                    itemBuilder: (_, i) {
                      final pkg = _packages[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${pkg['hearts_amount']} ❤️",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${pkg['ruby_cost']} 💎",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed:
                                    _purchasing
                                        ? null
                                        : () => _purchase(pkg['id']),
                                child: const Text("Buy"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );

    return widget.isDialog
        ? Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 400,
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: shopContent,
            ),
          ),
        )
        : Scaffold(
          appBar: AppBar(title: const Text("Heart Shop")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: shopContent,
          ),
        );
  }
}
