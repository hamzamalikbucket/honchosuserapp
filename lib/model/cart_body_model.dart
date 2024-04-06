// To parse this JSON data, do
//
//     final cartBody = cartBodyFromJson(jsonString);

import 'dart:convert';

CartBody cartBodyFromJson(String str) => CartBody.fromJson(json.decode(str));

String cartBodyToJson(CartBody data) => json.encode(data.toJson());

class CartBody {
  String? productId;
  String? quantity;
  String? specialInstructions;
  List<int>? addonIds;

  CartBody({
    this.productId,
    this.quantity,
    this.specialInstructions,
    this.addonIds,
  });

  factory CartBody.fromJson(Map<String, dynamic> json) => CartBody(
    productId: json["product_id"],
    quantity: json["quantity"],
    specialInstructions: json["special_instruction"],
    addonIds: json["addon_ids"] == null ? [] : List<int>.from(json["addon_ids"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "quantity": quantity,
    "special_instruction": specialInstructions,
    "addon_ids": addonIds == null ? [] : List<dynamic>.from(addonIds!.map((x) => x)),
  };
}
