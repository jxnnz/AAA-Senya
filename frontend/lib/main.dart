import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/heart_shop.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/color.dart';
import 'screens/dashboards/user_main.dart';
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
      theme: ThemeData(primaryColor: AppColors.primaryColor),
      home: const LogoScreen(), // Always start here
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user': (context) => UserMainScreen(),
        '/admin': (context) => AdminMainScreen(),
        '/loading':
            (context) => LoadingScreen(
              onComplete: (BuildContext context) async {
                return;
              },
            ),
        /*'/heart-shop':
            (context) => HeartShop(isDialog: true, userId: l,),*/
      },
    );
  }
}
