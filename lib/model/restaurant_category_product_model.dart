// // To parse this JSON data, do
// //
// //     final categoriesProductsModel = categoriesProductsModelFromJson(jsonString);
//
// import 'dart:convert';
//
// List<CategoriesProductsModel> categoriesProductsModelFromJson(String str) => List<CategoriesProductsModel>.from(json.decode(str).map((x) => CategoriesProductsModel.fromJson(x)));
//
// String categoriesProductsModelToJson(List<CategoriesProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class CategoriesProductsModel {
//   int? id;
//   String? categoryId;
//   String? subCategoryId;
//   String? restaurantId;
//   String? name;
//   String? image;
//   String? description;
//   String? status;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   String? price;
//   Category? category;
//   Category? subCategory;
//   Restaurant? restaurant;
//   List<FlavourId>? flavourIds;
//
//   CategoriesProductsModel({
//     this.id,
//     this.categoryId,
//     this.subCategoryId,
//     this.restaurantId,
//     this.name,
//     this.image,
//     this.description,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.price,
//     this.category,
//     this.subCategory,
//     this.restaurant,
//     this.flavourIds,
//   });
//
//   factory CategoriesProductsModel.fromJson(Map<String, dynamic> json) => CategoriesProductsModel(
//     id: json["id"],
//     categoryId: json["category_id"],
//     subCategoryId: json["sub_category_id"],
//     restaurantId: json["restaurant_id"],
//     name: json["name"],
//     image: json["image"],
//     description: json["description"],
//     status: json["status"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     price: json["price"],
//     category: json["category"] == null ? null : Category.fromJson(json["category"]),
//     subCategory: json["sub_category"] == null ? null : Category.fromJson(json["sub_category"]),
//     restaurant: json["restaurant"] == null ? null : Restaurant.fromJson(json["restaurant"]),
//     flavourIds: json["flavour_ids"] == null ? [] : List<FlavourId>.from(json["flavour_ids"]!.map((x) => FlavourId.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "category_id": categoryId,
//     "sub_category_id": subCategoryId,
//     "restaurant_id": restaurantId,
//     "name": name,
//     "image": image,
//     "description": description,
//     "status": status,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "price": price,
//     "category": category?.toJson(),
//     "sub_category": subCategory?.toJson(),
//     "restaurant": restaurant?.toJson(),
//     "flavour_ids": flavourIds == null ? [] : List<dynamic>.from(flavourIds!.map((x) => x.toJson())),
//   };
// }
//
// class Category {
//   int? id;
//   String? restaurantId;
//   String? name;
//   String? image;
//   String? status;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   String? categoryId;
//
//   Category({
//     this.id,
//     this.restaurantId,
//     this.name,
//     this.image,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.categoryId,
//   });
//
//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//     id: json["id"],
//     restaurantId: json["restaurant_id"],
//     name: json["name"],
//     image: json["image"],
//     status: json["status"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     categoryId: json["category_id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "restaurant_id": restaurantId,
//     "name": name,
//     "image": image,
//     "status": status,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "category_id": categoryId,
//   };
// }
//
//
//
//
//
//
//
// class FlavourId {
//   int? id;
//   String? flavourId;
//   String? productId;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   Flavours? flavours;
//
//   FlavourId({
//     this.id,
//     this.flavourId,
//     this.productId,
//     this.createdAt,
//     this.updatedAt,
//     this.flavours,
//   });
//
//   factory FlavourId.fromJson(Map<String, dynamic> json) => FlavourId(
//     id: json["id"],
//     flavourId: json["flavour_id"],
//     productId: json["product_id"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     flavours: json["flavours"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "flavour_id": flavourId,
//     "product_id": productId,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "flavours": flavours,
//   };
// }
//
// class Flavours {
//   int? id;
//   String? name;
//   String? status;
//   dynamic createdAt;
//   dynamic updatedAt;
//
//   Flavours({
//     this.id,
//     this.name,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory Flavours.fromJson(Map<String, dynamic> json) => Flavours(
//     id: json["id"],
//     name: json["name"],
//     status: json["status"],
//     createdAt: json["created_at"],
//     updatedAt: json["updated_at"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "status": status,
//     "created_at": createdAt,
//     "updated_at": updatedAt,
//   };
// }
//
//
//
// class Restaurant {
//   int? id;
//   String? name;
//   String? image;
//   String? longitude;
//   String? latitude;
//   String? status;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   String? address;
//   dynamic weekId;
//   String? phoneNo;
//
//   Restaurant({
//     this.id,
//     this.name,
//     this.image,
//     this.longitude,
//     this.latitude,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.address,
//     this.weekId,
//     this.phoneNo,
//   });
//
//   factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
//     id: json["id"],
//     name: json["name"],
//     image: json["image"],
//     longitude: json["longitude"],
//     latitude: json["latitude"],
//     status: json["status"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     address: json["address"],
//     weekId: json["week_id"],
//     phoneNo: json["phone_no"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "image": image,
//     "longitude": longitude,
//     "latitude": latitude,
//     "status": status,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "address": address,
//     "week_id": weekId,
//     "phone_no": phoneNo,
//   };
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

// To parse this JSON data, do
//
//     final categoriesProductsModel = categoriesProductsModelFromJson(jsonString);

import 'dart:convert';

List<CategoriesProductsModel> categoriesProductsModelFromJson(String str) => List<CategoriesProductsModel>.from(json.decode(str).map((x) => CategoriesProductsModel.fromJson(x)));

String categoriesProductsModelToJson(List<CategoriesProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesProductsModel {
  int? id;
  String? categoryId;
  String? subCategoryId;
  String? restaurantId;
  String? name;
  String? image;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? price;
  Category? category;
  Category? subCategory;
  Restaurant? restaurant;
  List<FlavourId>? flavourIds;

  CategoriesProductsModel({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.restaurantId,
    this.name,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.price,
    this.category,
    this.subCategory,
    this.restaurant,
    this.flavourIds,
  });

  factory CategoriesProductsModel.fromJson(Map<String, dynamic> json) => CategoriesProductsModel(
    id: json["id"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    price: json["price"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    subCategory: json["sub_category"] == null ? null : Category.fromJson(json["sub_category"]),
    restaurant: json["restaurant"] == null ? null : Restaurant.fromJson(json["restaurant"]),
    flavourIds: json["flavour_ids"] == null ? [] : List<FlavourId>.from(json["flavour_ids"]!.map((x) => FlavourId.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "price": price,
    "category": category?.toJson(),
    "sub_category": subCategory?.toJson(),
    "restaurant": restaurant?.toJson(),
    "flavour_ids": flavourIds == null ? [] : List<dynamic>.from(flavourIds!.map((x) => x.toJson())),
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
  String? categoryId;

  Category({
    this.id,
    this.restaurantId,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryId,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "category_id": categoryId,
  };
}



class FlavourId {
  int? id;
  String? flavourId;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Flavours? flavours;

  FlavourId({
    this.id,
    this.flavourId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.flavours,
  });

  factory FlavourId.fromJson(Map<String, dynamic> json) => FlavourId(
    id: json["id"],
    flavourId: json["flavour_id"],
    productId: json["product_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    flavours: json["flavours"] == null ? null : Flavours.fromJson(json["flavours"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "flavour_id": flavourId,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "flavours": flavours?.toJson(),
  };
}

class Flavours {
  int? id;
  String? name;
  String? status;
  dynamic createdAt;
  dynamic updatedAt;

  Flavours({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Flavours.fromJson(Map<String, dynamic> json) => Flavours(
    id: json["id"],
    name: json["name"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
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


