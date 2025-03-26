import 'package:flutter/material.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/view/home_page/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents default keyboard behavior
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              height: MediaQuery.of(context).size.height, // Full height
              color: loginblackColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/icon.png",
                      height: 130,
                    ),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.deepOrange,
                          Colors.orange,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        "CookLikeMe",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: whiteTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: whiteTextColor,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: greyColor),
                      decoration: InputDecoration(
                        labelText: "Email/Username",
                        labelStyle: const TextStyle(color: greyColor),
                        filled: true,
                        fillColor: fieldCOlor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: greyColor),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: greyColor),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: greyColor),
                        filled: true,
                        fillColor: fieldCOlor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: greyColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: greyColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 1),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: dOrangeButtonColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        },
                        // borderRadius: BorderRadius.circular(
                        //     40), // Ensures ripple effect matches button
                        child: Container(
                          decoration: BoxDecoration(
                              color: orangeButtonColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 35, vertical: 10),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: whiteTextColor,
                              ),
                            ),
                          ),
                        )),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: whiteTextColor),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Sign-up",
                            style: TextStyle(color: dOrangeButtonColor),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
