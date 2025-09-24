import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myabsen_project/api/profile.dart';
import 'package:myabsen_project/views/history.dart';
import 'package:myabsen_project/views/home.dart';
import 'package:myabsen_project/views/profile.dart';

class BottomPage extends StatelessWidget {
  BottomPage({super.key});
  static const id = "/bot";

  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 60,
          elevation: 6,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: _navDestinations,
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.screens,
        ),
      ),
    );
  }

  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];
}

// ================================================================
//         ⬇️ INI ADALAH 'OTAK' UTAMA APLIKASI LU ⬇️
// ================================================================
class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  // Variabel penampung data profil, dibungkus Rx agar reaktif
  final Rxn<String> userName = Rxn<String>();
  final Rxn<String> userEmail = Rxn<String>();
  final Rxn<String> profilePhotoUrl = Rxn<String>();
  final Rxn<String> userTrainingTitle = Rxn<String>();
  final RxBool isProfileLoading = true.obs;

  final List<Widget> screens = [
    const HomePage(),
    const HistoryAbsenPage(),
    const ProfilePage(),
  ];

  @override
  void onInit() {
    super.onInit();
    // Saat 'otak' pertama kali dibuat, langsung ambil data profil
    fetchProfileData();
  }

  // Fungsi ini jadi satu-satunya sumber kebenaran untuk data profil
  Future<void> fetchProfileData() async {
    isProfileLoading.value = true;
    try {
      final profileData = await ProfileAPI.getProfile();
      final data = profileData['data'];

      userName.value = data['name'];
      userEmail.value = data['email'];
      userTrainingTitle.value = data['training_title'];

      // Trik anti-cache: Tambahkan timestamp unik ke URL gambar
      final baseUrl = data['profile_photo_url'];
      if (baseUrl != null) {
        profilePhotoUrl.value =
            "$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      } else {
        profilePhotoUrl.value = null;
      }
    } catch (e) {
      print("Error di NavigationController: $e");
      // Opsional: tampilkan pesan error jika diperlukan
    } finally {
      isProfileLoading.value = false;
    }
  }
}
