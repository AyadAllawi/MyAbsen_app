class Endpoint {
  static const String baseURL = "https://appabsensi.mobileprojp.com";
  static const String register = "$baseURL/api/register";
  static const String login = "$baseURL/api/login";
  static const String checkIn = "$baseURL/api/absen/check-in";
  static const String checkOut = "$baseURL/api/absen/check-out";
  static const String izin = "$baseURL/api/izin";
  static const String deviceToken = "$baseURL/api/device-token";
  static String absenToday(String date) =>
      "$baseURL/api/absen/today?attendance_date=$date";
  static String absenStats(String start, String end) =>
      "$baseURL/api/absen/stats?start=$start&end=$end";
  static const String deleteAbsen = "$baseURL/api/absen/today?attendance_date";
  static const String profile = "$baseURL/api/profile";
  static const String training = "$baseURL/api/trainings";
  static const String batches = "$baseURL/api/batches";
  static const String history = "$baseURL/api/absen/history";
}