import 'package:flutter/material.dart';
import "../dashboards/lessonScreen/lesson_screen.dart";
import '../../themes/color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarExpanded = false;
  bool _isMobileSidebarOpen = false;
  String _selectedMenu = "home";
  int streakCount = 10;
  int lives = 5;
  int rubies = 1000;
  bool isStreakActive = true;

  // Simulated Lesson Data
  final List<Map<String, dynamic>> units = [
    {
      "title": "UNIT 1",
      "subtitle": "The Basics",
      "lessons": [
        {
          "title": "Lesson 1",
          "subtitle": "Introduction",
          "image": "assets/lesson_images/hello_bubble.png",
          "progress": 0.6,
          "unlocked": true,
        },
        {
          "title": "Lesson 2",
          "subtitle": "Alphabet (A-M)",
          "image": "assets/lesson_images/abc.png",
          "progress": 0.0,
          "unlocked": true,
        },
        {
          "title": "Lesson 3",
          "subtitle": "Alphabet (N-Z)",
          "image": "assets/lesson_images/xyz.png",
          "progress": 0.0,
          "unlocked": true,
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Overlay to close sidebar
          if (_isSidebarExpanded || _isMobileSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarExpanded = false;
                  _isMobileSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black12,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Main layout
          Row(
            children: [
              // Sidebar
              if (isMobile)
                _isMobileSidebarOpen
                    ? _buildSidebar(isMobile: true)
                    : const SizedBox.shrink()
              else
                _buildSidebar(isMobile: false),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Top app bar with stats
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildAppBarIcon(
                            Icons.local_fire_department,
                            streakCount,
                            Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          _buildAppBarIcon(Icons.favorite, lives, Colors.red),
                          const SizedBox(width: 16),
                          _buildAppBarIcon(Icons.diamond, rubies, Colors.pink),
                        ],
                      ),
                    ),

                    // Main content area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - lessons
                            Expanded(
                              flex: 2,
                              child: ListView(
                                children:
                                    units
                                        .map((unit) => _buildUnitSection(unit))
                                        .toList(),
                              ),
                            ),

                            // Right side - challenges and shop
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  children: [
                                    _buildDailyChallenge(),
                                    const SizedBox(height: 16),
                                    _buildSenShop(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Toggle button for mobile
          if (isMobile && !_isMobileSidebarOpen)
            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.orange),
                onPressed: () => setState(() => _isMobileSidebarOpen = true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isMobile = false}) {
    return Container(
      width: 85,
      color: Colors.orange,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 40),

          // Navigation items
          _buildSidebarItem("home", Icons.home, "Home", isSelected: true),
          _buildSidebarItem("flashcard", Icons.menu_book, "Flashcards"),
          _buildSidebarItem("practice", Icons.sports_esports, "Practice"),
          _buildSidebarItem("profile", Icons.person, "Profile"),

          const Spacer(),

          // Logout button
          Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.logout, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String menu,
    IconData icon,
    String label, {
    bool isSelected = false,
    bool isMobile = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUnitSection(Map<String, dynamic> unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit["title"],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(unit["subtitle"], style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ...unit["lessons"].map<Widget>((lesson) {
          return _buildLessonCard(lesson);
        }).toList(),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    Color cardColor;
    if (lesson["title"] == "Lesson 1") {
      cardColor = const Color(0xFF2E3A59);
    } else if (lesson["title"] == "Lesson 2") {
      cardColor = const Color(0xFFB5B6C8);
    } else {
      cardColor = const Color(0xFFB5B6C8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson["title"],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      lesson["subtitle"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  lesson["image"],
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Completed ${(lesson["progress"] * 100).toInt()}%",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: lesson["progress"],
                backgroundColor: Colors.white24,
                color: Colors.orange,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Daily Challenge",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(120, 36),
            ),
            child: const Text("Start", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSenShop() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "SenShop",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.shopping_cart, color: Colors.red, size: 40),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(120, 36),
            ),
            child: const Text("Buy", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
