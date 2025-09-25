// File: lib/api/history_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:MyAbsen/api/endpoint/endpoint.dart'; // Pastikan path ini benar
import 'package:MyAbsen/model/delete_absen.dart'; // Pastikan path ini benar
import 'package:MyAbsen/model/get_list_training_model.dart';
import 'package:MyAbsen/preference/shared_preference.dart'; // Pastikan path ini benar
import 'package:http/http.dart' as http;

class HistoryService {
  // Mengembalikan model yang sudah pasti benar
  static Future<GetListHistoryModel> getHistory() async {
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
      // Langsung parse menggunakan fungsi helper dari model
      return getListHistoryModelFromJson(response.body);
    } else {
      throw Exception(
        "Gagal mengambil riwayat. Status: ${response.statusCode}",
      );
    }
  }

  static Future<DeleteAbsenModel> deleteAbsen({required int idAbsen}) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }
    final url = Uri.parse('${Endpoint.deleteAbsen}/$idAbsen');

    final res = await http
        .delete(
          url,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Koneksi ke server terputus, coba lagi.');
          },
        );

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
