import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // ⬅️ buat format tanggal & jam
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/model/absen_chek_in.dart';
import 'package:myabsen_project/model/absen_chek_out.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class AttendanceAPI {
  static dynamic _safeDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (e) {
      return null;
    }
  }

  // ✅ Check-In
  static Future<AbsenCheckInModel> checkIn({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);
    final token = await PreferenceHandler.getToken();

    // ✅ format jam & tanggal sesuai backend
    String checkinTime = DateFormat('HH:mm').format(DateTime.now());
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": today,
        "check_in": checkinTime, // ⬅️ sesuai API
        "check_in_lat": lat.toString(),
        "check_in_lng": lng.toString(),
        "check_in_address": address,
      }),
    );

    final body = _safeDecode(res.body);
    if (res.statusCode == 200) return AbsenCheckInModel.fromJson(body);
    throw Exception(body?["message"] ?? "Gagal check-in");
  }

  // ✅ Check-Out
  static Future<AbsenCheckOutModel> checkOut({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkOut);
    final token =
        await PreferenceHandler.getToken(); // ambil token dari SharedPreference

    // ✅ format jam & tanggal
    String checkoutTime = DateFormat('HH:mm').format(DateTime.now());
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": today,
        "check_out": checkoutTime,
        "check_out_lat": lat.toString(),
        "check_out_lng": lng.toString(),
        "check_out_address": address,
      }),
    );

    final body = _safeDecode(res.body);

    if (res.statusCode == 200) {
      return AbsenCheckOutModel.fromJson(body);
    } else {
      throw Exception(body?["message"] ?? "Gagal check-out");
    }
  }

  // ✅ Ambil data absen hari ini
  static Future<dynamic> getToday(String date) async {
    final url = Uri.parse("${Endpoint.absenToday}?attendance_date=$date");
    final token = await PreferenceHandler.getToken();
    final res = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    final body = _safeDecode(res.body);
    if (res.statusCode == 200) return body;
    throw Exception(body?["message"] ?? "Gagal mengambil absen hari ini");
  }

  // ✅ Ambil statistik absen
  static Future<dynamic> getStats() async {
    final url = Uri.parse(Endpoint.absenStats);
    final token = await PreferenceHandler.getToken();
    final res = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    final body = _safeDecode(res.body);
    if (res.statusCode == 200) return body;
    throw Exception(body?["message"] ?? "Gagal mengambil stats");
  }
}
