import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF436EFF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/image/logo.png",
                    width: 100,
                    height: 100,
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "MyAbsen",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Versi 1.0.0",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: "Deskripsi",
              content:
                  "Aplikasi absensi mobile yang dikembangkan menggunakan framework Flutter untuk memenuhi studi kasus Assessment Sertifikasi Junior Mobile Developer. Aplikasi ini terintegrasi dengan REST API untuk manajemen data autentikasi dan absensi secara real-time.",
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: "Fitur Utama",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    "Autentikasi Pengguna: Registrasi, Login, dan Reset Password.",
                  ),
                  _buildFeatureItem(
                    "Absensi Harian: Absen Masuk dan Absen Pulang dengan validasi lokasi 20 meter.",
                  ),
                  _buildFeatureItem(
                    "Riwayat Absensi: Melihat history kehadiran dengan detail waktu dan lokasi.",
                  ),
                  _buildFeatureItem(
                    "Manajemen Profil: Mengedit nama, email, dan memperbarui foto profil.",
                  ),
                  _buildFeatureItem(
                    "Logout: Mengamankan akun dengan menghapus token autentikasi.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: "Fitur Unggulan",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    "Dialog Konfirmasi & Lottie Success Dialog.",
                  ),
                  _buildFeatureItem(
                    "Integrasi Google Maps untuk akurasi lokasi absen.",
                  ),
                  _buildFeatureItem(
                    "Efek Loading Shimmer untuk pengalaman pengguna yang lebih baik.",
                  ),
                  _buildFeatureItem(
                    "Tampilan UI/UX yang modern, dinamis, dan responsif.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                "© 2025 Ayad Allawi",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF436EFF),
          ),
        ),
        const SizedBox(height: 8),
        content != null
            ? Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              )
            : contentWidget!,
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
