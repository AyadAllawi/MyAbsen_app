import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myabsen_project/api/profile.dart';
import 'package:myabsen_project/preference/shared_preference.dart';
import 'package:myabsen_project/views/history.dart';
import 'package:myabsen_project/views/log/login.dart';
import 'package:myabsen_project/widgets/change_password.dart';
import 'package:myabsen_project/widgets/profile/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profilePhotoUrl;
  String? _name;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fungsi untuk mengambil data profil dari API
  Future<void> _fetchProfileData() async {
    try {
      final profileData = await ProfileAPI.getProfile();
      setState(() {
        _name = profileData['data']['name'] ?? "Guest";
        _email = profileData['data']['email'] ?? "No email";
        _profilePhotoUrl = profileData['data']['profile_photo_url'];
      });
    } catch (e) {
      print("Error fetching profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data profil.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mengunggah foto...")));
      _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      final response = await ProfileAPI.updatePhoto(file: image);
      final newPhotoUrl = response['data']?['profile_photo'];
      if (newPhotoUrl != null) {
        setState(() {
          _profilePhotoUrl = newPhotoUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Foto profil berhasil diperbarui!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengunggah foto: ${e.toString()}")),
      );
    }
  }

  ImageProvider<Object>? _getProfileImageProvider() {
    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_profilePhotoUrl!);
    }
    return null; // Return null jika tidak ada foto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF0C1C3C), Color(0xFF0C1C3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: _getProfileImageProvider(),
                            child: _getProfileImageProvider() == null
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.photo_library,
                                          color: Color(0xFF0062DD),
                                        ),
                                        title: const Text("Pilih dari Gallery"),
                                        onTap: () {
                                          _pickImage(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFF0062DD),
                                        ),
                                        title: const Text("Ambil Foto"),
                                        onTap: () {
                                          _pickImage(ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Color(0xFF0062DD),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _name ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _email ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildInfoTile(
                        title: "Edit Profile",
                        icon: Icons.person,
                        onTap: () async {
                          final updatedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                currentName: _name ?? '',
                                currentEmail: _email ?? '',
                              ),
                            ),
                          );

                          if (updatedData != null &&
                              updatedData is Map<String, dynamic>) {
                            setState(() {
                              _name = updatedData['name'];
                              _email = updatedData['email'];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Riwayat Absen",
                        icon: Icons.history,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryAbsenPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Ganti Password",
                        icon: Icons.lock_reset,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Notifikasi",
                        icon: Icons.notifications,
                        onTap: () {
                          // Implementasi navigasi untuk Notifikasi
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Bahasa",
                        icon: Icons.language,
                        onTap: () {
                          // Implementasi navigasi untuk Bahasa
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Tentang Aplikasi",
                        icon: Icons.info,
                        onTap: () {
                          // Implementasi navigasi untuk Tentang Aplikasi
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip,
                        onTap: () {
                          // Implementasi navigasi untuk Privacy Policy
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        title: "Pengaturan",
                        icon: Icons.settings,
                        onTap: () {
                          // Implementasi navigasi untuk Pengaturan
                        },
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await PreferenceHandler.removeToken();
                          await PreferenceHandler.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginAbsen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    VoidCallback? onTap, // Menambahkan parameter onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0062DD), size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
