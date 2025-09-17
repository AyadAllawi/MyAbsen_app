// To parse this JSON data, do
//
//     final putProfileModel = putProfileModelFromJson(jsonString);

import 'dart:convert';

PutProfileModel putProfileModelFromJson(String str) =>
    PutProfileModel.fromJson(json.decode(str));

String putProfileModelToJson(PutProfileModel data) =>
    json.encode(data.toJson());

class PutProfileModel {
  String? message;
  Data? data;

  PutProfileModel({this.message, this.data});

  factory PutProfileModel.fromJson(Map<String, dynamic> json) =>
      PutProfileModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? batchId;
  String? trainingId;
  dynamic jenisKelamin;
  String? profilePhoto;
  String? onesignalPlayerId;

  Data({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.onesignalPlayerId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    batchId: json["batch_id"],
    trainingId: json["training_id"],
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    onesignalPlayerId: json["onesignal_player_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "batch_id": batchId,
    "training_id": trainingId,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "onesignal_player_id": onesignalPlayerId,
  };
}