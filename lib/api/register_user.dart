import 'dart:convert';
import 'dart:io';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/get_batches_model.dart';
import 'package:absensi_apps/models/get_list_training_model.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/models/login_model.dart';
import 'package:absensi_apps/models/put_profile_model.dart';
import 'package:absensi_apps/models/register_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class AuthenticationAPI {
  static Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required File profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);
    final readImage = profilePhoto.readAsBytesSync();
    final b64 = base64Encode(readImage);
    final imageWithPrefix = "data:image/png;base64,$b64";
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": imageWithPrefix,
        "batch_id": batchId,
        "training_id": trainingId,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return RegisterModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Failed to Register");
    }
  }

  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
      headers: {"Accept": "application/json"},
    );

    print("Login Response: ${response.body}");

    if (response.statusCode == 200) {
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Login gagal");
    }
  }

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

  static Future<GetListTrainingModel> getListTraining() async {
    final url = Uri.parse(Endpoint.training);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return GetListTrainingModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }

  static Future<GetBatchesModel> getListBatch() async {
    final url = Uri.parse(Endpoint.batches);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return GetBatchesModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }
}