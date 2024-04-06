// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

List<BannerModel> bannerModelFromJson(String str) => List<BannerModel>.from(json.decode(str).map((x) => BannerModel.fromJson(x)));

String bannerModelToJson(List<BannerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BannerModel {
  int? id;
  String? image;
  String? restaurantId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? categoryId;
  Restaurant? restaurant;
  Category? category;

  BannerModel({
    this.id,
    this.image,
    this.restaurantId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.restaurant,
    this.category,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    id: json["id"],
    image: json["image"],
    restaurantId: json["restaurant_id"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    categoryId: json["category_id"],
    restaurant: json["restaurant"] == null ? null : Restaurant.fromJson(json["restaurant"]),
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "restaurant_id": restaurantId,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "category_id": categoryId,
    "restaurant": restaurant?.toJson(),
    "category": category?.toJson(),
  };
}

class Category {
  int? id;
  String? restaurantId;
  String? name;
  String? image;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Category({
    this.id,
    this.restaurantId,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Restaurant {
  int? id;
  String? name;
  String? image;
  String? longitude;
  String? latitude;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? address;
  dynamic weekId;
  String? phoneNo;

  Restaurant({
    this.id,
    this.name,
    this.image,
    this.longitude,
    this.latitude,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.weekId,
    this.phoneNo,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    address: json["address"],
    weekId: json["week_id"],
    phoneNo: json["phone_no"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "longitude": longitude,
    "latitude": latitude,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "address": address,
    "week_id": weekId,
    "phone_no": phoneNo,
  };
}
