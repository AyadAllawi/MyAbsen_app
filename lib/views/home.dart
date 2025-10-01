import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/attandance.dart';
import 'package:myabsen_project/contans/office_location.dart';
import 'package:myabsen_project/widgets/navbar/bottom.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NavigationController navController = Get.find<NavigationController>();
  Map<String, dynamic>? stats;
  bool isLoadingStats = true;
  bool isSubmitting = false;
  final bool _showSuccessCard = false;
  final String _successMessage = "";

  late String jam;
  late String tanggal;
  Timer? _timer;

  GoogleMapController? mapController;
  Position? currentPosition;
  String currentAddress = "Mencari lokasi...";
  final LatLng kantorLocation = OfficeLocation.kantor;
  double? distanceToOffice;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _initNonProfileData();
  }

  Future<void> _initNonProfileData() async {
    try {
      await Future.wait([fetchStats(), _determinePositionAndAddress()]);
    } catch (e) {
      print("_initNonProfileData error: $e");
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      jam = DateFormat("HH:mm", "id_ID").format(now);
      tanggal = DateFormat("EEEE, d MMMM y", "id_ID").format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Pagi";
    if (hour < 15) return "Siang";
    if (hour < 18) return "Sore";
    return "Malam";
  }

  Future<void> fetchStats() async {
    if (!mounted) return;
    setState(() => isLoadingStats = true);
    try {
      final statsData = await AttendanceAPI.getStats();
      if (mounted) {
        setState(() {
          stats = statsData;
        });
      }
    } catch (e) {
      print("fetchStats error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingStats = false);
      }
    }
  }

  Future<void> _determinePositionAndAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        currentPosition = pos;
        distanceToOffice = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          kantorLocation.latitude,
          kantorLocation.longitude,
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.0),
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          currentAddress = [
            p.name,
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(", ");
        });
      }
    } catch (e) {
      print("_determinePositionAndAddress error: $e");
    }
  }

  Future<void> sendAbsen(String type) async {
    // Implementasi fungsi ini...
  }

  void _showSuccessCardAndNavigate(String message) {
    // Implementasi fungsi ini...
  }

  @override
  Widget build(BuildContext context) {
    bool hasCheckedIn =
        stats != null &&
        stats?['checkin_time'] != null &&
        (stats?['checkin_time'] as String).isNotEmpty;
    bool hasCheckedOut =
        stats != null &&
        stats?['checkout_time'] != null &&
        (stats?['checkout_time'] as String).isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFE6E7EE),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20,
                    bottom: 120,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6E8BFA),
                        Color(0xFF5271FF),
                        Color(0xFF436EFF),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Obx(() {
                                final photoUrl =
                                    navController.profilePhotoUrl.value;
                                return CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  backgroundImage:
                                      (photoUrl != null && photoUrl.isNotEmpty)
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: (photoUrl == null || photoUrl.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 30,
                                        )
                                      : null,
                                );
                              }),
                              const SizedBox(width: 11),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      navController.isProfileLoading.value
                                          ? "Memuat data..."
                                          : "Selamat ${_greeting()}, ${navController.userName.value ?? 'User'}!",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      // Asumsi training title ada di controller
                                      navController.userTrainingTitle.value ??
                                          '-',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        jam,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        tanggal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // ================================================================
                //         ⬇️ INI DIA CONTENT-NYA YANG KEMARIN HILANG ⬇️
                // ================================================================
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                        (isLoadingStats || navController.isProfileLoading.value)
                        ? _buildShimmerLoading()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SizedBox(
                                  height: 190,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: currentPosition != null
                                            ? LatLng(
                                                currentPosition!.latitude,
                                                currentPosition!.longitude,
                                              )
                                            : kantorLocation,
                                        zoom: 16,
                                      ),
                                      onMapCreated: (controller) =>
                                          mapController = controller,
                                      myLocationEnabled: true,
                                      markers: {
                                        if (currentPosition != null)
                                          Marker(
                                            markerId: const MarkerId("me"),
                                            position: LatLng(
                                              currentPosition!.latitude,
                                              currentPosition!.longitude,
                                            ),
                                          ),
                                        Marker(
                                          markerId: const MarkerId("kantor"),
                                          position: kantorLocation,
                                          icon:
                                              BitmapDescriptor.defaultMarkerWithHue(
                                                BitmapDescriptor.hueBlue,
                                              ),
                                        ),
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildLocationCard(),
                              const SizedBox(height: 10),
                              _buildAbsenceCard(hasCheckedIn, hasCheckedOut),
                              const SizedBox(height: 10),
                              if (distanceToOffice != null &&
                                  distanceToOffice! > 100)
                                _buildWarningCard(),
                              const SizedBox(height: 20),
                            ],
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

  // ================================================================
  //         ⬇️ FUNGSI BUILDER-NYA GUA KEMBALIKAN LAGI ⬇️
  // ================================================================

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF436EFF), size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lokasi Anda",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF436EFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentAddress.isNotEmpty ? currentAddress : '-',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Jarak ke kantor: ${distanceToOffice != null ? distanceToOffice!.toStringAsFixed(1) : '-'} meter",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenceCard(bool hasCheckedIn, bool hasCheckedOut) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Absen Karyawan",
              style: TextStyle(
                color: Color(0xFF436EFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      "Check-in",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stats?['checkin_time'] ?? "-",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Check-out",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stats?['checkout_time'] ?? "-",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCheckedIn
                          ? Colors.grey[200]
                          : const Color(0xFF4CAF50),
                      foregroundColor: hasCheckedIn
                          ? Colors.grey[400]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSubmitting || hasCheckedIn
                        ? null
                        : () => sendAbsen("checkin"),
                    child: const Text(
                      "Check-in",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !hasCheckedIn || hasCheckedOut
                          ? Colors.grey[200]
                          : const Color(0xFFF44336),
                      foregroundColor: !hasCheckedIn || hasCheckedOut
                          ? Colors.grey[400]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSubmitting || !hasCheckedIn || hasCheckedOut
                        ? null
                        : () => sendAbsen("checkout"),
                    child: const Text(
                      "Check-out",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                "© 2025 Ayad Allawi",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Anda berada di luar jangkauan kantor (>${distanceToOffice!.toStringAsFixed(0)}m)",
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
