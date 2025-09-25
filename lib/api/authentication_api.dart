import 'dart:convert';
import 'dart:io';

import 'package:MyAbsen/api/endpoint/endpoint.dart';
import 'package:MyAbsen/model/get_bacth.dart';
import 'package:MyAbsen/model/get_list_training_model.dart';
import 'package:MyAbsen/model/login.dart';
import 'package:MyAbsen/model/register.dart';
import 'package:MyAbsen/preference/shared_preference.dart';
import 'package:http/http.dart' as http;

class AuthenticationAPI {
  /// Decode JSON aman biar ga error
  static dynamic _safeDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (e) {
      print("❌ JSON Decode Error: $e");
      return null;
    }
  }

  /// Helper untuk ambil pesan error dari response
  static String _extractErrorMessage(dynamic body, String defaultMsg) {
    if (body == null) return defaultMsg;
    if (body is Map) {
      if (body["message"] != null) return body["message"].toString();
      if (body["error"] != null) return body["error"].toString();
      if (body["errors"] != null) return body["errors"].toString();
    }
    return defaultMsg;
  }

  /// REGISTER USER
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

    final readImage = await profilePhoto.readAsBytes();
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

    print("📤 REGISTER Payload: $payload");

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    final body = _safeDecode(res.body);
    print("📥 REGISTER Response: $body");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return RegisterModel.fromJson(body);
    } else {
      final msg = _extractErrorMessage(body, "Gagal register");
      throw Exception(msg);
    }
  }

  /// LOGIN USER
  static Future<RegisterUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final payload = {"email": email, "password": password};

    print("📤 LOGIN Payload: $payload");

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    final body = _safeDecode(res.body);
    print("📥 LOGIN Response: $body");

    if (res.statusCode == 200) {
      // ambil token fleksibel
      final token =
          body?["token"] ??
          body?["access_token"] ??
          body?["data"]?["token"] ??
          body?["data"]?["access_token"];

      // ambil user info fleksibel
      final user = body?["user"] ?? body?["data"]?["user"] ?? body?["data"];
      final userId = user?["id"];
      final name = user?["name"];
      final userEmail = user?["email"];
      final batch = user?["batch"]?.toString() ?? "";

      // simpan data user
      if (token != null &&
          userId != null &&
          userEmail != null &&
          name != null) {
        await PreferenceHandler.saveUserData(
          token: token.toString(),
          userId: int.tryParse(userId.toString()) ?? 0,
          email: userEmail.toString(),
          name: name.toString(),
          batch: batch,
        );
      } else if (token != null) {
        // fallback kalau cuma ada token
        await PreferenceHandler.saveToken(token.toString());
      }

      return RegisterUserModel.fromJson(body);
    } else {
      final msg = _extractErrorMessage(body, "Login gagal");
      throw Exception(msg);
    }
  }

  /// FORGOT PASSWORD
  static Future<void> forgotPassword({required String email}) async {
    final url = Uri.parse(Endpoint.forgotPassword);
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email}),
    );

    final body = _safeDecode(res.body);
    print("📥 FORGOT Response: $body");

    if (res.statusCode != 200) {
      final msg = _extractErrorMessage(body, "Gagal request forgot password");
      throw Exception(msg);
    }
  }

  /// RESET PASSWORD
  static Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);
    print("📤 Resetting password for: $email with OTP");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'otp': otp, 'password': password}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal mereset password.');
    }
    // Kalau berhasil, tidak perlu return apa-apa
  }

  /// GET LIST BATCH
  static Future<List<Batches>> getBatchList() async {
    final url = Uri.parse(Endpoint.getBatch);
    final res = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    final body = _safeDecode(res.body);
    print("📥 BATCH Response: $body");

    if (res.statusCode == 200) {
      final List data = body?["data"] ?? [];
      return data.map((e) => Batches.fromJson(e)).toList();
    } else {
      final msg = body?["message"] ?? "Gagal ambil batch list";
      throw Exception(msg);
    }
  }

  /// GET LIST TRAINING
  static Future<List<Datum>> getTrainingList() async {
    final url = Uri.parse(Endpoint.getTraining);
    final res = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    final body = _safeDecode(res.body);
    print("📥 TRAINING Response: $body");

    if (res.statusCode == 200) {
      final model = GetListHistoryModel.fromJson(body);
      return model.data ?? [];
    } else {
      final msg = body?["message"] ?? "Gagal ambil training list";
      throw Exception(msg);
    }
  }

  static Future<void> requestOtp(String email) async {
    final url = Uri.parse(Endpoint.forgotPassword);
    print("📤 Requesting OTP for: $email to URL: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal mengirim OTP.');
    }
    // Kalau berhasil, tidak perlu return apa-apa, cukup jangan error
  }

  /// LOGOUT
  static Future<void> logout() async {
    await PreferenceHandler.logout();
    print("✅ User logged out");
  }
}
