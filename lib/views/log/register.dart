import 'dart:io';

import 'package:MyAbsen/api/authentication_api.dart';
import 'package:MyAbsen/model/get_bacth.dart';
import 'package:MyAbsen/model/get_list_training_model.dart';
import 'package:MyAbsen/views/log/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

// Widget kecil untuk animasi staggered (muncul satu per satu)
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.2),
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = "/register";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal ambil data: $e")));
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(fontFamily: "Poppins"), // DITAMBAHKAN
                ),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(
                  'Ambil Foto dari Kamera',
                  style: TextStyle(fontFamily: "Poppins"), // DITAMBAHKAN
                ),
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengambil gambar')));
      }
    }
  }

  Future<void> registerUser() async {
    if (_image == null) {
      Get.snackbar(
        "Error",
        "Foto profil wajib diunggah.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    if (selectedBatchObj == null || selectedTrainingObj == null) {
      Get.snackbar(
        "Error",
        "Batch dan Training wajib dipilih.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil, silakan login")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginAbsen()),
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains("sudah terdaftar")) {
        await _showLottieDialog("assets/lottie/warning.json");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email sudah terdaftar")),
          );
        }
      } else {
        await _showLottieDialog("assets/lottie/error.json");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal mendaftar: $e")));
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showLottieDialog(String asset) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: Lottie.asset(asset, height: 150, repeat: false)),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins'), // DITAMBAHKAN
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A5CF6), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Image.asset(
                      // Mengganti Image.asset dengan Lottie
                      'assets/images/image/logo.png',
                      height: 150,
                    ),
                  ),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Buat Akun Baru",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        fontFamily: "Poppins",
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      "Isi data di bawah ini untuk memulai.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- FORM FIELDS DENGAN ANIMASI ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 400),
                    child: TextFormField(
                      controller: nameController,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ), // DITAMBAHKAN
                      decoration: _inputDecoration(
                        "Nama Lengkap",
                        Icons.person_outline,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 500),
                    child: TextFormField(
                      controller: emailController,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ), // DITAMBAHKAN
                      decoration: _inputDecoration(
                        "Email",
                        Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 600),
                    child: DropdownButtonFormField<Datum>(
                      initialValue: selectedTrainingObj,
                      decoration: _inputDecoration(
                        "Pilih Training",
                        Icons.work_outline,
                      ),
                      items: trainingList
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Expanded(
                                child: Text(
                                  t.title ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedTrainingObj = value),
                      validator: (value) =>
                          value == null ? 'Training harus dipilih' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Batches>(
                            initialValue: selectedBatchObj,
                            decoration: _inputDecoration(
                              "Batch",
                              Icons.group_work_outlined,
                            ),
                            items: batchList
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(
                                      "Batch ${b.batchKe?.toString() ?? ''}",
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                      ), // DITAMBAHKAN
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedBatchObj = value),
                            validator: (value) =>
                                value == null ? 'Batch harus dipilih' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedGender,
                            decoration: _inputDecoration(
                              "Kelamin",
                              Icons.wc_outlined,
                            ),
                            items: ["L", "P"]
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      g == 'L' ? 'L' : 'P',
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedGender = value),
                            validator: (value) => value == null
                                ? 'Jenis Kelamin harus dipilih'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInSlide(
                    delay: const Duration(milliseconds: 800),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ), // DITAMBAHKAN
                      decoration:
                          _inputDecoration(
                            "Password",
                            Icons.lock_outline,
                          ).copyWith(
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
                      validator: (value) =>
                          value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- UPLOAD FOTO ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 900),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Unggah Foto Profil",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontFamily: "Poppins", // DITAMBAHKAN
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- TOMBOL DAFTAR ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 1000),
                    child: SizedBox(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : const Text(
                                "Daftar Sekarang",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // --- LINK MASUK ---
                  FadeInSlide(
                    delay: const Duration(milliseconds: 1100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun?",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginAbsen(),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
