// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

List<CartModel> cartModelFromJson(String str) => List<CartModel>.from(json.decode(str).map((x) => CartModel.fromJson(x)));

String cartModelToJson(List<CartModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartModel {
  int? id;
  String? userId;
  String? productId;
  String? quantity;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic addonId;
  String? specialInstruction;
  User? user;
  Product? product;
  List<AddonElement>? addon;

  CartModel({
    this.id,
    this.userId,
    this.productId,
    this.quantity,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.addonId,
    this.specialInstruction,
    this.user,
    this.product,
    this.addon,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json["id"],
    userId: json["user_id"],
    productId: json["product_id"],
    quantity: json["quantity"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    addonId: json["addon_id"],
    specialInstruction: json["special_instruction"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    addon: json["addon"] == null ? [] : List<AddonElement>.from(json["addon"]!.map((x) => AddonElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "product_id": productId,
    "quantity": quantity,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "addon_id": addonId,
    "special_instruction": specialInstruction,
    "user": user?.toJson(),
    "product": product?.toJson(),
    "addon": addon == null ? [] : List<dynamic>.from(addon!.map((x) => x.toJson())),
  };
}

class AddonElement {
  int? id;
  String? addonId;
  String? cartId;
  DateTime? createdAt;
  DateTime? updatedAt;
  AddonAddon? addon;

  AddonElement({
    this.id,
    this.addonId,
    this.cartId,
    this.createdAt,
    this.updatedAt,
    this.addon,
  });

  factory AddonElement.fromJson(Map<String, dynamic> json) => AddonElement(
    id: json["id"],
    addonId: json["addon_id"],
    cartId: json["cart_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    addon: json["addon"] == null ? null : AddonAddon.fromJson(json["addon"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "addon_id": addonId,
    "cart_id": cartId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "addon": addon?.toJson(),
  };
}

class AddonAddon {
  int? id;
  String? name;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? price;
  String? categoryId;

  AddonAddon({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.price,
    this.categoryId,
  });

  factory AddonAddon.fromJson(Map<String, dynamic> json) => AddonAddon(
    id: json["id"],
    name: json["name"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    price: json["price"],
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "price": price,
    "category_id": categoryId,
  };
}

class Product {
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

  Product({
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
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
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
  };
}

class User {
  int? id;
  String? name;
  String? email;
  String? phoneNo;
  String? password;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? image;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNo,
    this.password,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phoneNo: json["phone_no"],
    password: json["password"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone_no": phoneNo,
    "password": password,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "image": image,
  };
}
