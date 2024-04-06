// To parse this JSON data, do
//
//     final addOnsDataModel = addOnsDataModelFromJson(jsonString);

import 'dart:convert';

List<AddOnsDataModel> addOnsDataModelFromJson(String str) => List<AddOnsDataModel>.from(json.decode(str).map((x) => AddOnsDataModel.fromJson(x)));

String addOnsDataModelToJson(List<AddOnsDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddOnsDataModel {
  int? id;
  String? name;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? price;
  String? categoryId;
  Category? category;
  dynamic subCategory;
  dynamic restaurant;
  List<dynamic>? flavourIds;

  AddOnsDataModel({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.price,
    this.categoryId,
    this.category,
    this.subCategory,
    this.restaurant,
    this.flavourIds,
  });

  factory AddOnsDataModel.fromJson(Map<String, dynamic> json) => AddOnsDataModel(
    id: json["id"],
    name: json["name"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    price: json["price"],
    categoryId: json["category_id"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    subCategory: json["sub_category"],
    restaurant: json["restaurant"],
    flavourIds: json["flavour_ids"] == null ? [] : List<dynamic>.from(json["flavour_ids"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "price": price,
    "category_id": categoryId,
    "category": category?.toJson(),
    "sub_category": subCategory,
    "restaurant": restaurant,
    "flavour_ids": flavourIds == null ? [] : List<dynamic>.from(flavourIds!.map((x) => x)),
  };
}

class Category {
  int? id;
  String? name;
  String? image;
  String? status;
  String? restaurantId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.image,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    status: json["status"],
    restaurantId: json["restaurant_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "status": status,
    "restaurant_id": restaurantId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}


