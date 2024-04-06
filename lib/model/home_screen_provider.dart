import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/category_and_products_list.dart';
import 'package:figma_new_project/model/restaurant_categories_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_list_tabview/scrollable_list_tabview.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeProvider extends ChangeNotifier {
  //List<Category> _categories = [];
  var category , emptyCategory ;
  List<RestaurantCategoriesModel> restaurantCategoriesList = [];
  List<RestaurantCategoriesModel> restaurantCategoriesList1 = [];
  List<CategoriesProductsModel> categoriesProductsList = [];
  List<CategoriesProductsModel> eachCategoriesProductsList = [];
  List<CategoriesProductsModel> eachCategoriesProductsListTesting = [];
  List<ScrollDataModel> scrollDataModel = [];
  List<ScrollDataModel> scrollDataModelTest1 = [];
  List<CategoriesProductsModel> searchProductsList = [];
  int _currentTabIndex = 0;
  List<ScrollableListTab>  dataScrollableListTab = [];



  List<RestaurantCategoriesModel> get categories => restaurantCategoriesList;
  List<CategoriesProductsModel> get products => categoriesProductsList;
  List<CategoriesProductsModel> get eachCategoryProducts => eachCategoriesProductsList;
  List<ScrollableListTab> get dataScrollableList => dataScrollableListTab;

  // HomeProvider() {
  //   fetchCategories();
  //   fetchProducts();
  // }

  Future<void> fetchCategories() async {
    print('we are in getCategories');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      var headers = {
        // 'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie',
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/categories'));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {

        restaurantCategoriesList1 = List<RestaurantCategoriesModel>.from(json.decode(responseData).map((x) => RestaurantCategoriesModel.fromJson(x)));


        if(restaurantCategoriesList1.isNotEmpty) {
          print('we are here in isNotEmpty restaurantCategoriesList1');

          for(int i=0; i<restaurantCategoriesList1.length; i++) {

            if( restaurantCategoriesList1[i].restaurantId.toString() == prefs.getString('selectedRestaurant')!) {

              restaurantCategoriesList.add(
                  RestaurantCategoriesModel(
                    id: restaurantCategoriesList1[i].id,
                    restaurantId:  restaurantCategoriesList1[i].restaurantId,
                    name:  restaurantCategoriesList1[i].name,
                    image:  restaurantCategoriesList1[i].image,
                    status:  restaurantCategoriesList1[i].status,
                    longitude:  restaurantCategoriesList1[i].longitude,
                    latitude:  restaurantCategoriesList1[i].latitude,
                  )
              );
            }

            if( i == restaurantCategoriesList1.length-1 ) {
              if(restaurantCategoriesList.isEmpty) {
                // print('we are here in empty restaurantCategoriesList1');
                // setState(() {
                //   isLoadingC = false;
                //   emptyCategory = 'yes';
                //   category = 'yes';
                // });
              } else {
                //print('we are here in empty restaurantCategoriesList1');
                // setState(() {
                //   isLoadingC = false;
                //   emptyCategory = 'no';
                //   category = 'no';
                // });
              }


            }

          }

        }
        else if (restaurantCategoriesList1.isEmpty) {
          print('we are here in empty restaurantCategoriesList1');
          // setState(() {
          //   isLoadingC = false;
          //   emptyCategory = 'yes';
          //   category = 'yes';
          // });
        }
      }
      else if (response.statusCode == 302) {
        print('we are in getCategories 302');
        if(restaurantCategoriesList.isEmpty) {
          // setState(() {
          //   emptyCategory = 'yes';
          //   category = 'yes';
          // });
        }
        // setState(() {
        //   isLoadingC = false;
        // });
        // var snackBar = SnackBar(content: Text('Something went wrong'
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.red,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else if (response.statusCode == 420) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var snackBar = SnackBar(content: Text('Session expires login to continue'
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // await prefs.remove('userEmail').then((value){
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => LoginScreen()),
        //   );
        // });
      }

      else {
        print('we are in getCategories else');
        if(restaurantCategoriesList.isEmpty) {
          // setState(() {
          //   emptyCategory = 'yes';
          //   category = 'yes';
          // });
        }
        // setState(() {
        //   isLoadingC = false;
        // });
        print(response.reasonPhrase.toString() + ' Hello error');
      }
    }
    catch(e) {
      print('we are in getCategories catch $e');
      print(e.toString());

      if(e.toString() == 'Bad state: Response has no Location header for redirect') {

      }



    }
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // print( ' Hello getProducts ${prefs.getString('selectedRestaurant')!}');

    try{
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie'
      };

      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/products'));



      request.headers.addAll(headers);
      print( 'response before Hello getProducts');
      http.StreamedResponse response = await request.send();
      print( 'response after Hello getProducts');
      //print(response.statusCode.toString() + ' This is status code');
      // final data = json.decode(responseData);
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        categoriesProductsList = List<CategoriesProductsModel>.from(json.decode(responseData).map((x) => CategoriesProductsModel.fromJson(x)));
        eachCategoriesProductsList.clear();
        eachCategoriesProductsList.add(CategoriesProductsModel(
          id: 0,
          categoryId: '',
          restaurantId: '',
          name: '',
          image: '',
          description: '',
          price: '',
        ));


        if(categoriesProductsList.isNotEmpty) {



          for(int i=0; i<categoriesProductsList.length ; i++) {
            if(categoriesProductsList[i].restaurantId.toString() ==  prefs.getString('selectedRestaurant')!
            ) {

              searchProductsList.add(CategoriesProductsModel(
                  id: categoriesProductsList[i].id,
                  categoryId: categoriesProductsList[i].categoryId,
                  restaurantId: categoriesProductsList[i].restaurantId,
                  name: categoriesProductsList[i].name,
                  image: categoriesProductsList[i].image,
                  description: categoriesProductsList[i].description,
                  price: categoriesProductsList[i].price,
                  category: categoriesProductsList[i].category
              ));

                eachCategoriesProductsList.add(CategoriesProductsModel(
                    id: categoriesProductsList[i].id,
                    categoryId: categoriesProductsList[i].categoryId,
                    restaurantId: categoriesProductsList[i].restaurantId,
                    name: categoriesProductsList[i].name,
                    image: categoriesProductsList[i].image,
                    description: categoriesProductsList[i].description,
                    price: categoriesProductsList[i].price,
                    category: categoriesProductsList[i].category
                ));






            }
            if(i == categoriesProductsList.length-1 && searchProductsList.isNotEmpty && eachCategoriesProductsList.isNotEmpty) {
              print(' we are in products i== categoriesProductsList.length-1 and going to getAllCategoriesAndTheirProducts');
              //getDataScroll();
              getAllCategoriesAndTheirProducts();
            }
          }


          // setState(() {
          //   isLoading = false;
          //   product = 'yes';
          // });

        } else if(categoriesProductsList.isEmpty) {

          if(categoriesProductsList.isEmpty) {
            print('we are in empty');
            // setState(() {
            //   isLoading = false;
            //   emptyProduct = 'yes';
            // });
          }

        }

      }
      else if (response.statusCode == 302) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        print('we are in empty response.statusCode == 302');
        if(categoriesProductsList.isEmpty) {
          print('we are in empty');
          // setState(() {
          //
          //   emptyProduct = 'yes';
          // });
        }

        if(data["message"] == "No products found") {
          // setState(() {
          //   noProducts = 'no';
          //   product = 'no';
          // });
        }
        // setState(() {
        //   isLoading = false;
        //
        // });
        // var snackBar = SnackBar(content: Text('Something went wrong'
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.red,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else if (response.statusCode == 420) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // var snackBar = SnackBar(content: Text('Session expires login to continue'
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.red,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // await prefs.remove('userEmail').then((value){
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => LoginScreen()),
        //   );
        // });
      }
      else {
        print('we are in empty else');

        print(response.reasonPhrase.toString() + ' Hello error');
        // var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.red,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch(e) {



      print( 'response after Hello getProducts' + e.toString());

      if(e.toString() == 'Bad state: Response has no Location header for redirect') {

      } else if (e.toString() == 'Connection timed out') {
        print('we are in getCategories catch $e');


      }

    }
    notifyListeners();

  }


  Future<void> getAllCategoriesAndTheirProducts() async {


    if(restaurantCategoriesList.isNotEmpty && eachCategoriesProductsList.isNotEmpty) {
      // setState(() {
      //   scrollDataModel.clear();
      //   dataScrollableListTab.clear();
      // });

      for(int cate=0; cate<restaurantCategoriesList.length; cate++) {
        print('cate =  $cate  ${restaurantCategoriesList[cate].name.toString()}');
        // setState(() {
        //   eachCategoriesProductsList.clear();
        //   eachCategoriesProductsList.add(CategoriesProductsModel(
        //     id: 0,
        //     categoryId: '',
        //     restaurantId: '',
        //     name: '',
        //     image: '',
        //     description: '',
        //     price: '',
        //   ));
        // });

        scrollDataModel.add(ScrollDataModel(category: restaurantCategoriesList[cate] , productList:eachCategoriesProductsList));



        if(cate == restaurantCategoriesList.length-1) {
          print('we are in cate == restaurantCategoriesList.length-1');
          print(cate == restaurantCategoriesList.length-1);
          dataScrollableListTab.clear();


          for(int t=0;t<scrollDataModel.length; t++) {

            dataScrollableListTab.add(
                ScrollableListTab(
                    tab: ListTab(
                        label:
                        Text(
                          scrollDataModel[t].category!.name.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        activeBackgroundColor: darkRedColor, showIconOnList: false, inactiveBackgroundColor: lightPeachColor, borderRadius: BorderRadius.circular(30), borderColor: Colors.transparent ),


                    body: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: scrollDataModel[t].productList.length,
                      itemBuilder: (_, index) =>
                      index == 0 ? Container(
                        height: categoryHeight,
                        alignment: Alignment.centerLeft,
                        // padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: darkRedColor,
                        child: Column(
                          children: [
                            Container(
                              // decoration: BoxDecoration(
                              color: lightButtonGreyColor,
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              child: ClipRRect(
                                //  borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl:  imageConstUrl + scrollDataModel[t].category!
                                      .image
                                      .toString(),
                                  //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.centerLeft,
                              height: 40,
                              child: Text(scrollDataModel[t].category!.name.toString(),style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                          ],
                        ),
                      ) :
                      scrollDataModel[t].category!.name.toString() == scrollDataModel[t].productList[index].category!.name.toString() ?
                      ListTile(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => ProductDetailScreen(product: scrollDataModel[t].productList[index])));
                        },
                        leading:  Container(
                          decoration: BoxDecoration(
                            color: lightButtonGreyColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              imageUrl: imageConstUrlProduct+scrollDataModel[t].productList[index].image.toString(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                        title: Text(scrollDataModel[t].productList[index].name.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('R '+scrollDataModel[t].productList[index].price.toString(),
                          style: TextStyle(color: Colors.red, fontSize: 13,fontWeight: FontWeight.bold),),
                      ) : Container(),
                    ))
            );
          }


          // _block.init(this, scrollDataModel);
        }
        else {
          print(cate == restaurantCategoriesList.length-1);
        }
      }
    }
    notifyListeners();

  }



}