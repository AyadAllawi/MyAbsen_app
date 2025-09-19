import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myabsen_project/api/attandance.dart';
import 'package:myabsen_project/api/profile.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? stats; // data dari API
  Map<String, dynamic>? profile; // profile dari API
  bool isLoading = true;
  bool isSubmitting = false;

  late String jam;
  late String tanggal;
  Timer? _timer;

  // Maps & location
  GoogleMapController? mapController;
  Position? currentPosition;
  String currentAddress = "Mencari lokasi...";
  // Koordinat kantor (ubah sesuai titik kantor Anda)
  final LatLng kantorLocation = LatLng(-6.2087634, 106.845599); // contoh: Monas
  double? distanceToOffice; // meter

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
    _initAll();
  }

  Future<void> _initAll() async {
    // urutan: ambil profile & stats, lalu lokasi
    await Future.wait([
      fetchProfile(),
      fetchStats(),
      _determinePositionAndAddress(),
    ]);
    // stop loading flag (stats or profile may set isLoading earlier but ensure false)
    setState(() {
      isLoading = false;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    // 12-hour with AM/PM as requested (id locale)
    setState(() {
      jam = DateFormat("hh:mm a", "id_ID").format(now); // ex: 01:45 PM
      tanggal = DateFormat(
        "EEEE, d MMMM y",
        "id_ID",
      ).format(now); // ex: Jumat, 19 September 2025
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  // ---------- API calls ----------
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

  // ---------- Location & Geocoding ----------
  Future<void> _determinePositionAndAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // user perlu aktifkan location service
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

      // reverse geocode to get address (optional)
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
        // jika geocoding gagal, tampilkan lat,lng
        currentAddress = "${pos.latitude}, ${pos.longitude}";
        print("geocoding error: $e");
      }

      // hitung jarak to kantor
      final meter = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        kantorLocation.latitude,
        kantorLocation.longitude,
      );
      setState(() {
        distanceToOffice = meter;
      });

      // animate map jika sudah ada controller
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.0),
        );
      }
    } catch (e) {
      print("_determinePositionAndAddress error: $e");
    }
  }

  // ---------- Absen (cek jarak dulu) ----------
  Future<void> sendAbsen(String type) async {
    setState(() => isSubmitting = true);

    // pastikan posisi tersedia
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lokasi belum tersedia, coba ulangi.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    // jarak ke kantor harus <= 100 meter
    final dist =
        distanceToOffice ??
        Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          kantorLocation.latitude,
          kantorLocation.longitude,
        );

    if (dist > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda berada di luar jangkauan 100m kantor.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      if (type == "checkin") {
        await AttendanceAPI.checkIn(
          lat: currentPosition!.latitude,
          lng: currentPosition!.longitude,
          address: currentAddress,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Check-in berhasil")));
      } else if (type == "checkout") {
        await AttendanceAPI.checkOut(
          lat: currentPosition!.latitude,
          lng: currentPosition!.longitude,
          address: currentAddress,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Check-out berhasil")));
      }

      // refresh stats & position/address
      await Future.wait([fetchStats(), _determinePositionAndAddress()]);
    } catch (e) {
      print("sendAbsen error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal $type: ${e.toString()}")));
    }

    setState(() => isSubmitting = false);
  }

  // ---------- Build UI (style preserved) ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E7EE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                              profile?['name'] ?? 'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Map Card (Google Map)
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Color(0xFFE6E7EE),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFA3B1C6),
                                  offset: Offset(6, 6),
                                  blurRadius: 12,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-6, -6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: currentPosition == null
                                  ? Container(
                                      color: Color(0xFFD1D9E6),
                                      child: Center(
                                        child: Text(
                                          'Mencari lokasi...',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : GoogleMap(
                                      onMapCreated: (c) {
                                        mapController = c;
                                      },
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          currentPosition!.latitude,
                                          currentPosition!.longitude,
                                        ),
                                        zoom: 16,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId("user"),
                                          position: LatLng(
                                            currentPosition!.latitude,
                                            currentPosition!.longitude,
                                          ),
                                          infoWindow: InfoWindow(
                                            title: "Lokasimu",
                                          ),
                                        ),
                                        Marker(
                                          markerId: MarkerId("kantor"),
                                          position: kantorLocation,
                                          infoWindow: InfoWindow(
                                            title: "Kantor",
                                          ),
                                        ),
                                      },
                                      myLocationEnabled: true,
                                      zoomControlsEnabled: false,
                                    ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Location Card
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6E7EE),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFA3B1C6),
                                  offset: Offset(6, 6),
                                  blurRadius: 12,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-6, -6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Color(0xFF5271FF),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lokasimu",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            currentAddress,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color: Color(0xFF5271FF),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lokasi Kantor",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${kantorLocation.latitude}, ${kantorLocation.longitude}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Absence Card
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6E7EE),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFA3B1C6),
                                  offset: Offset(6, 6),
                                  blurRadius: 12,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-6, -6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF5271FF),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Absen',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Absen: ${stats?['total_absen'] ?? 0}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Masuk: ${stats?['total_masuk'] ?? 0}",
                                    ),
                                    Text("Izin: ${stats?['total_izin'] ?? 0}"),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: isSubmitting
                                            ? null
                                            : () => sendAbsen("checkin"),
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Colors.green[600]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFFA3B1C6),
                                                offset: Offset(4, 4),
                                                blurRadius: 8,
                                              ),
                                              BoxShadow(
                                                color: Colors.white,
                                                offset: Offset(-4, -4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isSubmitting
                                                ? SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    'Check-in',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: isSubmitting
                                            ? null
                                            : () => sendAbsen("checkout"),
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.red[600]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFFA3B1C6),
                                                offset: Offset(4, 4),
                                                blurRadius: 8,
                                              ),
                                              BoxShadow(
                                                color: Colors.white,
                                                offset: Offset(-4, -4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isSubmitting
                                                ? SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    'Check-out',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Warning Card (show if we have distance)
                          if (distanceToOffice != null)
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xFFE6E7EE),
                                borderRadius: BorderRadius.circular(15),
                                border: Border(
                                  left: BorderSide(color: Colors.red, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFA3B1C6),
                                    offset: Offset(4, 4),
                                    blurRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-4, -4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          distanceToOffice! > 100
                                              ? 'Diluar Area Kantor'
                                              : 'Dalam Area Kantor',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Anda harus berada dalam jarak 100m dari kantor',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Jarak: ${distanceToOffice?.toStringAsFixed(0)}m',
                                            style: TextStyle(
                                              color: Colors.red[700],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
