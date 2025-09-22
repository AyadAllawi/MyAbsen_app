import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessScreen extends StatelessWidget {
  final String absenTime;
  final String absenDate;

  const SuccessScreen({
    super.key,
    required this.absenTime,
    required this.absenDate,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/success.json',
              height: screenHeight * 0.4,
            ),
            SizedBox(height: 20),
            Text(
              'Absen Sukses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Anda masuk pukul',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              absenTime,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Berhasil absen pada tanggal $absenDate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
