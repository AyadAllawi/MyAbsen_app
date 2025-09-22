import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:myabsen_project/api/authentication_api.dart';
import 'package:myabsen_project/model/get_bacth.dart';
import 'package:myabsen_project/model/get_list_training_model.dart';
import 'package:myabsen_project/views/log/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = "/register";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // API data
  List<Batches> batchList = [];
  List<Datum> trainingList = [];

  Batches? selectedBatchObj;
  Datum? selectedTrainingObj;
  String? selectedGender;

  File? _image;
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final batches = await AuthenticationAPI.getBatchList();
      final trainings = await AuthenticationAPI.getTrainingList();

      setState(() {
        batchList = batches;
        trainingList = trainings;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal ambil data: $e")));
    }
  }

  // FUNGSI _pickImage YANG DIUBAH - TAMBAH FITUR KAMERA
  Future<void> _pickImage() async {
    // Tampilkan bottom sheet untuk pilihan
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // FUNGSI BARU UNTUK MENDAPATKAN GAMBAR
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar')));
    }
  }

  Future<void> registerUser() async {
    if (_image == null) {
      Get.snackbar("Error", "Foto wajib diupload");
      return;
    }
    if (selectedBatchObj == null || selectedTrainingObj == null) {
      Get.snackbar("Error", "Batch dan Training wajib dipilih");
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthenticationAPI.registerUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        jenisKelamin: selectedGender ?? "",
        profilePhoto: _image!,
        batchId: selectedBatchObj?.id ?? 1,
        trainingId: selectedTrainingObj?.id ?? 1,
      );

      await _showLottieDialog("assets/lottie/success.json");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil, silakan login")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginAbsen()),
      );
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains("sudah terdaftar")) {
        await _showLottieDialog("assets/lottie/warning.json");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Email sudah terdaftar")));
      } else {
        await _showLottieDialog("assets/lottie/error.json");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mendaftar: $e")));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showLottieDialog(String asset) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: Lottie.asset(asset, repeat: false)),
    );
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.grey.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: "Poppins",
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/images/image/logo.png", height: 100),
                const SizedBox(height: 20),
                const Text(
                  "Daftar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    fontFamily: "Poppins",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // Nama
                _buildLabel("Nama"),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Masukkan nama lengkap"),
                ),
                const SizedBox(height: 15),

                // Email
                _buildLabel("Email"),
                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Masukkan email anda"),
                ),
                const SizedBox(height: 25),

                // Training Dropdown
                _buildLabel("Training"),
                DropdownButtonFormField<Datum>(
                  initialValue: selectedTrainingObj,
                  decoration: _inputDecoration("Pilih Training"),
                  items: trainingList
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.title ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedTrainingObj = value),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Batch Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Batch"),
                          DropdownButtonFormField<Batches>(
                            initialValue: selectedBatchObj,
                            decoration: _inputDecoration("Pilih Batch"),
                            items: batchList
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(
                                      b.batchKe?.toString() ?? "Batch",
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedBatchObj = value),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Kelamin"),
                          DropdownButtonFormField<String>(
                            initialValue: selectedGender,
                            decoration: _inputDecoration("Pilih Kelamin"),
                            items: ["L", "P"]
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedGender = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Password
                _buildLabel("Password"),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: _inputDecoration("Masukkan password anda")
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 20),

                // Upload Foto - TAMBAH PETUNJUK KAMERA/GALLERY
                _buildLabel("Upload Foto"),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to select image",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "(Kamera atau Gallery)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              registerUser();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Daftar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: "Poppins",
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginAbsen()),
                        );
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Color(0xFF4A5CF6),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
