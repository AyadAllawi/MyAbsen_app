import 'package:MyAbsen/extension/navigation.dart';
import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:MyAbsen/views/onboarding/onboarding.dart';
import 'package:MyAbsen/widgets/navbar/bottom.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  void checkLogin() async {
    final isLogin = await PreferenceHandler.getLogin();
    Future.delayed(Duration(seconds: 4)).then((_) {
      if (!mounted) return;
      if (isLogin == true) {
        context.pushReplacementNamed(BottomPage.id);
      } else {
        context.pushNamed(OnboardingPage.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 350),
            Container(
              child: Image(
                image: AssetImage("assets/images/image/logo.png"),
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            Spacer(),
            RichText(
              text: TextSpan(
                text: '© 2025',
                style: const TextStyle(
                  color: Color.fromARGB(255, 121, 117, 117),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Ayad Allawi',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 4, 255),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
