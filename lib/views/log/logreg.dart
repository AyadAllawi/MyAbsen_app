import 'package:MyAbsen/views/log/register.dart';
import 'package:flutter/material.dart';

class Logreg extends StatefulWidget {
  const Logreg({super.key});

  @override
  State<Logreg> createState() => _LogregState();
}

class _LogregState extends State<Logreg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 130),
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/image/logo.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // const Text(
            //   "MyAbsen",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Color(0xFF000DFF),
            //     fontSize: 30,
            //     fontFamily: 'Poppins_bold',
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 190),

            const Text(
              "Selamat Datang di",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "MyAbsen",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF000DFF),
                fontSize: 30,
                fontFamily: 'Poppins_bold',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Atur Kehadiran dengan Mudah Kelola absensi harian, jadwal, dan laporan pekerjaan secara praktis langsung dari smartphone kamu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 138, 136, 136),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 320,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // <-- Hilangkan padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      // <-- Tambahkan gradient di sini
                      colors: [Color(0xFF436EFF), Color(0xFF000DFF)],
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: 320,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Hapus padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  elevation: 8, // Tambahkan elevasi agar bayangan terlihat
                  shadowColor: Colors.black.withOpacity(0.3), // Warna bayangan
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    // Gradient abu-abu gelap untuk tampilan premium
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4c4c4c), Color(0xFF1f1f1f)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
