// File: lib/model/get_list_history_model.dart

import 'dart:convert';

GetListHistoryModel getListHistoryModelFromJson(String str) =>
    GetListHistoryModel.fromJson(json.decode(str));

String getListHistoryModelToJson(GetListHistoryModel data) =>
    json.encode(data.toJson());

class GetListHistoryModel {
  String? message;
  List<Datum> data; // Tidak perlu nullable karena kita handle di fromJson

  GetListHistoryModel({this.message, required this.data});

  factory GetListHistoryModel.fromJson(Map<String, dynamic> json) =>
      GetListHistoryModel(
        message: json["message"],
        data: json["data"] == null
            ? [] // Jika data dari API null, kembalikan list kosong
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? title;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? status;

  Datum({
    this.id,
    this.title,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "attendance_date": attendanceDate?.toIso8601String(),
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "status": status,
  };
}
