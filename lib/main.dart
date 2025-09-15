import 'package:flutter/material.dart';
import 'package:myabsen_project/views/log/login.dart';
import 'package:myabsen_project/views/log/logreg.dart';
import 'package:myabsen_project/views/log/register.dart';
import 'package:myabsen_project/views/onboarding/onboarding.dart';
import 'package:myabsen_project/views/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 3, 3),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginAbsen(),
        '/logreg': (context) => const Logreg(),
        '/register_futsal': (context) => const Register(),
        // '/home_futsal': (context) => const Home(),
        // '/bot': (context) => Bottom(),
        // '/lapangan': (context) => LapanganScreen(),
        // '/add': (context) => AddFieldScreen(
        //   onFieldAdded: (field) {
        //     print("Lapangan baru: ${field!.nama}");
        //   },
        // ),
      },
      home: SplashScreen(),
    );
  }
}
