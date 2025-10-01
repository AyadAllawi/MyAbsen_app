import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/attandance.dart';
import 'package:myabsen_project/api/profile.dart';
import 'package:myabsen_project/contans/office_location.dart';
import 'package:myabsen_project/model/absen_chek_in.dart';
import 'package:myabsen_project/model/absen_chek_out.dart';
import 'package:myabsen_project/widgets/succes.dart';

class HomePage extends StatefulWidget {
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
      jam = DateFormat("hh:mm a", "id_ID").format(now);
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
    if (profile != null && profile!['name'] != null) {
      return profile!['name'];
    }
    return "User";
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
        profile = profileData;
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
        print("Location services disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print("Location permission denied forever");
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
            if (p.name != null && p.name!.isNotEmpty) p.name,
            if (p.street != null && p.street!.isNotEmpty) p.street,
            if (p.subLocality != null && p.subLocality!.isNotEmpty)
              p.subLocality,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality,
            if (p.administrativeArea != null &&
                p.administrativeArea!.isNotEmpty)
              p.administrativeArea,
          ];
          currentAddress = parts.join(", ");
        } else {
          currentAddress = "${pos.latitude}, ${pos.longitude}";
        }
      } catch (e) {
        currentAddress = "${pos.latitude}, ${pos.longitude}";
        print("geocoding error: $e");
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

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.0),
        );
      }
    } catch (e) {
      print("_determinePositionAndAddress error: $e");
    }
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
        print("Check-in response: ${response.toJson()}");

        setState(() {
          _successMessage = "Check-in berhasil!";
          _showSuccessCard = true;
        });
      } else {
        AbsenCheckOutModel response = await AttendanceAPI.checkOut(
          lat: currentPosition!.latitude,
          lng: currentPosition!.longitude,
          address: currentAddress,
        );
        print("Check-out response: ${response.toJson()}");

        setState(() {
          _successMessage = "Check-out berhasil!";
          _showSuccessCard = true;
        });
      }

      // auto hilang setelah 2 detik
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccessCard = false);
        }
      });

      await Future.wait([fetchStats(), _determinePositionAndAddress()]);
    } catch (e) {
      print("sendAbsen error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal $type: ${e.toString()}")));
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E7EE),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // HEADER
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5271FF), Color(0xFF3B57E8)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF5271FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF3B57E8),
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
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
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoading
                                      ? "Memuat data..."
                                      : "Selamat ${_greeting()}, ${userName}!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  profile?['training_title'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.notifications, color: Colors.white),
                        ],
                      ),
                      SizedBox(height: 25),
                      Text(
                        jam,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(tanggal, style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                // BODY
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children: [
                              // MAP CARD
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
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
                                      onMapCreated: (controller) {
                                        mapController = controller;
                                      },
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
                              SizedBox(height: 20),

                              // LOCATION CARD
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    "Lokasi: ${currentAddress.isNotEmpty ? currentAddress : '-'}",
                                  ),
                                  subtitle: Text(
                                    "Jarak ke kantor: ${distanceToOffice != null ? distanceToOffice!.toStringAsFixed(1) : '-'} meter",
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // ABSENCE CARD
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Absensi Hari Ini",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text("Check-in"),
                                              SizedBox(height: 5),
                                              Text(
                                                stats?['checkin_time'] ?? "-",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("Check-out"),
                                              SizedBox(height: 5),
                                              Text(
                                                stats?['checkout_time'] ?? "-",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: isSubmitting
                                                  ? null
                                                  : () => sendAbsen("checkin"),
                                              child: Text("Check-in"),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: isSubmitting
                                                  ? null
                                                  : () => sendAbsen("checkout"),
                                              child: Text("Check-out"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // WARNING CARD
                              if (distanceToOffice != null &&
                                  distanceToOffice! > 100)
                                Card(
                                  color: Colors.red.shade100,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      "Anda berada di luar jangkauan kantor (>${distanceToOffice!.toStringAsFixed(0)}m)",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            // SUCCESS CARD fade in – fade out
            if (_showSuccessCard)
              Center(
                child: AnimatedOpacity(
                  opacity: _showSuccessCard ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: SuccessCard(message: _successMessage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
