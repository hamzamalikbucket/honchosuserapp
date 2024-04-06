import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/category_and_products_list.dart';
import 'package:figma_new_project/model/restaurant_categories_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBloc with ChangeNotifier {

  List<CategoryTab> tabs = [];
  List<RappiItems> items = [];
  TabController? tabController ;
  ScrollController scrollController = ScrollController();
  bool _listen = true;

  void init(TickerProvider ticker, List<ScrollDataModel> list ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tabController = TabController(length: list.length, vsync: ticker);
    double offsetFrom = 0.0;
    double offsetTo = 0.0;
    for(int i=0; i<list.length ; i++) {
      if( list[i].category!.id.toString() ==  prefs.getString('selectedRestaurant')!) {
        final scrollData = list[i];

        if(i> 0) {
          offsetFrom += list[i-1].productList.length * productHeight;
        }

        if(i < list.length - 1) {
          offsetTo = offsetFrom + list[i+1].productList.length * productHeight;
        } else {
          offsetTo = double.infinity;
        }

        tabs.add(CategoryTab(scrollData: scrollData, isSelected: (i==0), offsetFrom:
        categoryHeight * i + offsetFrom,
        offsetTo: offsetTo
        ));
        items.add(RappiItems(categoryItem: list[i].category,));

        for(int j=0; j<scrollData.productList.length ; j++) {
          items.add(RappiItems(product: scrollData.productList[j],));
        }

      }
    }
    scrollController.addListener(_onScrollListener);

  }





  void _onScrollListener() {

    if(_listen) {
      for(int i=0; i<tabs.length ; i++) {
        // final tab = tabs[i];
        if(scrollController.offset >= tabs[i].offsetFrom && scrollController.offset <= tabs[i].offsetTo && !tabs[i].isSelected) {
          onCategorySelected(i, animationRequired: false);
          tabController!.animateTo(i);
          break;
        }


      }
    }




  }

  void onCategorySelected(int index, {bool animationRequired = true}) async {
    final selected = tabs[index];
    print(index.toString() + ' This is index');
    print(tabs.length.toString() + ' This is index');
    for(int i=0; i<tabs.length ; i++) {
      print(selected.scrollData.category!.name == tabs[i].scrollData.category!.name);
      final condition = selected.scrollData.category!.name == tabs[i].scrollData.category!.name;
      tabs[i] = tabs[i].copyWith(condition);
      }
    notifyListeners();

    if(animationRequired) {
      _listen = false;
     await scrollController.animateTo(selected.offsetFrom, duration: const Duration(milliseconds: 200), curve: Curves.linear);
     _listen = true;
    }

   //
    
    }


    @override
  void dispose() {
    // TODO: implement dispose
      scrollController.removeListener(_onScrollListener);
    scrollController.dispose();
    if(tabController != null) {
      tabController!.dispose();
    }

      super.dispose();
  }

  }



class CategoryTab {
  ScrollDataModel scrollData;
    bool isSelected;
    double offsetFrom;
    double offsetTo;

   CategoryTab copyWith(bool selected ) => CategoryTab(scrollData: scrollData,isSelected: selected, offsetFrom: offsetFrom, offsetTo: offsetTo);

   CategoryTab({required this.scrollData, required this.isSelected, required this.offsetFrom, required this.offsetTo});



}


class RappiItems {

  RestaurantCategoriesModel? categoryItem;
  CategoriesProductsModel? product;

  RappiItems({ this.categoryItem, this.product});

  bool get isCategory =>  categoryItem != null;
}