import 'dart:convert';

import 'package:http/http.dart' as http;
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

  static Future<AbsenCheckInModel> checkIn({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkIn);
    final token = await PreferenceHandler.getToken();
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": DateTime.now().toIso8601String().split('T').first,
        "check_in": DateTime.now().toIso8601String(),
        "check_in_lat": lat.toString(),
        "check_in_lng": lng.toString(),
        "check_in_address": address,
      }),
    );
    final body = _safeDecode(res.body);
    if (res.statusCode == 200) return AbsenCheckInModel.fromJson(body);
    throw Exception(body?["message"] ?? "Gagal check-in");
  }

  static Future<AbsenCheckOutModel> checkOut({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final url = Uri.parse(Endpoint.checkOut);
    final token = await PreferenceHandler.getToken();
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "check_out": DateTime.now().toIso8601String(),
        "check_out_lat": lat.toString(),
        "check_out_lng": lng.toString(),
        "check_out_address": address,
      }),
    );
    final body = _safeDecode(res.body);
    if (res.statusCode == 200) return AbsenCheckOutModel.fromJson(body);
    throw Exception(body?["message"] ?? "Gagal check-out");
  }

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
