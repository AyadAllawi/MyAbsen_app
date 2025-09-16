import 'package:flutter/material.dart';
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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedTraining;
  String? selectedBatch;
String? selectedGender;
  bool isLoading = false;
  String? errorMessage;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email, Password, dan Nama tidak boleh kosong"),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Judul
                const Text(
                  "Daftar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Color(0xff8A2D3B),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama
                _buildLabel("Nama"),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Masukkan nama lengkap"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Email
                _buildLabel("Email"),
                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Masukkan email anda"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong";
                    }
                    if (!value.contains("@")) {
                      return "Email tidak valid";
                    }
                    if (!(value.endsWith("@gmail.com") ||
                        value.endsWith("@yahoo.com"))) {
                      return "Email harus @gmail.com atau @yahoo.com";
                    }
                    if (RegExp('[A-Z]').hasMatch(value)) {
                      return "Email harus huruf kecil";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Training
                _buildLabel("Training"),
                DropdownButtonFormField<String>(
                  initialValue: selectedTraining,
                  decoration: _inputDecoration("Pilih Training"),
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: "Mobile Programming",
                      child: Text("Mobile Programming"),
                    ),
                    DropdownMenuItem(
                      value: "Web Programming",
                      child: Text("Web Programming"),
                    ),
                    DropdownMenuItem(
                      value: "Perhotelan",
                      child: Text("Perhotelan"),
                    ),
                    DropdownMenuItem(
                      value: "Tata Boga",
                      child: Text("Tata Boga"),
                    ),
                    DropdownMenuItem(
                      value: "Content Creator",
                      child: Text("Content Creator"),
                    ),
                    DropdownMenuItem(
                      value: "Make Up Artist",
                      child: Text("Make Up Artist"),
                    ),
                    DropdownMenuItem(
                      value: "Multi Media",
                      child: Text("Multi Media"),
                    ),
                    DropdownMenuItem(
                      value: "Design Grafis Madya",
                      child: Text("Design Grafis Madya"),
                    ),
                    DropdownMenuItem(
                      value: "Data Manajemen Staff",
                      child: Text("Data Manajemen Staff"),
                    ),
                    DropdownMenuItem(
                      value: "Akuntansi Junior",
                      child: Text("Akuntansi Junior"),
                    ),
                    DropdownMenuItem(value: "Barista", child: Text("Barista")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTraining = value;
                      trainingController.text = value ?? "";
                    });
                  },
                  validator: (value) => value == null ? "Pilih training" : null,
                ),
                const SizedBox(height: 10),

            // Batch & Kelamin (sejajar)
// Batch & Kelamin (sejajar)
Row(
  children: [
    // Batch
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Batch"),
          DropdownButtonFormField<String>(
            value: selectedBatch,
            decoration: _inputDecoration("Pilih Batch"),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: "Batch 1", child: Text("Batch 1")),
              DropdownMenuItem(value: "Batch 2", child: Text("Batch 2")),
              DropdownMenuItem(value: "Batch 3", child: Text("Batch 3")),
              DropdownMenuItem(value: "Batch 4", child: Text("Batch 4")),
            ],
            onChanged: (value) {
              setState(() {
                selectedBatch = value;
                batchController.text = value ?? "";
              });
            },
            validator: (value) => value == null ? "Pilih batch" : null,
          ),
        ],
      ),
    ),

    const SizedBox(width: 12), // jarak antar kolom

    // Kelamin
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Kelamin"),
          DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: _inputDecoration("Pilih Kelamin"),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
              DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
            ],
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            validator: (value) => value == null ? "Pilih kelamin" : null,
          ),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 10),


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
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password wajib diisi";
                    }
                    if (value.length < 6) {
                      return "Password minimal 6 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await registerUser();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          color: Color(0xFF888888),
                        ),
                      ),
                      TextButton(
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Color.fromRGBO(6, 46, 245, 1),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginAbsen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
          color: Color(0xff8A2D3B),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.grey.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
    );
  }
}
