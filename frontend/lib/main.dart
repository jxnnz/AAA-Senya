import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/color.dart';
import 'api_routes/auth-repository.dart';
import 'screens/dashboards/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin/admin_main.dart';
import "screens/login_screen.dart";
import 'screens/signup_screen.dart';
/*import 'screens/dashboard/flashcard_screen.dart';
import 'package:senya_fsl/widgets/game_mode_level.dart';
import 'screens/dashboard/home_screen.dart';
import 'screens/forgotpassword_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/dashboard/practice_screen.dart';
import 'screens/dashboard/profile_screen.dart';

import 'screens/dashboard/lesson_screen.dart';
import 'widgets/flashcard_set_screen.dart';*/

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _authRepository = AuthRepository();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SENYA',
      theme: ThemeData(primaryColor: AppColors.primaryColor),
      // IMPORTANT: Always start with LogoScreen
      home: const LogoScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/admin': (context) => AdminMainScreen(),
      },
    );
  }
}
