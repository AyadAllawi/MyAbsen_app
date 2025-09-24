import 'package:flutter/material.dart';
import 'package:myabsen_project/preference/shared_preference.dart';
import 'package:myabsen_project/views/log/login.dart';
import 'package:myabsen_project/widgets/navbar/bottom.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await PreferenceHandler.getToken();
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginAbsen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen saat pengecekan
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
