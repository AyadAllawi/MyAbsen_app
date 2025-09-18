import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/model/history.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class HistoryService {
  static Future<GetHistoryModel> getHistory() async {
    final url = Uri.parse(Endpoint.history);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("History Status: ${response.statusCode}");
    print("History Body: ${response.body}");

    if (response.statusCode == 200) {
      return GetHistoryModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil riwayat absensi");
    }
  }
}
