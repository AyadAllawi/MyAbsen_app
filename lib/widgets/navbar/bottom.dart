import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Widget> screens = [
    HomePage(),
    const HistoryAbsenPage(),
    ProfilePage(),
  ];
}
