import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myabsen_project/api/profile.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String? currentPhotoUrl; // Tambahkan ini

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentEmail,
    this.currentPhotoUrl, // Tambahkan ini
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  // Variabel baru untuk foto profil
  File? _pickedImage;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _profilePhotoUrl = widget.currentPhotoUrl; // Inisialisasi dari widget
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil Image Picker dan memilih gambar
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      Navigator.pop(context); // Tutup bottom sheet
    }
  }

  // Fungsi untuk mengunggah foto profil ke API
  Future<void> _updateProfilePhoto() async {
    if (_pickedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ProfileAPI.updatePhoto(file: _pickedImage!);
      final newPhotoUrl = response['data']?['profile_photo'];

      if (newPhotoUrl != null) {
        setState(() {
          _profilePhotoUrl = newPhotoUrl;
          _pickedImage = null; // Reset picked image setelah berhasil diunggah
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengunggah foto: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengupdate nama dan email
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    try {
      // Panggil API untuk mengupdate nama dan email
      await ProfileAPI.updateProfile(name: newName, email: newEmail);

      // Panggil fungsi unggah foto jika ada gambar yang dipilih
      if (_pickedImage != null) {
        await _updateProfilePhoto();
      }

      // Tampilkan pesan sukses dan kembali ke halaman profil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Kembali ke halaman sebelumnya dan kirim data yang diperbarui
      Navigator.pop(context, {
        'name': newName,
        'email': newEmail,
        'photoUrl': _profilePhotoUrl, // Kirim juga URL foto yang baru
      });
    } catch (e) {
      // Tangani error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui profil: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function untuk mendapatkan ImageProvider yang benar
  ImageProvider<Object>? _getProfileImageProvider() {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    } else if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_profilePhotoUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _getProfileImageProvider() == null
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4A5CF6), Color(0xFF6C7CE7)],
                            )
                          : null,
                      image: _getProfileImageProvider() != null
                          ? DecorationImage(
                              image: _getProfileImageProvider()!,
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4A5CF6).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _getProfileImageProvider() == null
                        ? Icon(Icons.person, size: 60, color: Colors.white)
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
                                onTap: () => _pickImage(ImageSource.gallery),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF0062DD),
                                ),
                                title: const Text("Ambil Foto"),
                                onTap: () => _pickImage(ImageSource.camera),
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
                            color: Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Form Section
            Text(
              'Informasi Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 20),

            // Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Lengkap',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF4A5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF4A5CF6),
                          size: 20,
                        ),
                      ),
                      hintText: 'Masukkan nama lengkap',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Email Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF4A5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF4A5CF6),
                          size: 20,
                        ),
                      ),
                      hintText: 'Masukkan email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Save Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF4A5CF6), Color(0xFF6C7CE7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4A5CF6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
