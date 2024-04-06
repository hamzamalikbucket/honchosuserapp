import 'package:figma_new_project/model/restaurant_categories_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';

class ScrollDataModel {
   RestaurantCategoriesModel? category;
   List<CategoriesProductsModel> productList = [];

   ScrollDataModel({
      required this.category,
      required this.productList,
   });


}