import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../../auth/auth_util.dart';
import '../../widgets/logout_dialog.dart';
import 'admin_units.dart';
import 'admin_lessons.dart';
import 'admin_signs.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminUnitsTab(),
    AdminLessonsTab(),
    AdminSignsTab(),
  ];

  final List<String> _titles = ['Units', 'Lessons', 'Signs'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Collapsed Sidebar
          Container(
            width: 85,
            color: AppColors.primaryColor,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/images/LOGO.png', width: 50)),
                const SizedBox(height: 20),
                _buildSidebarItem(0, Icons.view_module, 'Units'),
                _buildSidebarItem(1, Icons.school, 'Lessons'),
                _buildSidebarItem(2, Icons.video_library, 'Signs'),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout) {
                      await logout(context);
                    }
                  },
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(_titles[_selectedIndex]),
                  elevation: 1,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(10),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.selectedColor
                      : AppColors.unselectedColor,
              size: 35,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isSelected
                        ? AppColors.selectedColor
                        : AppColors.unselectedColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
