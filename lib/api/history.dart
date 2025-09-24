import 'dart:async';
import 'dart:convert';

import 'package:MyAbsen/api/endpoint/endpoint.dart';
import 'package:MyAbsen/model/delete_absen.dart';
import 'package:MyAbsen/model/history.dart';
import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:http/http.dart' as http;

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

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        return GetHistoryModel.fromJson(jsonResponse);
      } else {
        return GetHistoryModel(message: "Tidak ada data riwayat", data: []);
      }
    } else {
      throw Exception(
        "Gagal mengambil riwayat absensi. Status code: ${response.statusCode}",
      );
    }
  }

  static Future<DeleteAbsenModel> deleteAbsen({required int idAbsen}) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }
    final url = Uri.parse('${Endpoint.deleteAbsen}/$idAbsen');

    // UBAH BAGIAN INI
    final res = await http
        .delete(
          url,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(
          const Duration(seconds: 10), // <-- TAMBAHKAN INI
          onTimeout: () {
            // Ini akan dijalankan jika waktu tunggu habis
            throw TimeoutException('Koneksi ke server terputus, coba lagi.');
          },
        );

    // Sisa kodenya tetap sama
    if (res.statusCode == 200) {
      return deleteAbsenModelFromJson(res.body);
    } else {
      try {
        final errorBody = json.decode(res.body);
        final errorMessage =
            errorBody['message'] ?? 'Gagal menghapus data absen.';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception(
          'Gagal menghapus data absen. Status: ${res.statusCode}',
        );
      }
    }
  }
}
