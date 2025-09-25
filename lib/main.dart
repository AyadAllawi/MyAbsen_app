import 'package:MyAbsen/views/home.dart';
import 'package:MyAbsen/views/log/login.dart';
import 'package:MyAbsen/views/log/logreg.dart';
import 'package:MyAbsen/views/log/register.dart';
import 'package:MyAbsen/views/onboarding/onboarding.dart';
import 'package:MyAbsen/views/splashscreen.dart';
import 'package:MyAbsen/widgets/navbar/bottom.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginAbsen(),
        '/logreg': (context) => const Logreg(),
        '/register_futsal': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/bot': (context) => BottomPage(),
      },
      home: SplashScreen(),
    );
  }
}
