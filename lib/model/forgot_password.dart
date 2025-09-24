import 'dart:convert';

import 'package:MyAbsen/widgets/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model untuk respons forgot password
class ForgotPasswordModel {
  String? message;

  ForgotPasswordModel({this.message});

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordModel(message: json["message"]);
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final String _baseUrl = 'https://appabsensi.mobileprojp.com';

  Future<void> _forgotPassword() async {
    final url = Uri.parse('$_baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        body: {'email': _emailController.text},
      );

      // Baris ini untuk debugging, lo bisa hapus nanti
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        final forgotPasswordResponse = ForgotPasswordModel.fromJson(
          responseBody,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              forgotPasswordResponse.message ?? 'Kode OTP telah dikirim.',
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordPage(email: _emailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message'] ?? 'Gagal mengirim OTP.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Masukkan email Anda untuk mendapatkan kode OTP.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _forgotPassword,
              child: const Text('Kirim Kode OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
