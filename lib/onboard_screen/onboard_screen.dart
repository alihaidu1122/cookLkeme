import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/view/home_page/home_page.dart';
import 'package:cooklkeme_createx_project/view/auth_screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _slides = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
  ];

  final List<String> _headings = [
    "Discover Endless Recipes",
    "Share Your Creations",
    "Connect with Food Lovers",
  ];

  final List<String> _paragraphs = [
    "Swipe through a world of flavors! From quick snacks to gourmet meals, explore recipes that inspire your next dish.",
    "Got a favorite recipe? Record, edit, and post it to show off your cooking skills. Inspire others with your delicious creations!",
    "Follow chefs and fellow foodies, engage with their recipes, and join a community that’s as passionate about food as you are.",
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to another screen if required
    }
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('OnboardScreen', true);

    // bool? storedValue = prefs.getBool('onboardScren'); // Check the value
    //  print(storedValue);
  }

  @override
  void initState() {
    _completeOnboarding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        scrollDirection:
            Axis.horizontal, // Enables full-screen horizontal scroll
        itemBuilder: (context, index) {
          return Column(
            children: [
              // Background Image with Gradient (80% of screen)
              Stack(
                children: [
                  SizedBox(
                    height: screenHeight * 0.75, // Adjusted to prevent overflow
                    width: screenWidth,
                    child: Image.asset(
                      _slides[index],
                      fit: BoxFit.cover, // Ensures image starts from top
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.75, // Same as image height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),

          
              Container(
                height: screenHeight * 0.25,
                padding: const EdgeInsets.only(top: 15),
                // color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _headings[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: whiteTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    // const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        _paragraphs[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          color: halfWhiteColor,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Sliding dots and Next Button
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1D1D1D), // Solid dark color
                            Color(0xFF1D1D1D),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(24, 26, 32, 0.6),
                              Color.fromRGBO(24, 26, 32, 0.6),
                            ],
                          ),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Sliding dots
                            Row(
                              children: List.generate(
                                _slides.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: _currentPage == index ? 29 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? orangeButtonColor
                                        : whiteTextColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // Next Button
                            TextButton(
                              onPressed: () async {
                                if (_currentPage == _slides.length - 1) {
                                  // ✅ Save flag to SharedPreferences
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('seenOnboarding', true);

                                  // ✅ Navigate permanently to HomeScreen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginScreen()),
                                  );
                                } else {
                                  // Go to the next page
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: Text(
                                _currentPage == _slides.length - 1
                                    ? "Finish"
                                    : "Next",
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
          );
        },
      ),
    );
  }
}
