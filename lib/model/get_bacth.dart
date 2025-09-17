// To parse this JSON data, do
//
//     final getBatchesModel = getBatchesModelFromJson(jsonString);

import 'dart:convert';

GetBatchesModel getBatchesModelFromJson(String str) =>
    GetBatchesModel.fromJson(json.decode(str));

String getBatchesModelToJson(GetBatchesModel data) =>
    json.encode(data.toJson());

class GetBatchesModel {
  String? message;
  List<Batches>? data;

  GetBatchesModel({this.message, this.data});

  factory GetBatchesModel.fromJson(Map<String, dynamic> json) =>
      GetBatchesModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Batches>.from(json["data"]!.map((x) => Batches.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Batches {
  int? id;
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Training>? trainings;

  Batches({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.trainings,
  });

  factory Batches.fromJson(Map<String, dynamic> json) => Batches(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    trainings: json["trainings"] == null
        ? []
        : List<Training>.from(
            json["trainings"]!.map((x) => Training.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "trainings": trainings == null
        ? []
        : List<dynamic>.from(trainings!.map((x) => x.toJson())),
  };
}

class Training {
  int? id;
  String? title;
  Pivot? pivot;

  Training({this.id, this.title, this.pivot});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "pivot": pivot?.toJson(),
  };
}

class Pivot {
  String? trainingBatchId;
  String? trainingId;

  Pivot({this.trainingBatchId, this.trainingId});

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    trainingBatchId: json["training_batch_id"],
    trainingId: json["training_id"],
  );

  Map<String, dynamic> toJson() => {
    "training_batch_id": trainingBatchId,
    "training_id": trainingId,
  };
}