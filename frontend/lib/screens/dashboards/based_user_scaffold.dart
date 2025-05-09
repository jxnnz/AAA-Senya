import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../themes/color.dart';
import '../../widgets/logout_dialog.dart';
import '../../auth/auth_util.dart';

class BaseUserScaffold extends StatefulWidget {
  final Widget child;
  const BaseUserScaffold({super.key, required this.child});

  @override
  State<BaseUserScaffold> createState() => _BaseUserScaffoldState();
}

class _BaseUserScaffoldState extends State<BaseUserScaffold> {
  bool _isSidebarExpanded = false;
  bool _isMobileSidebarOpen = false;

  final List<String> _routes = ['/home', '/flashcard', '/practice', '/profile'];

  final Map<String, String> _routeTitles = {
    '/home': 'Home',
    '/flashcard': 'Flashcard',
    '/practice': 'Practice',
    '/profile': 'Profile',
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
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
          Row(
            children: [
              if (isMobile)
                _isMobileSidebarOpen
                    ? _buildSidebar(context, isMobile)
                    : const SizedBox.shrink()
              else
                GestureDetector(
                  onTap: () {
                    if (!_isSidebarExpanded) {
                      setState(() => _isSidebarExpanded = true);
                    }
                  },
                  child: _buildSidebar(context, false),
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavBar(context) : null,
    );
  }

  Widget _buildSidebar(BuildContext context, bool isMobile) {
    final bool expanded = isMobile ? true : _isSidebarExpanded;
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isMobile ? 200 : (expanded ? 200 : 85),
      color: AppColors.primaryBlue,
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
          const SizedBox(height: 10),
          if (!isMobile && expanded)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () => setState(() => _isSidebarExpanded = false),
              ),
            ),
          const SizedBox(height: 20),
          _buildSidebarItem(
            context,
            Icons.home,
            'Home',
            '/home',
            currentRoute,
            expanded,
          ),
          _buildSidebarItem(
            context,
            Icons.menu_book,
            'Flashcard',
            '/flashcard',
            currentRoute,
            expanded,
          ),
          _buildSidebarItem(
            context,
            Icons.sports_esports,
            'Practice',
            '/practice',
            currentRoute,
            expanded,
          ),
          _buildSidebarItem(
            context,
            Icons.person,
            'Profile',
            '/profile',
            currentRoute,
            expanded,
          ),
          const Spacer(),
          _buildLogoutItem(context, expanded),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    String currentRoute,
    bool expanded,
  ) {
    final bool isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, route),
        child: Container(
          decoration:
              isSelected
                  ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      right: BorderSide(color: Colors.white),
                    ),
                  )
                  : null,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                size: 40,
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, bool expanded) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final shouldLogout = await showLogoutDialog(context);
          if (shouldLogout) {
            setState(() => _isSidebarExpanded = false);
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
              child: const Icon(
                Icons.logout,
                color: AppColors.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            if (expanded)
              const Text(
                "Logout",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService().getUserStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final status = snapshot.data!;
        return Container(
          height: 60,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _routeTitles[ModalRoute.of(context)?.settings.name] ?? 'Senya',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  _StatIcon(
                    icon: Icons.local_fire_department,
                    value: status['streak'],
                    color: AppColors.streakActive,
                  ),
                  const SizedBox(width: 16),
                  _StatIcon(
                    icon: Icons.favorite,
                    value: status['hearts'],
                    color: AppColors.heartRed,
                  ),
                  const SizedBox(width: 16),
                  _StatIcon(
                    icon: Icons.diamond,
                    value: status['rubies'],
                    color: AppColors.rubiesGold,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    int selectedIndex = _routes.indexOf(currentRoute);
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      onTap: (index) => Navigator.pushReplacementNamed(context, _routes[index]),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Flashcard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: 'Practice',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _StatIcon({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 5),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
