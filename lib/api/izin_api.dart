// Izin
import 'dart:convert';

import 'package:MyAbsen/api/endpoint/endpoint.dart';
import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:http/http.dart' as http;


class IzinAPI {
  static Future<void> submitIzin({
    required String date,
    required String reason,
  }) async {
    final url = Uri.parse(Endpoint.izin);
    final token = await PreferenceHandler.getToken();
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"date": date, "reason": reason}),
    );
    if (res.statusCode != 200)
      throw Exception(json.decode(res.body)["message"] ?? "Gagal submit izin");
  }
}

// Delete Absen
class DeleteAPI {
  static Future<void> deleteAbsen({required String id}) async {
    final url = Uri.parse("${Endpoint.deleteAbsen}?id=$id");
    final token = await PreferenceHandler.getToken();
    final res = await http.delete(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    if (res.statusCode != 200)
      throw Exception(json.decode(res.body)["message"] ?? "Gagal hapus absen");
  }
}
