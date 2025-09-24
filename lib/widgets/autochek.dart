import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:MyAbsen/views/log/login.dart';
import 'package:MyAbsen/widgets/navbar/bottom.dart';
import 'package:flutter/material.dart';

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
