import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/model/history.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class HistoryService {
  static Future<GetHistoryModel> getHistory() async {
    final token = await PreferenceHandler.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak valid. Silakan login ulang.");
    }

    final url = Uri.parse(Endpoint.history);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("URL History: ${url.toString()}");
    print("History Status: ${response.statusCode}");
    print("History Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Periksa apakah 'data' ada dan merupakan list
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        return GetHistoryModel.fromJson(jsonResponse);
      } else {
        // Jika data kosong, kembalikan model dengan list kosong
        return GetHistoryModel(message: "Tidak ada data riwayat", data: []);
      }
    } else {
      // Lemparkan exception dengan status code
      throw Exception(
        "Gagal mengambil riwayat absensi. Status code: ${response.statusCode}",
      );
    }
  }
}
