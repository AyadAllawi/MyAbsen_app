// To parse this JSON data, do
//
//     final getListTrainingModel = getListTrainingModelFromJson(jsonString);

import 'dart:convert';

GetListTrainingModel getListTrainingModelFromJson(String str) =>
    GetListTrainingModel.fromJson(json.decode(str));

String getListTrainingModelToJson(GetListTrainingModel data) =>
    json.encode(data.toJson());

class GetListTrainingModel {
  String? message;
  List<Datum>? data;

  GetListTrainingModel({this.message, this.data});

  factory GetListTrainingModel.fromJson(Map<String, dynamic> json) =>
      GetListTrainingModel(
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
  String? title;

  Datum({this.id, this.title});

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}