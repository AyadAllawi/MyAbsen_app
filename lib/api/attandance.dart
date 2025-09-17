import 'dart:convert';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/absen_check_out_model.dart';
import 'package:absensi_apps/models/absen_masuk_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceAPI {
  static Future<AbsenCheckInModel> checkIn({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);
    final token = await PreferenceHandler.getToken();
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm').format(now);

    final response = await http.post(
      url,
      body: {
        'attendance_date': date,
        'check_in': time,
        'check_in_lat': lat.toString(),
        'check_in_lng': lng.toString(),
        'check_in_address': address,
      },
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Check-In Status: ${response.statusCode}");
    print("Check-In Response: ${response.body}");

    if (response.statusCode == 200) {
      return AbsenCheckInModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal melakukan check-in");
    }
  }

  static Future<AbsenCheckOutModel> checkOut({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkOut);
    final token = await PreferenceHandler.getToken();

    final response = await http.post(
      url,
      body: {'lat': lat.toString(), 'lng': lng.toString(), 'address': address},
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Check-Out Status: ${response.statusCode}");
    print("Check-Out Response: ${response.body}");

    if (response.statusCode == 200) {
      return AbsenCheckOutModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal melakukan check-out");
    }
  }
}