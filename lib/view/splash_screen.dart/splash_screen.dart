import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/view/home_page/home_page.dart';
import 'package:cooklkeme_createx_project/onboard_screen/onboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool seenOnboarding;
  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    print(  widget.seenOnboarding);
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              widget.seenOnboarding ? HomeScreen() : OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: splashScreenColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/icon.png",
              height: width * .45,
            ),
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE7242C), Color(0xFFFF8F1D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: const Text(
                  "cookLkeme",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.02 * 32, // 2% of font size
                    fontFamily: "SF Pro Rounded",
                    color: Colors.white, // Needed for ShaderMask to apply gradient
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
