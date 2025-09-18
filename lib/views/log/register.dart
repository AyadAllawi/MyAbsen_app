import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:myabsen_project/api/register_user.dart';
import 'package:myabsen_project/views/log/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const id = "/register";

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController trainingController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedTraining;
  String? selectedBatch;
  String? selectedGender;
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    try {
      // contoh file foto dummy, nanti bisa pake imagePicker
      File fakeImage = File("assets/images/logo.png");

      await AuthenticationAPI.registerUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        jenisKelamin: selectedGender ?? "",
        profilePhoto: fakeImage,
        batchId:
            int.tryParse((selectedBatch ?? "1").replaceAll("Batch ", "")) ?? 1,
        trainingId: 1, // sementara fix, bisa diganti dynamic
      );

      // ✅ sukses daftar
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
        // ⚠️ email sudah ada
        await _showLottieDialog("assets/lottie/warning.json");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Email sudah terdaftar")));
      } else {
        // ❌ gagal umum
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
                _buildInputField(
                  controller: nameController,
                  hint: "Masukkan nama lengkap",
                ),
                const SizedBox(height: 15),

                // Email
                _buildLabel("Email"),
                _buildInputField(
                  controller: emailController,
                  hint: "Masukkan email anda",
                ),
                const SizedBox(height: 15),

                // Training
                _buildLabel("Training"),
                _buildDropdown(
                  value: selectedTraining,
                  hint: "Pilih Training",
                  items: const [
                    "Mobile Programming",
                    "Web Programming",
                    "Perhotelan",
                    "Tata Boga",
                  ],
                  onChanged: (value) {
                    setState(() => selectedTraining = value);
                    trainingController.text = value ?? "";
                  },
                ),
                const SizedBox(height: 10),

                // Batch & Kelamin sejajar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Batch"),
                          _buildDropdown(
                            value: selectedBatch,
                            hint: "Pilih Batch",
                            items: const ["Batch 1", "Batch 2", "Batch 3"],
                            onChanged: (value) {
                              setState(() => selectedBatch = value);
                              batchController.text = value ?? "";
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Kelamin"),
                          _buildDropdown(
                            value: selectedGender,
                            hint: "Pilih Kelamin",
                            items: const ["Laki-laki", "Perempuan"],
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
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await registerUser();
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

                // Sudah punya akun
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
                          MaterialPageRoute(
                            builder: (context) => const LoginAbsen(),
                          ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration(hint),
      dropdownColor: Colors.white,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
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
}
