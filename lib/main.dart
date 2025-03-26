import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooklkeme_createx_project/controller/user_controller.dart';
import 'package:cooklkeme_createx_project/view/splash_screen.dart/splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? storedValue = prefs.getBool('OnboardScreen'); // Check the value
  bool seenOnboarding = storedValue ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({Key? key, this.seenOnboarding = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(seenOnboarding: seenOnboarding),
    );
  }
}
