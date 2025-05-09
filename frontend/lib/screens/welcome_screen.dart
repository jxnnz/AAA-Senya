import 'package:flutter/material.dart';
import '../themes/color.dart'; // Import your color.dart file

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size to determine responsiveness
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600; // Adjust breakpoint if needed

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryBlue, // Use color from color.dart
        elevation: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0), // 🧭 Adjust as needed
              child: Image.asset(
                'assets/images/logo.png',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SENYA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/login',
                  ), // Update login route if needed
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // Keep button background as white
                foregroundColor: Colors.black, // Keep text color as black
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Adjust corner radius
                ),
              ),
              child: const Text(
                'Log In', // Edit button text if needed
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Adjust padding if needed
          child:
              isMobile
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/welcome.png', // Update image path
                        width:
                            screenSize.width *
                            0.8, // Adjust image size dynamically
                      ),
                      const SizedBox(height: 20),
                      _buildTextSection(context, isMobile), // Call text section
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:
                            screenSize.width *
                            0.4, // Adjust image width for larger screens
                        child: Image.asset(
                          'assets/images/welcome.png',
                          width: screenSize.width * 0.4,
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ), // Adjust spacing between image & text
                      SizedBox(
                        width:
                            screenSize.width * 0.4, // Adjust text section width
                        child: _buildTextSection(context, isMobile),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  // Widget for the text section (Title + Button)
  Widget _buildTextSection(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        RichText(
          textAlign:
              isMobile ? TextAlign.center : TextAlign.left, // Adjust alignment
          text: const TextSpan(
            style: TextStyle(
              fontSize: 32, // Adjust text size for smaller screens
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter', // Change font if needed
              color: Colors.black,
            ),
            children: [
              TextSpan(text: 'Learn FSL in a fun and interactive way with '),
              TextSpan(
                text: 'SENYA',
                style: TextStyle(
                  color:
                      AppColors
                          .accentOrange, // Use primaryColor from color.dart
                ), // Customize "SENYA" color
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: isMobile ? Alignment.center : Alignment.centerLeft,
          child: ElevatedButton(
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  '/signup',
                ), // Update signup route if needed
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.accentOrange, // Use color from color.dart
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ), // Adjust button rounding
              ),
            ),
            child: Text(
              'Get Started', // Edit button text if needed
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ), // Adjust text color
            ),
          ),
        ),
      ],
    );
  }
}
