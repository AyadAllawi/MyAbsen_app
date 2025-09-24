import 'dart:async';

import 'package:MyAbsen/api/attandance.dart';
import 'package:MyAbsen/api/profile.dart';
import 'package:MyAbsen/contans/office_location.dart';
import 'package:MyAbsen/model/absen_chek_in.dart';
import 'package:MyAbsen/model/absen_chek_out.dart';
import 'package:MyAbsen/widgets/succes.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? stats;
  Map<String, dynamic>? profile;
  bool isLoading = true;
  bool isSubmitting = false;
  bool _showSuccessCard = false;
  String _successMessage = "";

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
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
    _initAll();
  }

  Future<void> _initAll() async {
    try {
      await Future.wait([
        fetchProfile(),
        fetchStats(),
        _determinePositionAndAddress(),
      ]);
    } catch (e) {
      print("_initAll error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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

  String get userName {
    return profile?['name'] ?? "User";
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Pagi";
    if (hour < 15) return "Siang";
    if (hour < 18) return "Sore";
    return "Malam";
  }

  Future<void> fetchStats() async {
    try {
      final statsData = await AttendanceAPI.getStats();
      setState(() {
        stats = statsData;
      });
    } catch (e) {
      print("fetchStats error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil statistik")));
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profileData = await ProfileAPI.getProfile();
      setState(() {
        profile = profileData['data'];
      });
    } catch (e) {
      print("fetchProfile error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil profil")));
    }
  }

  Future<void> _determinePositionAndAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = pos;
      });

      try {
        final placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.name,
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(", ");
          currentAddress = parts;
        } else {
          currentAddress = "${pos.latitude}, ${pos.longitude}";
        }
      } catch (e) {
        currentAddress = "${pos.latitude}, ${pos.longitude}";
      }

      final meter = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        kantorLocation.latitude,
        kantorLocation.longitude,
      );
      setState(() {
        distanceToOffice = meter;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.0),
      );
    } catch (e) {
      print("_determinePositionAndAddress error: $e");
    }
  }

  void _showSuccessCardAndNavigate(String message) {
    setState(() {
      _successMessage = message;
      _showSuccessCard = true;
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showSuccessCard = false;
        });
      }
    });
  }

  Future<void> sendAbsen(String type) async {
    setState(() => isSubmitting = true);

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lokasi belum tersedia, coba ulangi.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    final dist =
        distanceToOffice ??
        Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          kantorLocation.latitude,
          kantorLocation.longitude,
        );

    if (dist > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda berada di luar jangkauan 20m kantor.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      if (type == "checkin") {
        AbsenCheckInModel response = await AttendanceAPI.checkIn(
          lat: currentPosition!.latitude,
          lng: currentPosition!.longitude,
          address: currentAddress,
        );
        setState(() {
          stats = {
            'checkin_time': response.data?.checkInTime,
            'checkout_time': stats?['checkout_time'],
          };
        });
        _showSuccessCardAndNavigate("Check-in berhasil!");
      } else {
        AbsenCheckOutModel response = await AttendanceAPI.checkOut(
          lat: currentPosition!.latitude,
          lng: currentPosition!.longitude,
          address: currentAddress,
        );
        setState(() {
          stats = {
            'checkin_time': stats?['checkin_time'],
            'checkout_time': response.data?.checkOutTime,
          };
        });
        _showSuccessCardAndNavigate("Check-out berhasil!");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal $type: ${e.toString()}")));
    } finally {
      setState(() => isSubmitting = false);
    }
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
      backgroundColor: Color(0xFFE6E7EE),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20,
                    bottom: 120,
                  ),
                  decoration: BoxDecoration(
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
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    profile != null &&
                                        profile!['profile_photo_url'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          profile!['profile_photo_url'],
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                        ),
                                      )
                                    : Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 11),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLoading
                                        ? "Memuat data..."
                                        : "Selamat ${_greeting()}, $userName!",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    profile?['training_title'] ?? '-',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontFamily: 'Poppins',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 25,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        jam,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        tanggal,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // CONTENT
                Transform.translate(
                  offset: Offset(0, -80), // Mengangkat konten ke atas
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: isLoading
                        ? _buildShimmerLoading()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // MAP CARD
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
                                            markerId: MarkerId("me"),
                                            position: LatLng(
                                              currentPosition!.latitude,
                                              currentPosition!.longitude,
                                            ),
                                            infoWindow: InfoWindow(
                                              title: "Lokasi Anda",
                                              snippet: currentAddress,
                                            ),
                                          ),
                                        Marker(
                                          markerId: MarkerId("kantor"),
                                          position: kantorLocation,
                                          infoWindow: InfoWindow(
                                            title: "Kantor",
                                            snippet: "Titik lokasi kantor",
                                          ),
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
                              SizedBox(height: 10),
                             
                              _buildLocationCard(),
                              SizedBox(height: 10),
                             
                              _buildAbsenceCard(hasCheckedIn, hasCheckedOut),
                              SizedBox(height: 10),
                           
                              if (distanceToOffice != null &&
                                  distanceToOffice! > 100)
                                _buildWarningCard(),
                              SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_showSuccessCard)
            Center(
              child: AnimatedOpacity(
                opacity: _showSuccessCard ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: SuccessCard(message: _successMessage),
              ),
            ),
          isSubmitting
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        SizedBox(height: 80),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 2),
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
            Icon(Icons.location_on, color: Color(0xFF436EFF), size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lokasi Anda",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF436EFF),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    currentAddress.isNotEmpty ? currentAddress : '-',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Jarak ke kantor: ${distanceToOffice != null ? distanceToOffice!.toStringAsFixed(1) : '-'} meter",
                    style: TextStyle(
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
            Text(
              "Absen Karyawan",
              style: TextStyle(
                color: Color(0xFF436EFF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Check-in",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      stats?['checkin_time'] ?? "-",
                      style: TextStyle(
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
                    Text(
                      "Check-out",
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      stats?['checkout_time'] ?? "-",
                      style: TextStyle(
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
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCheckedIn
                          ? Colors.grey[200]
                          : Color(0xFF4CAF50),
                      foregroundColor: hasCheckedIn
                          ? Colors.grey[400]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSubmitting || hasCheckedIn
                        ? null
                        : () => sendAbsen("checkin"),
                    child: Text(
                      "Check-in",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !hasCheckedIn || hasCheckedOut
                          ? Colors.grey[200]
                          : Color(0xFFF44336),
                      foregroundColor: !hasCheckedIn || hasCheckedOut
                          ? Colors.grey[400]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSubmitting || !hasCheckedIn || hasCheckedOut
                        ? null
                        : () => sendAbsen("checkout"),
                    child: Text(
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
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Anda berada di luar jangkauan kantor (>${distanceToOffice!.toStringAsFixed(0)}m)",
                style: TextStyle(
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
