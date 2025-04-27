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
  int streakCount = 5;
  int lives = 3;
  int rubies = 120;
  bool isStreakActive = true; // This should be updated based on login time

  // Simulated Lesson Data (Replace this with data from Supabase)
  // TODO: Replace `units` list with Supabase data retrieval.
  // Fetch units and lessons dynamically and map them accordingly.
  final List<Map<String, dynamic>> units = [
    {
      "title": "Unit 1: Basics",
      "lessons": [
        {
          "title": "Lesson 1",
          "image": "assets/lesson_images/lesson-alpha1.png",
          "progress": 0.5,
          "unlocked": true,
        },
        {
          "title": "Lesson 2",
          "image": "assets/lesson_images/lesson-alpha2.png",
          "progress": 0.2,
          "unlocked": true,
        },
        {
          "title": "Lesson 3",
          "image": "assets/lesson_images/lesson-introduction.png",
          "progress": 0.0,
          "unlocked": false,
        },
      ],
    },
    {
      "title": "Unit 2: Intermediate",
      "lessons": [
        {
          "title": "Lesson 1",
          "image": "assets/lesson_images/lesson-num1.png",
          "progress": 0.0,
          "unlocked": false,
        },
        {
          "title": "Lesson 2",
          "image": "assets/lesson_images/lesson-num2.png",
          "progress": 0.0,
          "unlocked": false,
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
          // ------------------- OVERLAY TO CLOSE SIDEBAR -------------------
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

          // ------------------- SIDEBAR -------------------
          Row(
            children: [
              if (isMobile)
                _isMobileSidebarOpen
                    ? _buildSidebar(isMobile: true)
                    : const SizedBox.shrink()
              else
                GestureDetector(
                  onTap: () {
                    if (!_isSidebarExpanded) {
                      setState(() => _isSidebarExpanded = true);
                    }
                  },
                  child: _buildSidebar(isMobile: false),
                ),
              // ------------------- MAIN CONTENT -------------------
              Expanded(
                child: Column(
                  children: [
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
                            isStreakActive
                                ? AppColors.streakActive
                                : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          _buildAppBarIcon(
                            Icons.favorite,
                            lives,
                            AppColors.heart,
                          ),
                          const SizedBox(width: 16),
                          _buildAppBarIcon(
                            Icons.diamond,
                            rubies,
                            AppColors.heart,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children:
                              units
                                  .map((unit) => _buildUnitSection(unit))
                                  .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // ------------------- TOGGLE BUTTON FOR MOBILE -------------------
          if (isMobile && !_isMobileSidebarOpen)
            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primaryColor),
                onPressed: () => setState(() => _isMobileSidebarOpen = true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isMobile = false}) {
    final bool expanded = isMobile ? true : _isSidebarExpanded;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isMobile ? 200 : (expanded ? 200 : 85),
      color: AppColors.primaryColor,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _isMobileSidebarOpen = false),
            ),
          Center(
            child: Image.asset(
              'assets/images/LOGO.png',
              width: expanded ? 120 : 50,
            ),
          ),
          const SizedBox(height: 20),
          _buildSidebarItem("home", Icons.home, "Home", isMobile: isMobile),
          _buildSidebarItem(
            "flashcard",
            Icons.menu_book,
            "Flashcard",
            isMobile: isMobile,
          ),
          _buildSidebarItem(
            "practice",
            Icons.sports_esports,
            "Practice",
            isMobile: isMobile,
          ),
          _buildSidebarItem(
            "profile",
            Icons.person,
            "Profile",
            isMobile: isMobile,
          ),
          const Spacer(),
          Center(
            child: GestureDetector(
              onTap: _logout,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout,
                      color: AppColors.selectedColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: AppColors.selectedColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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
    bool isMobile = false,
  }) {
    bool isSelected = _selectedMenu == menu;
    bool expanded = isMobile || _isSidebarExpanded;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedMenu = menu);
          // Navigate based on menu selection
          if (menu == 'home') {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (menu == 'flashcard') {
            Navigator.pushReplacementNamed(context, '/flashcard');
          } else if (menu == 'practice') {
            Navigator.pushReplacementNamed(context, '/practice');
          } else if (menu == 'profile') {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        child: Container(
          decoration:
              isSelected
                  ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      right: BorderSide(color: Colors.white, width: 5),
                    ),
                  )
                  : null,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? AppColors.selectedColor
                        : AppColors.unselectedColor,
                size: 40,
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          isSelected
                              ? AppColors.selectedColor
                              : AppColors.unselectedColor,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSection(Map<String, dynamic> unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit["title"],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children:
              unit["lessons"].map<Widget>((lesson) {
                final index = unit["lessons"].indexOf(lesson);
                final color =
                    lesson["unlocked"]
                        ? AppColors.lessonColors[index %
                            AppColors.lessonColors.length]
                        : Colors.grey;
                return _buildLessonCard(lesson, color);
              }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LessonModuleScreen(
                    lessonId: 1,
                  ), // pass correct ID dynamically
            ),
          );
        },
        child: Container(
          height: 100, // Adjustable height
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lesson["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Completed ${(lesson["progress"] * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: lesson["progress"],
                      backgroundColor: Colors.white54,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Image.asset(
                lesson["image"],
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildAppBarIcon(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
