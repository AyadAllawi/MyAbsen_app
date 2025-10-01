// model/history.dart

import 'dart:convert';

GetHistoryModel getHistoryModelFromJson(String str) =>
    GetHistoryModel.fromJson(json.decode(str));

String getHistoryModelToJson(GetHistoryModel data) =>
    json.encode(data.toJson());

class GetHistoryModel {
  String? message;
  List<Datum>? data;

  GetHistoryModel({this.message, this.data});

  factory GetHistoryModel.fromJson(Map<String, dynamic> json) =>
      GetHistoryModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? status;
  String? checkInAddress;
  String? checkOutAddress;
  String? alasanIzin;

  Datum({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.checkInAddress,
    this.checkOutAddress,
    this.alasanIzin,
  });

  // ================================================================
  //                INI BAGIAN YANG PALING PENTING
  // ================================================================
  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"], // LANGSUNG, KARENA KITA TAHU API MENGIRIM int

    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    status: json["status"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "status": status,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "alasan_izin": alasanIzin,
  };
}
