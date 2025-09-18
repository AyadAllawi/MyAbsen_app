import 'package:flutter/material.dart';
import 'package:myabsen_project/preference/shared_preference.dart';
import 'package:myabsen_project/views/log/logreg.dart';
import 'package:myabsen_project/views/onboarding/onboarding.dart';


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

    isLogin();
  }

  void isLogin() async {
    bool? isLogin = await PreferenceHandler.getLoginStatus();

    Future.delayed(Duration(seconds: 3)).then((value) async {
      print(isLogin);
      if (isLogin == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Logreg()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
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
            SizedBox(height: 290),
            Container(
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                width: 300,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            Spacer(),
            RichText(
              text: TextSpan(
                text: 'Powered by ',
                style: const TextStyle(
                  color: Color.fromARGB(255, 121, 117, 117),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Ayad Allawi',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 4, 255),
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
