// To parse this JSON data, do
//
//     final scrollDataModelTest = scrollDataModelTestFromJson(jsonString);

import 'dart:convert';

List<ScrollDataModelTest> scrollDataModelTestFromJson(String str) => List<ScrollDataModelTest>.from(json.decode(str).map((x) => ScrollDataModelTest.fromJson(x)));

String scrollDataModelTestToJson(List<ScrollDataModelTest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ScrollDataModelTest {
  String? categoryA;
  String? categoryB;
  String? categoryC;
  List<Category>? category;

  ScrollDataModelTest({
    this.categoryA,
    this.categoryB,
    this.categoryC,
    this.category,
  });

  factory ScrollDataModelTest.fromJson(Map<String, dynamic> json) => ScrollDataModelTest(
    categoryA: json["Category A"],
    categoryB: json["Category B"],
    categoryC: json["Category C"],
    category: json["Category"] == null ? [] : List<Category>.from(json["Category"]!.map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Category A": categoryA,
    "Category B": categoryB,
    "Category C": categoryC,
    "Category": category == null ? [] : List<dynamic>.from(category!.map((x) => x.toJson())),
  };
}

class Category {
  String? itemCount;
  String? productId;
  String? productName;
  String? productPrice;

  Category({
    this.itemCount,
    this.productId,
    this.productName,
    this.productPrice,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    itemCount: json["itemCount"],
    productId: json["productId"],
    productName: json["productName"],
    productPrice: json["productPrice"],
  );

  Map<String, dynamic> toJson() => {
    "itemCount": itemCount,
    "productId": productId,
    "productName": productName,
    "productPrice": productPrice,
  };
}
