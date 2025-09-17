import 'dart:convert';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/models/put_profile_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class ProfileAPI {
  static Future<PutProfileModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    print("Update Profile URL: $url");
    print("Update Profile Data: {name: $name, email: $email}");

    final response = await http.put(
      url,
      body: {"name": name, "email": email},
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Update Profile Response: ${response.statusCode}");
    print("Update Profile Body: ${response.body}");

    if (response.statusCode == 200) {
      return PutProfileModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error["message"] ??
            "Update profile gagal. Status: ${response.statusCode}",
      );
    }
  }

  static Future<GetProfileModel> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Profile Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      return GetProfileModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      print(error);
      throw Exception(error["message"] ?? "Gagal mengambil profil");
    }
  }
}