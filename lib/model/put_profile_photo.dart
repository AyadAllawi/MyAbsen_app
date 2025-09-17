// To parse this JSON data, do
//
//     final putProfilePhotoModel = putProfilePhotoModelFromJson(jsonString);

import 'dart:convert';

PutProfilePhotoModel putProfilePhotoModelFromJson(String str) =>
    PutProfilePhotoModel.fromJson(json.decode(str));

String putProfilePhotoModelToJson(PutProfilePhotoModel data) =>
    json.encode(data.toJson());

class PutProfilePhotoModel {
  String? message;
  Data? data;

  PutProfilePhotoModel({this.message, this.data});

  factory PutProfilePhotoModel.fromJson(Map<String, dynamic> json) =>
      PutProfilePhotoModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? profilePhoto;

  Data({this.profilePhoto});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}