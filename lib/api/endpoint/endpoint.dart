class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // Authentication
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";
  static const String forgotPassword = "$baseUrl/forgot-password";
  static const String resetPassword = "$baseUrl/reset-password";
  static const String getBatch = "$baseUrl/batches";
  static const String getTraining = "$baseUrl/trainings";

  // Profile
  static const String profile = "$baseUrl/profile";
  static const String profilePhoto = "$baseUrl/profile/photo";
  static const String updateProfile = "$baseUrl/profile";

  // Absensi
  static const String checkIn = "$baseUrl/absen/check-in";
  static const String checkOut = "$baseUrl/absen/check-out";
  static const String absenToday = "$baseUrl/absen/today";
  static const String absenStats = "$baseUrl/absen/stats";
  static const String history = "$baseUrl/absen/history";
  static const String izin = "$baseUrl/izin";
  static const String deleteAbsen = "$baseUrl/absen";
}
