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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FF), // Latar belakang lebih cerah
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF436EFF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: _getProfileImageProvider(),
                        child: _getProfileImageProvider() == null
                            ? const Icon(
                                Icons.person,
                                size: 85,
                                color: Color(0xFFC0C0C0),
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
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0),
                                ),
                              ),
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Color(0xFF0062DD),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name ?? "Loading...",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Informasi Akun"),
                  _buildCard(
                    children: [
                      _buildInfoTile(
                        title: "Edit Profile",
                        icon: Icons.person_outline,
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
                      _buildDivider(),
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
                      _buildDivider(),
                      _buildInfoTile(
                        title: "Ganti Password",
                        icon: Icons.lock_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Pengaturan & Lainnya"),
                  _buildCard(
                    children: [
                      _buildInfoTile(
                        title: "Notifikasi",
                        icon: Icons.notifications_none,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        title: "Bahasa",
                        icon: Icons.language,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        title: "Tentang Aplikasi",
                        icon: Icons.info_outline,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        title: "Pengaturan",
                        icon: Icons.settings_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.redAccent,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF436EFF), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFE0E0E0)),
    );
  }
}
