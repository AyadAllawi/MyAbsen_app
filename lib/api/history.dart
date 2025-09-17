import 'dart:convert';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class HistoryAPI {
  static Future<GetHistoryModel> getHistory() async {
    final url = Uri.parse(Endpoint.history);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Profile Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      return GetHistoryModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      print(error);
      throw Exception(error["message"] ?? "Gagal mengambil profil");
    }
  }
}