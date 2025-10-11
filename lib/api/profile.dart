import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class ProfileAPI {
  static Future<dynamic> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    // Tambahkan print ini
    print('URL Penuh untuk Profile: ${url.toString()}');

    final res = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    // Tambahkan baris ini untuk melihat status dan respons dari server
    print('Status API Profile: ${res.statusCode}');
    print('Respons API Profile: ${res.body}');

    if (res.statusCode == 200) {
      return json.decode(res.body);
    }

    final body = json.decode(res.body);
    throw Exception(body["message"] ?? "Gagal ambil profile");
  }

  // ✨ TAMBAHKAN 'async' DI SINI
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

  // ✨ TAMBAHKAN 'async' DI SINI
  static Future<dynamic> updatePhoto({required File file}) async {
    final url = Uri.parse(Endpoint.profilePhoto);
    final token = await PreferenceHandler.getToken();

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('photo', file.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) return json.decode(res.body);
    final body = json.decode(res.body);
    throw Exception(body["message"] ?? "Gagal update foto");
  }
}
