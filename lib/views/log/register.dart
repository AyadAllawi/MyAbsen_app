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
  String? selectedTraining;
  String? selectedBatch;
  String? selectedGender;
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulasi API

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset("assets/images/image/logo.png", height: 100),
                const SizedBox(height: 20),

                // Title
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
                _buildInputField(controller: nameController, hint: "Masukkan nama lengkap"),
                const SizedBox(height: 15),

                // Email
                _buildLabel("Email"),
                _buildInputField(controller: emailController, hint: "Masukkan email anda"),
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
                    "Content Creator",
                    "Make Up Artist",
                    "Multi Media",
                    "Design Grafis Madya",
                    "Data Manajemen Staff",
                    "Akuntansi Junior",
                    "Barista",
                  ],
                  onChanged: (value) {
                    setState(() => selectedTraining = value);
                    trainingController.text = value ?? "";
                  },
                ),
                const SizedBox(height: 15),

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
                            items: const ["Batch 1", "Batch 2", "Batch 3", "Batch 4"],
                            onChanged: (value) {
                              setState(() => selectedBatch = value);
                              batchController.text = value ?? "";
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Kelamin"),
                          _buildDropdown(
                            value: selectedGender,
                            hint: "Pilih Kelamin",
                            items: const ["Laki-laki", "Perempuan"],
                            onChanged: (value) => setState(() => selectedGender = value),
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
                  decoration: _inputDecoration("Masukkan password anda").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Text("Lupa Password!", style: TextStyle(
                  color: Color(0xFF000000)
                ),),
const SizedBox(height: 20),
                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        await registerUser();
                        Navigator.pop(context);
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
                const SizedBox(height: 20),

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
                          MaterialPageRoute(builder: (context) => const LoginAbsen()),
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

  Widget _buildInputField({required TextEditingController controller, required String hint}) {
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
      value: value,
      decoration: _inputDecoration(hint),
      dropdownColor: Colors.white,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
