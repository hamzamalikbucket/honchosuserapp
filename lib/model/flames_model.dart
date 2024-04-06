// To parse this JSON data, do
//
//     final flamesModel = flamesModelFromJson(jsonString);

import 'dart:convert';

List<FlamesModel> flamesModelFromJson(String str) => List<FlamesModel>.from(json.decode(str).map((x) => FlamesModel.fromJson(x)));

String flamesModelToJson(List<FlamesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FlamesModel {
  int? id;
  String? flames;
  String? userId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  FlamesModel({
    this.id,
    this.flames,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory FlamesModel.fromJson(Map<String, dynamic> json) => FlamesModel(
    id: json["id"],
    flames: json["flames"],
    userId: json["user_id"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "flames": flames,
    "user_id": userId,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
