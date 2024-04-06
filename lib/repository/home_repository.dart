import 'package:figma_new_project/data/network/BaseApiService.dart';
import 'package:figma_new_project/data/network/NetworkApiService.dart';
import 'package:figma_new_project/res/app_urls.dart';

class HomeRepository {

  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getProducts() async {
    try {
      dynamic response =
      await _apiService.getGetApiResponse(AppUrls.productsEndPoint);
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> getCategories() async {
    try {
      dynamic response =
      await _apiService.getGetApiResponse(AppUrls.categoriesEndPoint);
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

}