import 'dart:convert';

import 'package:MyAbsen/api/endpoint/endpoint.dart';
import 'package:MyAbsen/model/absen_chek_in.dart';
import 'package:MyAbsen/model/absen_chek_out.dart';
import 'package:MyAbsen/model/delete_absen.dart';
import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // ⬅️ buat format tanggal & jam

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

    Future<DeleteAbsenModel> deleteAbsen({required int idAbsen}) async {
      // 1. Ambil token buat otentikasi
      final token = await PreferenceHandler.getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login ulang.");
      }

      // 2. Siapin URL-nya, lengkap dengan ID absen yang mau dihapus
      final url = Uri.parse('${Endpoint.deleteAbsen}/$idAbsen');
      print("📤 Sending DELETE request to: $url");

      // 3. Kirim request DELETE ke server
      final res = await http.delete(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // 4. Proses respons dari server
      if (res.statusCode == 200) {
        // Kalau berhasil (status code 200 OK)
        print("✅ Absen berhasil dihapus. Response: ${res.body}");
        return deleteAbsenModelFromJson(res.body);
      } else {
        // Kalau gagal
        print(
          "❌ Gagal hapus absen. Status: ${res.statusCode}, Body: ${res.body}",
        );
        // Coba ambil pesan error dari body json-nya
        final errorBody = json.decode(res.body);
        final errorMessage =
            errorBody['message'] ?? 'Gagal menghapus data absen.';
        throw Exception(errorMessage);
      }
    }

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
