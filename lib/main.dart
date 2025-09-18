import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myabsen_project/views/home.dart';
import 'package:myabsen_project/views/log/login.dart';
import 'package:myabsen_project/views/log/logreg.dart';
import 'package:myabsen_project/views/log/register.dart';
import 'package:myabsen_project/views/navbar/bottom.dart';
import 'package:myabsen_project/views/onboarding/onboarding.dart';
import 'package:myabsen_project/views/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data (misal: Indonesia)
  await initializeDateFormatting('id_ID', null);

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
        '/home': (context) => const HomePage(),
      },
      home: SplashScreen(),
    );
  }
}
