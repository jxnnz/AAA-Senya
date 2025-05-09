import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../dashboards/based_user_scaffold.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../../services/api_service.dart';
import '../../widgets/unit_progress_screen.dart';
import '../../widgets/user_progress_dashboard.dart';
import '../../widgets/unit_detail_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String avatarUrl = '';
  String displayName = '';
  String username = '';
  String email = '';
  int rubies = 0;
  int hearts = 0;
  int streak = 0;
  Duration heartCountdown = const Duration(minutes: 10);
  bool isEdited = false;
  int userId = 0;
  bool isLoading = true;

  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> unitProgress = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id') ?? 0;
    if (userId == 0) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final res = await _apiService.get('/profile/$userId');
    if (!mounted) return;
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        displayName = data['account']['name'] ?? '';
        username = data['account']['username'] ?? '';
        email = data['account']['email'] ?? '';
        rubies = data['profile']['rubies'] ?? 0;
        hearts = data['profile']['hearts'] ?? 0;
        streak = data['profile']['streak'] ?? 0;
        avatarUrl =
            data['profile']['profile_url'] ?? 'https://via.placeholder.com/150';
        if (hearts < 5) startHeartTimer();
      });
      await _loadProgress();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadProgress() async {
    final unitRes = await _apiService.get('/lessons/units-with-lesson-signs/');
    if (!mounted) return;
    if (unitRes.statusCode == 200) {
      final List units = json.decode(unitRes.body);
      List<Map<String, dynamic>> loadedUnits = [];
      for (final unit in units) {
        loadedUnits.add({
          'id': unit['id'],
          'name': unit['title'],
          'progress': (unit['lessons'].length * 10).toDouble(),
          'lessons':
              unit['lessons']
                  .map(
                    (lesson) => {
                      'id': lesson['id'],
                      'title': lesson['title'],
                      'grade': ['A', 'B', 'C', 'D'][lesson['id'] % 4],
                    },
                  )
                  .toList(),
        });
      }
      setState(() {
        unitProgress = loadedUnits;
        isLoading = false;
      });
    }
  }

  void openUnitDetail(Map<String, dynamic> unit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnitDetailWidget(unit: unit)),
    );
  }

  void openOverallProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProgressDashboard()),
    );
  }

  void startHeartTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || hearts >= 5) {
        timer.cancel();
      } else {
        setState(() {
          heartCountdown = heartCountdown - const Duration(seconds: 1);
        });
      }
    });
  }

  void showEditDialog() async {
    String newName = displayName;
    String newUsername = username;
    html.File? selectedFile;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: SizedBox(
                  width: 500,
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                            TextButton(
                              onPressed: () async {
                                html.FileUploadInputElement uploadInput =
                                    html.FileUploadInputElement();
                                uploadInput.accept = 'image/*';
                                uploadInput.click();
                                uploadInput.onChange.listen((event) {
                                  final files = uploadInput.files;
                                  if (files != null && files.isNotEmpty) {
                                    final file = files.first;
                                    final reader = html.FileReader();
                                    reader.readAsDataUrl(file);
                                    reader.onLoadEnd.listen((_) {
                                      final imageUrl = reader.result as String;
                                      setDialogState(() {
                                        selectedFile = file;
                                        avatarUrl = imageUrl;
                                      });
                                    });
                                  }
                                });
                              },
                              child: const Text(
                                "Change Photo",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Name:'),
                          controller: TextEditingController(text: newName),
                          onChanged: (val) => newName = val,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Username:',
                          ),
                          controller: TextEditingController(text: newUsername),
                          onChanged: (val) => newUsername = val,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          controller: TextEditingController(text: email),
                          decoration: const InputDecoration(
                            labelText: 'Email:',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isEdited)
                          const Text(
                            "⚠️ You can only edit your username once.",
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                          ),
                          onPressed: () async {
                            setState(() {
                              displayName = newName;
                              username = newUsername;
                              isEdited = true;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Save Changes"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseUserScaffold(
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: showEditDialog,
                                icon: const Icon(Icons.edit, size: 30),
                              ),
                            ],
                          ),
                          Text(
                            '@$username',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCard('Rubies', '$rubies', Icons.diamond),
                      _statCard('Hearts', '$hearts', Icons.favorite),
                      _statCard(
                        'Streak',
                        '$streak',
                        Icons.local_fire_department,
                      ),
                    ],
                  ),
                  if (hearts < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Next heart in: ${heartCountdown.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(heartCountdown.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: openOverallProgress,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(value: 0.7),
                            SizedBox(height: 4),
                            Text('70% completed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unit Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...unitProgress.map(
                    (unit) => GestureDetector(
                      onTap: () => openUnitDetail(unit),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(unit['name']),
                          subtitle: LinearProgressIndicator(
                            value: unit['progress'] / 100,
                            backgroundColor: Colors.grey[300],
                            color: AppColors.primaryBlue,
                          ),
                          trailing: Text(
                            '${unit['progress'].toStringAsFixed(0)}%',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color:
                        unitProgress.every((u) => u['progress'] == 100)
                            ? Colors.white
                            : Colors.grey[300],
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events),
                      title: const Text('Certificate'),
                      subtitle: Text(
                        unitProgress.every((u) => u['progress'] == 100)
                            ? 'Ready to download'
                            : 'Complete all units to unlock',
                      ),
                      trailing:
                          unitProgress.every((u) => u['progress'] == 100)
                              ? ElevatedButton(
                                onPressed: () {},
                                child: const Text('Generate'),
                              )
                              : const Icon(Icons.lock_outline),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    final lowerLabel = label.toLowerCase();
    final bool isHeart = lowerLabel.contains("heart");
    final bool isStreak = lowerLabel.contains("streak");
    final bool isRuby =
        lowerLabel.contains("rubies") || lowerLabel.contains("ruby");

    Color iconColor = AppColors.primaryBlue;
    if (isHeart) iconColor = AppColors.heartRed;
    if (isRuby) iconColor = Colors.red[800]!;
    if (isStreak) {
      final streakValue = int.tryParse(value) ?? 0;
      iconColor =
          streakValue > 0 ? AppColors.streakActive : AppColors.streakInactive;
    }

    return SizedBox(
      width: 210,
      height: 200,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 50),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 35),
                textAlign: TextAlign.center,
              ),
              if (isHeart)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/heart-shop'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      backgroundColor: AppColors.accentOrange,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "SenShop",
                      style: TextStyle(fontSize: 20, color: AppColors.text),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
