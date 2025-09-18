import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:myabsen_project/api/endpoint/endpoint.dart';
import 'package:myabsen_project/model/login.dart';
import 'package:myabsen_project/model/register.dart';
import 'package:myabsen_project/preference/shared_preference.dart';

class AuthenticationAPI {
  /// Decode JSON dengan aman biar ga langsung error
  static dynamic _safeDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (_) {
      return null;
    }
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

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    final body = _safeDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return RegisterModel.fromJson(body);
    } else {
      final msg = body?["message"] ?? "Gagal register";
      throw Exception(msg);
    }
  }

  /// LOGIN USER
  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final payload = {"email": email, "password": password};

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    final body = _safeDecode(res.body);

    if (res.statusCode == 200) {
      print("LOGIN RESPONSE: $body");

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

      // simpan data user kalau ada
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

      return LoginModel.fromJson(body);
    } else {
      final msg = body?["message"] ?? "Login gagal";
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

    if (res.statusCode != 200) {
      throw Exception(body?["message"] ?? "Gagal request forgot password");
    }
  }

  /// RESET PASSWORD
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "otp": otp, "password": password}),
    );

    final body = _safeDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body?["message"] ?? "Gagal reset password");
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await PreferenceHandler.logout();
  }
}
