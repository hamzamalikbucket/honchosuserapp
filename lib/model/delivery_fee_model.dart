// To parse this JSON data, do
//
//     final deliveryFeeModel = deliveryFeeModelFromJson(jsonString);

import 'dart:convert';

DeliveryFeeModel deliveryFeeModelFromJson(String str) => DeliveryFeeModel.fromJson(json.decode(str));

String deliveryFeeModelToJson(DeliveryFeeModel data) => json.encode(data.toJson());

class DeliveryFeeModel {
  int? id;
  String? freeDelivery;
  String? basicDeliveryCharge;
  String? chargePerKilo;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? deliveryFee;

  DeliveryFeeModel({
    this.id,
    this.freeDelivery,
    this.basicDeliveryCharge,
    this.chargePerKilo,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deliveryFee,
  });

  factory DeliveryFeeModel.fromJson(Map<String, dynamic> json) => DeliveryFeeModel(
    id: json["id"],
    freeDelivery: json["free_delivery"],
    basicDeliveryCharge: json["basic_delivery_charge"],
    chargePerKilo: json["charge_per_kilo"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deliveryFee: json["delivery_fee"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "free_delivery": freeDelivery,
    "basic_delivery_charge": basicDeliveryCharge,
    "charge_per_kilo": chargePerKilo,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "delivery_fee": deliveryFee,
  };
}
