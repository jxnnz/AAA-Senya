import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/dashboards/flashcard_set_screen.dart';
import 'package:frontend/screens/dashboards/lessonScreen/lesson_screen.dart';
import 'package:frontend/screens/heart_shop.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboards/based_user_scaffold.dart';
import 'screens/dashboards/flashcard_screen.dart';
import 'screens/dashboards/home_screen.dart';
import 'screens/dashboards/practice_screen.dart';
import 'screens/dashboards/profile_screen.dart';
import 'themes/color.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin/admin_main.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/heart_shop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SENYA',
      theme: AppTheme.lightTheme,
      home: const LogoScreen(), // Always start here
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/flashcard': (context) => const FlashcardScreen(),
        '/practice': (context) => const PracticeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) => AdminMainScreen(),
        '/loading':
            (context) => LoadingScreen(
              onComplete: (BuildContext context) async {
                return;
              },
            ),
        '/heart-shop': (context) => HeartShop(isDialog: false, userId: 13),
        '/lesson': (context) => LessonModuleScreen(lessonId: 4155),
        '/flashcard-set': (context) {
          final lesson =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return FlashcardSetScreen(lesson: lesson);
        },
      },
    );
  }
}
