import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class ProfileAPI {
  static Future<dynamic> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();
    final res = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    final body = json.decode(res.body);
    throw Exception(body["message"] ?? "Gagal ambil profile");
  }

  static Future<dynamic> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.updateProfile);
    final token = await PreferenceHandler.getToken();
    final res = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "email": email}),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    final body = json.decode(res.body);
    throw Exception(body["message"] ?? "Gagal update profile");
  }

  // ================================================================
  //         ⬇️ INI DIA PERBAIKAN FINALNYA (PAKAI BASE64) ⬇️
  // ================================================================
  static Future<dynamic> updatePhoto({required File file}) async {
    final url = Uri.parse(Endpoint.profilePhoto);
    final token = await PreferenceHandler.getToken();

    // 1. Baca file gambar menjadi bytes, lalu ubah ke Base64 string
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final imageWithPrefix = "data:image/png;base64,$base64Image";

    // 2. Kirim sebagai JSON biasa dengan method PUT
    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"profile_photo": imageWithPrefix}),
    );

    print('📸 Status Update Foto: ${response.statusCode}');
    print('📸 Body Update Foto: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    try {
      final body = json.decode(response.body);
      throw Exception(body["message"] ?? "Gagal update foto.");
    } catch (e) {
      throw Exception(
        "Gagal update foto. Server error status: ${response.statusCode}",
      );
    }
  }
}
