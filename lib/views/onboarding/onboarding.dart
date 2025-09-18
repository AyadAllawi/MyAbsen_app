import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  static const id = "/onboarding";

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 95,
                      height: 80,
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      "MyAbsen",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D6EFD),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Center(
                  child: Image.asset(
                    "assets/images/onboarding.png",
                    height: 350,
                    width: 450,
                  ),
                ),

                const SizedBox(height: 110),

                // Text deskripsi (align kiri)
                const Text(
                  "Cukup satu sentuhan untuk catat kehadiran kerja. "
                  "Cepat, praktis, dan tanpa ribet",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 95,
                      height: 80,
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      "MyAbsen",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D6EFD),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Center(
                  child: Image.asset(
                    "assets/images/oboarding1.png",
                    height: 350,
                    width: 450,
                  ),
                ),

                const SizedBox(height: 110),

                // Text deskripsi (align kiri)
                const Text(
                  "Semua kehadiran tersimpan otomatis dan real-time, siap untuk dipantau kapan saja.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 95,
                      height: 80,
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      "MyAbsen",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D6EFD),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Center(
                  child: Image.asset(
                    "assets/images/onboarding2.png",
                    height: 350,
                    width: 450,
                  ),
                ),

                const SizedBox(height: 110),

                // Text deskripsi (align kiri)
                const Text(
                  "Fokus ke pekerjaan, biar MyAbsen yang urus catatan kehadiran kamu.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      showNextButton: true,
      next: SizedBox(
        width: 60,
        height: 60,
        child: const Icon(Icons.arrow_forward, color: Colors.black),
      ),
      done: SizedBox(
        width: 60,
        height: 60,
        child: const Icon(Icons.arrow_forward, color: Colors.black),
      ),
      onDone: () {
        Navigator.pushReplacementNamed(context, "/logreg");
      },
      showSkipButton: false,
      dotsDecorator: const DotsDecorator(
        size: Size(10, 10),
        color: Colors.grey,
        activeColor: Color(0xFF0D6EFD),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
