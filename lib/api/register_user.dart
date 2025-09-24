import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/model/get_bacth.dart';
import 'package:myabsen_project/model/get_list_training.dart';
import 'package:myabsen_project/model/get_profile.dart';
import 'package:myabsen_project/model/login.dart';
import 'package:myabsen_project/model/put_profile.dart';
import 'package:myabsen_project/model/register.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class AuthenticationAPI {
  // Helper: safe json decode -> returns decoded object or null
  static dynamic _safeDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (e) {
      print("JSON decode failed: $e");
      return null;
    }
  }

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

    try {
      final readImage = profilePhoto.readAsBytesSync();
      final b64 = base64Encode(readImage);
      final imageWithPrefix = "data:image/png;base64,$b64";

      final payload = {
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": imageWithPrefix,
        "batch_id": batchId,
        "training_id": trainingId,
      };

      print("REGISTER -> URL: $url");
      print("REGISTER -> Payload keys: ${payload.keys}");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = _safeDecode(response.body);
        if (body == null) {
          throw Exception(
            "Register success but response body is empty or invalid.",
          );
        }
        return RegisterModel.fromJson(body);
      } else {
        final error = _safeDecode(response.body) ?? {};
        throw Exception(
          error["message"] ??
              "Failed to Register. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }

  // NOTE: pastikan model class di model/login.dart bernama LoginModel.
  // Kalau di project lo namanya LoginAbsen, ubah signature/return sesuai model asli.
  static Future<RegisterUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    try {
      final payload = {"email": email, "password": password};

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = _safeDecode(response.body);
        if (body == null) {
          throw Exception("Login success but response body invalid.");
        }
        return RegisterUserModel.fromJson(body);
      } else {
        final error = _safeDecode(response.body) ?? {};
        throw Exception(
          error["message"] ?? "Login gagal. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  static Future<PutProfileModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login kembali.");
    }

    print("Update Profile URL: $url");
    print("Update Profile Data: {name: $name, email: $email}");

    final response = await http.put(
      url,
      body: jsonEncode({"name": name, "email": email}),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Update Profile Response: ${response.statusCode}");
    print("Update Profile Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      if (body == null) {
        throw Exception("Update profile sukses tapi response invalid.");
      }
      return PutProfileModel.fromJson(body);
    } else {
      final error = _safeDecode(response.body) ?? {};
      throw Exception(
        error["message"] ??
            "Update profile gagal. Status: ${response.statusCode}",
      );
    }
  }

  static Future<GetProfileModel> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login.");
    }

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Profile Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      if (body == null) {
        throw Exception("Gagal parsing profile response.");
      }
      return GetProfileModel.fromJson(body);
    } else {
      final error = _safeDecode(response.body) ?? {};
      print(error);
      throw Exception(error["message"] ?? "Gagal mengambil profil");
    }
  }

  static Future<GetListTrainingByIdModel> getListTraining() async {
    final url = Uri.parse(Endpoint.getTraining);
    final token = await PreferenceHandler.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login.");
    }

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("getListTraining Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      if (body == null) {
        throw Exception("Gagal parsing training response.");
      }
      return GetListTrainingByIdModel.fromJson(body);
    } else {
      final error = _safeDecode(response.body) ?? {};
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }

  static Future<GetBatchesModel> getListBatch() async {
    final url = Uri.parse(Endpoint.getBatch);
    final token = await PreferenceHandler.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login.");
    }

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("getListBatch Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = _safeDecode(response.body);
      if (body == null) {
        throw Exception("Gagal parsing batch response.");
      }
      return GetBatchesModel.fromJson(body);
    } else {
      final error = _safeDecode(response.body) ?? {};
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }
}
