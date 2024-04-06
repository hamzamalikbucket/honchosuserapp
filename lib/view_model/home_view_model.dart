import 'dart:convert';

import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/data/response/api_response.dart';
import 'package:figma_new_project/model/restaurant_categories_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:figma_new_project/repository/home_repository.dart';
import 'package:figma_new_project/utils/utils.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  final _myhomeRepo = HomeRepository();

  ApiResponse<List<CategoriesProductsModel>> productList = ApiResponse.loading();
  ApiResponse<List<RestaurantCategoriesModel>> categoriesList = ApiResponse.loading();

  setProductList(ApiResponse<List<CategoriesProductsModel>> productListData) {
    productList = productListData;
    notifyListeners();
  }
  setCategoryList(ApiResponse<List<RestaurantCategoriesModel>> categoriesListData) {
    categoriesList = categoriesListData;
    notifyListeners();
  }

  Future<void> getCategories(BuildContext context) async {
    setCategoryList(ApiResponse.loading());
    _myhomeRepo.getCategories().then((value) {
      setCategoryList(ApiResponse.completed(
          List<RestaurantCategoriesModel>.from(json.decode(value).map((x) => RestaurantCategoriesModel.fromJson(x)))));
    }).onError((error, stackTrace) {
      setCategoryList(ApiResponse.error(error.toString()));
      // if (kDebugMode) {
      //   print(error.toString());
      // }
      Utils.flushBarErrorMessage(
          error.toString(), context, darkRedColor, 'Error');
    });
  }

  Future<void> getProducts(BuildContext context) async {
    setProductList(ApiResponse.loading());
    _myhomeRepo.getProducts().then((value) {
      setProductList(ApiResponse.completed(
          List<CategoriesProductsModel>.from(json.decode(value).map((x) => CategoriesProductsModel.fromJson(x)))));
    }).onError((error, stackTrace) {
      setProductList(ApiResponse.error(error.toString()));
      // if (kDebugMode) {
      //   print(error.toString());
      // }
      Utils.flushBarErrorMessage(
          error.toString(), context, darkRedColor, 'Error');
    });
  }
}