import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:figma_new_project/model/category_and_products_list.dart';
import 'package:figma_new_project/model/restaurant_categories_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:figma_new_project/view/widgets/fappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scrollable_list_tabview/model/list_tab.dart';
import 'package:scrollable_list_tabview/model/scrollable_list_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import '../../../constants.dart';
import '../../../model/bannerModel.dart';
import '../../../model/get_cart_model.dart';
import '../../../model/restaurant_model.dart';
import '../../widgets/category_section.dart';
import '../auth/login/login_screen.dart';
import '../banners/banner_view.dart';
import '../chooseRestaurant/choose_restaurant_screen.dart';
import '../chooseRestaurant/restaurant_detail_screen.dart';
import '../googleMap/choose_address_screen.dart';
import '../productDetail/product_detail_screen.dart';

class HomeScreenTesting extends StatefulWidget {
  @override
  _HomeScreenTestingState createState() => _HomeScreenTestingState();
}

class _HomeScreenTestingState extends State<HomeScreenTesting> with SingleTickerProviderStateMixin {
  final TextEditingController _typeAheadController = TextEditingController();
  CupertinoSuggestionsBoxController _suggestionsBoxController = CupertinoSuggestionsBoxController();

  String token = '',
      name = '',
      address = '',
      restaurantName = '',
      restaurantId = '',
      emptyCategory = '',
      emptyProduct = '',
      profileImage = '',
      category = '',
      product = '',
      noProducts = '',
      clearSuggesstions = '';

  List<RestaurantCategoriesModel> restaurantCategoriesList = [];
  List<RestaurantCategoriesModel> restaurantCategoriesList1 = [];
  List<RestaurantModel> restaurantList = [];
  List<CategoriesProductsModel> categoriesProductsList = [];
  List<CategoriesProductsModel> eachCategoriesProductsList = [];
  List<CategoriesProductsModel> eachCategoriesProductsListTesting = [];
  List<ScrollDataModel> scrollDataModel = [];
  List<ScrollDataModel> scrollDataModelTest1 = [];
  List<CategoriesProductsModel> searchProductsList = [];
  List<ScrollableListTab> dataScrollableListTab = [];

  List<Widget> banners1 = [
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
  ];

  int loadData = 0;

  bool isCollapsed = false;
  late AutoScrollController scrollController;
  TabController? tabController;

  final double expandedHeight = 500.0;

  // final PageData data = ExampleData.data;

  final data = [
    {
      "Category A": "Category A",
      "Category B": "Category A",
      "Category C": "Category A",
      "Category": [
        {"itemCount": "1", "productId": "1", "productName": "Apple juice", "productPrice": "8"},
        {"itemCount": "1", "productId": "2", "productName": "Sandwish", "productPrice": "2"}
      ]
    },
    {
      "Category A": "Category A",
      "Category B": "Category A",
      "Category C": "Category A",
      "Category": [
        {"itemCount": "1", "productId": "1", "productName": "Apple juice", "productPrice": "8"},
        {"itemCount": "1", "productId": "2", "productName": "Sandwish", "productPrice": "2"}
      ]
    }
  ];

  List<Widget> dummy = [
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
    ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/home_1.png',
          fit: BoxFit.scaleDown,
        )),
  ];

  final double collapsedHeight = kToolbarHeight;

  final listViewKey = RectGetter.createGlobalKey();
  Map<int, dynamic> itemKeys = {};

  // prevent animate when press on tab bar
  bool pauseRectGetterIndex = false;

  bool isLoading = false;
  bool isLoadingC = false;
  int current = 0, y = 0;
  final cartController = Get.put(AddToCartController());
  List<BannerModel> bannerList = [];
  int z = 0;

  void getBanners() async {
    print('we are in banners');
    try {
      var headers = {'Cookie': 'restaurant_session=$cookie'};
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/banners'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      log('banners list status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        log('banners list body data :${responseData}');

        bannerList = List<BannerModel>.from(json.decode(responseData).map((x) => BannerModel.fromJson(x)));

        if (bannerList.isNotEmpty) {
          setState(() {
            banners1.clear();
          });

          for (int i = 0; i < bannerList.length; i++) {
            if (bannerList[i].restaurantId.toString() == restaurantId) {
              if (bannerList[i].image.toString() == 'burger.jpg') {
                setState(() {
                  banners1.add(GestureDetector(
                    onTap: () {
                      print(bannerList[i].category!.id.toString() + ' This is the cat id');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BannerView(
                                  productList: categoriesProductsList,
                                  model: bannerList[i],
                                  restaurantId: restaurantId,
                                )),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.95,
                        fit: BoxFit.fill,
                        imageUrl: 'https://www.honchos.co.za/wp-content/uploads/2022/07/about-us-banner.jpg',
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ));
                });
              } else {
                setState(() {
                  banners1.add(GestureDetector(
                    onTap: () {
                      print(bannerList[i].category!.id.toString() + ' This is the cat id');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BannerView(
                                  productList: categoriesProductsList,
                                  model: bannerList[i],
                                  restaurantId: restaurantId,
                                )),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.95,
                        fit: BoxFit.fill,
                        imageUrl: imageConstUrlBanner + bannerList[i].image.toString(),
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ));
                });
              }
            }
          }
        }

        print(bannerList.toList().toString() + ' This is banner list');
        //print(await response.stream.bytesToString());
      } else if (response.statusCode == 302) {
        print('we are in empty response.statusCode == 302');
      } else if (response.statusCode == 420) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var snackBar = SnackBar(
          content: Text(
            'Session expires login to continue',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await prefs.remove('userEmail').then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        print('we are in empty else');

        print(response.reasonPhrase.toString() + ' Hello error');
      }
    } catch (e) {
      print('Error ${e}');
      print('response after Hello getProducts' + e.toString());
    }
  }

  void getCategories() async {
    print('we are in getCategories');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loadData = 1;
      isLoadingC = true;
      restaurantCategoriesList.clear();
      restaurantCategoriesList1.clear();
    });

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
    // final data = json.decode(responseData);
    // print(data['message'].toString()+ ' Data is here');

    if (response.statusCode == 200) {
      //print('categories Status Code${restaurantCategoriesList1}');
      log('categories Status Code${responseData}');
      setState(() {
        restaurantCategoriesList1 = List<RestaurantCategoriesModel>.from(json.decode(responseData).map((x) => RestaurantCategoriesModel.fromJson(x)));
      });

      log('categories Status Code ${restaurantCategoriesList1.isEmpty}');
      if (restaurantCategoriesList1.isNotEmpty) {
        print('categories Status Code (Not Empty) ${restaurantCategoriesList1.toString()}');
        // print('we are here in isNotEmpty restaurantCategoriesList1');

        for (int i = 0; i < restaurantCategoriesList1.length; i++) {
          //if (restaurantCategoriesList1[i].restaurantId.toString() == prefs.getString('selectedRestaurant')!) {
          print('we are here in isNotEmpty restaurantCategoriesList1 ${restaurantCategoriesList1[i].name}');

          if (restaurantCategoriesList.any((element) => element.name == restaurantCategoriesList1[i].name)) {
            print('Sorry already their ${restaurantCategoriesList1[i].restaurantId.toString()} ${restaurantCategoriesList1[i].name}');
          } else {
            setState(() {
              restaurantCategoriesList.add(RestaurantCategoriesModel(
                id: restaurantCategoriesList1[i].id,
                restaurantId: restaurantCategoriesList1[i].restaurantId,
                name: restaurantCategoriesList1[i].name,
                image: restaurantCategoriesList1[i].image,
                status: restaurantCategoriesList1[i].status,
                longitude: restaurantCategoriesList1[i].longitude,
                latitude: restaurantCategoriesList1[i].latitude,
              ));
            });
          }

          if (i == restaurantCategoriesList1.length - 1) {
            setState(() {
              isLoadingC = false;
              category = 'no';
              emptyCategory = 'no';
            });
          }
          // }else{
          //   print('categories Status Code (We are in else)');
          // }

          if (i == restaurantCategoriesList1.length - 1) {
            if (restaurantCategoriesList.isEmpty) {
              // print('we are here in empty restaurantCategoriesList1');
              setState(() {
                isLoadingC = false;
                emptyCategory = 'yes';
                category = 'yes';
              });
            } else {
              //print('we are here in empty restaurantCategoriesList1');
              setState(() {
                isLoadingC = false;
                emptyCategory = 'no';
                category = 'no';
              });
            }
          }
        }
      } else if (restaurantCategoriesList1.isEmpty) {
        log('categories Status Code (Empty)');
        log('we are here in empty restaurantCategoriesList1');
        setState(() {
          isLoadingC = false;
          emptyCategory = 'yes';
          category = 'yes';
        });
      }
    } else if (response.statusCode == 302) {
      log('we are in getCategories 302');
      if (restaurantCategoriesList.isEmpty) {
        setState(() {
          emptyCategory = 'yes';
          category = 'yes';
        });
      }
      setState(() {
        isLoadingC = false;
      });
      var snackBar = SnackBar(
        content: Text(
          'Something went wrong',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (response.statusCode == 420) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var snackBar = SnackBar(
        content: Text(
          'Session expires login to continue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      await prefs.remove('userEmail').then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } else {
      log('we are in getCategories else');
      if (restaurantCategoriesList.isEmpty) {
        setState(() {
          emptyCategory = 'yes';
          category = 'yes';
        });
      }
      setState(() {
        isLoadingC = false;
      });
      log(response.reasonPhrase.toString() + ' Hello error');
    }

    try {} catch (e) {
      log('we are in getCategories catch $e');
      log(e.toString());

      if (e.toString() == 'Bad state: Response has no Location header for redirect') {}
    }
  }

  void getProducts() async {
    log('gettting products');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loadData = 1;
      y = 1;
      isLoading = true;
      categoriesProductsList.clear();
      searchProductsList.clear();
    });
    // print( ' Hello getProducts ${prefs.getString('selectedRestaurant')!}');

    try {
      var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};

      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/products'));

      request.headers.addAll(headers);
      print('response before Hello getProducts');
      http.StreamedResponse response = await request.send();
      print('response after Hello getProducts');
      print(response.statusCode.toString() + ' This is status code');
      // final data = json.decode(responseData);
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        setState(() {
          categoriesProductsList = List<CategoriesProductsModel>.from(json.decode(responseData).map((x) => CategoriesProductsModel.fromJson(x)));
          // searchProductsList = categoriesProductsList;
          setState(() {
            eachCategoriesProductsList.clear();
            searchProductsList.clear();
            eachCategoriesProductsList.add(CategoriesProductsModel(
              id: 0,
              categoryId: '',
              restaurantId: '',
              name: '',
              image: '',
              description: '',
              price: '',
            ));
          });
        });
        if (categoriesProductsList.isNotEmpty) {
          for (int i = 0; i < categoriesProductsList.length; i++) {
            // if (categoriesProductsList[i].restaurantId.toString() == prefs.getString('selectedRestaurant')!) {
               setState(() {
                 searchProductsList.add(CategoriesProductsModel(
                     id: categoriesProductsList[i].id,
                     categoryId: categoriesProductsList[i].categoryId,
                     restaurantId: categoriesProductsList[i].restaurantId,
                     name: categoriesProductsList[i].name,
                     image: categoriesProductsList[i].image,
                     description: categoriesProductsList[i].description,
                     price: categoriesProductsList[i].price,
                     category: categoriesProductsList[i].category));
                 eachCategoriesProductsList.add(CategoriesProductsModel(
                     id: categoriesProductsList[i].id,
                     categoryId: categoriesProductsList[i].categoryId,
                     restaurantId: categoriesProductsList[i].restaurantId,
                     name: categoriesProductsList[i].name,
                     image: categoriesProductsList[i].image,
                     description: categoriesProductsList[i].description,
                     price: categoriesProductsList[i].price,
                     category: categoriesProductsList[i].category));
               });
            // }
            if (i == categoriesProductsList.length - 1 && (searchProductsList.isNotEmpty && eachCategoriesProductsList.isNotEmpty)) {
              print(' we are in products i== categoriesProductsList.length-1 and going to getAllCategoriesAndTheirProducts');
              //getDataScroll();
              getAllCategoriesAndTheirProducts();
            }
          }

          setState(() {
            isLoading = false;
            product = 'yes';
          });
        } else if (categoriesProductsList.isEmpty) {
          if (categoriesProductsList.isEmpty) {
            print('we are in empty');
            setState(() {
              isLoading = false;
              emptyProduct = 'yes';
            });
          }
        }
      } else if (response.statusCode == 302) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        print('we are in empty response.statusCode == 302');
        if (categoriesProductsList.isEmpty) {
          print('we are in empty');
          setState(() {
            emptyProduct = 'yes';
          });
        }

        if (data["message"] == "No products found") {
          setState(() {
            noProducts = 'no';
            product = 'no';
          });
        }
        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(
          content: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (response.statusCode == 420) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var snackBar = SnackBar(
          content: Text(
            'Session expires login to continue',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await prefs.remove('userEmail').then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        print('we are in empty else');
        if (categoriesProductsList.isEmpty) {
          print('we are in empty');
          setState(() {
            emptyProduct = 'yes';
          });
        }
        setState(() {
          isLoading = false;
        });
        print(response.reasonPhrase.toString() + ' Hello error');
        // var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.red,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        noProducts = 'no';
        product = 'no';
      });
      print('response after Hello getProducts' + e.toString());

      if (e.toString() == 'Bad state: Response has no Location header for redirect') {
      } else if (e.toString() == 'Connection timed out') {
        print('we are in getCategories catch $e');
      }
    }
  }

  void getAllCategoriesAndTheirProducts() async {
    if (restaurantCategoriesList.isNotEmpty && eachCategoriesProductsList.isNotEmpty) {
      setState(() {
        scrollDataModel.clear();
        dataScrollableListTab.clear();
      });

      for (int restaurantCategoriesListIndex = 0; restaurantCategoriesListIndex < restaurantCategoriesList.length; restaurantCategoriesListIndex++) {
        List<CategoriesProductsModel> eachCatProduct=<CategoriesProductsModel>[];


        eachCategoriesProductsList.forEach((element) {
          if(element.categoryId.toString().isNotEmpty){
            print('cate =   ${restaurantCategoriesList[restaurantCategoriesListIndex].id.toString()}(${int.parse(element.categoryId.toString()).runtimeType}) '
                '&&&&& ${int.parse(element.categoryId.toString())}(${int.parse(element.categoryId.toString()).runtimeType}})'
                '     =======  result is ${int.parse(element.categoryId.toString())==restaurantCategoriesList[restaurantCategoriesListIndex].id}');
            if(int.parse(element.categoryId.toString())==restaurantCategoriesList[restaurantCategoriesListIndex].id){
              eachCatProduct.add(element);
            }
          }
        });


        setState(() {
          scrollDataModel.add(ScrollDataModel(category: restaurantCategoriesList[restaurantCategoriesListIndex], productList: eachCatProduct));
        });

        if(restaurantCategoriesList[restaurantCategoriesListIndex].id==eachCategoriesProductsList[restaurantCategoriesListIndex].categoryId){

        }

        if (restaurantCategoriesListIndex == restaurantCategoriesList.length - 1) {
          print('we are in cate == restaurantCategoriesList.length-1');
          print(restaurantCategoriesListIndex == restaurantCategoriesList.length - 1);
          setState(() {
            dataScrollableListTab.clear();
          });

          for (int t = 0; t < scrollDataModel.length; t++) {
            setState(
              () {
                dataScrollableListTab.add(
                  ScrollableListTab(
                    tab: ListTab(
                        label: Text(
                          scrollDataModel[t].category!.name.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        activeBackgroundColor: darkRedColor,
                        showIconOnList: false,
                        inactiveBackgroundColor: lightPeachColor,
                        borderRadius: BorderRadius.circular(30),
                        borderColor: Colors.transparent),
                    body: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 80),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: scrollDataModel[t].productList.length,
                      itemBuilder: (_, index) => index == 0
                          ? Container(
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
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                        imageUrl: imageConstUrl + scrollDataModel[t].category!.image.toString(),
                                        //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.centerLeft,
                                    height: 40,
                                    child: Text(
                                      scrollDataModel[t].category!.name.toString(),
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : scrollDataModel[t].category!.name.toString() == scrollDataModel[t].productList[index].category!.name.toString()
                              ? Container(
                                  height: 40,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: scrollDataModel[t].productList[index])));
                                    },
                                    title: Container(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            scrollDataModel[t].productList[index].name.toString(),
                                            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'R ' + scrollDataModel[t].productList[index].price.toString(),
                                            style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                    ),
                  ),
                );
              },
            );
          }
          tabController = TabController(length: scrollDataModel.length, vsync: this);

          // _block.init(this, scrollDataModel);
        } else {
          print(restaurantCategoriesListIndex == restaurantCategoriesList.length - 1);
        }
      }
    }
  }

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selectedRestaurant') != null) {
      setState(() {
        restaurantId = prefs.getString('selectedRestaurant')!;
        //name =  prefs.getString('userName')!;
      });
    }
    getCategories();
    getProducts();
    if ((prefs.getString('userPhone') == null && prefs.getString('userEmail') == null) || prefs.getString('userId') == null) {}

    if (prefs.getString('profileImage') != null) {
      setState(() {
        profileImage = prefs.getString('profileImage')!;
      });
    }
    print(profileImage.toString() + ' Profile image');

    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token')!;
      });
    }
    if (prefs.getString('userName') != null) {
      setState(() {
        name = prefs.getString('userName')!;
      });
    }
    if (prefs.getString('userAddress') != null) {
      setState(() {
        address = prefs.getString('userAddress')!;
        //name =  prefs.getString('userName')!;
      });
    }

    if (prefs.getString('delivery') != null) {
      print(prefs.getString('delivery').toString() + ' Delivery Available');
    }
  }

  getProductList() {
    setState(() {
      searchProductsList.clear();
    });

    for (int i = 0; i < cartController.serachProductsList.length; i++) {
      if (cartController.serachProductsList[i].restaurantId == restaurantId) {
        setState(() {
          searchProductsList.add(CategoriesProductsModel(
            id: cartController.serachProductsList[i].id,
            categoryId: cartController.serachProductsList[i].categoryId,
            restaurantId: cartController.serachProductsList[i].restaurantId,
            name: cartController.serachProductsList[i].name,
            image: cartController.serachProductsList[i].image,
          ));
        });
      }
    }
  }

  @override
  void initState() {
    scrollController = AutoScrollController();
    setState(() {
      clearSuggesstions = '';
      loadData = 0;
      z = 0;
      restaurantName = '';
    });
    getRestaurantDetail();

    setState(() {
      noProducts = '';
      searchProductsList.clear();
      category = '';
      product = '';
      token = '';
      emptyCategory = '';
      emptyProduct = '';
      name = '';
      isLoading = false;
      isLoadingC = false;
      restaurantCategoriesList.clear();
      categoriesProductsList.clear();
      y = 0;
    });
    cartController.fetchCartItems();
    cartController.getBanners();
    getUserData();
    getProductList();

    if (bannerList.isEmpty) {
      getBanners();
    }
    super.initState();
  }

  void getRestaurantDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('selectedRestaurant') != null) {
      setState(() {
        restaurantName = prefs.getString('restaurantName').toString();
      });

      // prefs.remove("today");
      // prefs.remove("closingTime");
      // prefs.remove("openingTime");

      print(prefs.getString('selectedRestaurant').toString() + ' selectedRestaurant 123');
      var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/restaurants/${prefs.getString('selectedRestaurant')}'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseData = await response.stream.bytesToString();
      //json.decode(responseData);
      if (response.statusCode == 200) {
        setState(() {
          restaurantList = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
        });
      } else if (response.statusCode == 302) {
      } else {}
    }
  }

  List<CategoriesProductsModel> getSuggestions(String query) {
    //searchProductsList.retainWhere((s) => s.name!.toLowerCase().toString().contains(query.toLowerCase().toString()));
    // searchProductsList.where((model) => model.name!.toLowerCase().toString().contains(query.toLowerCase().toString()));
    return searchProductsList;
  }

  @override
  void dispose() {
    scrollController.dispose();
    // tabController!.dispose();
    super.dispose();
  }

  List<int> getVisibleItemsIndex() {
    Rect? rect = RectGetter.getRectFromKey(listViewKey);
    List<int> items = [];
    if (rect == null) return items;
    itemKeys.forEach((index, key) {
      Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      if (itemRect.top > rect.bottom) return;
      if (itemRect.bottom - 120 < rect.top) return;
      items.add(index);
    });
    return items;
  }

  void onCollapsed(bool value) {
    if (this.isCollapsed == value) return;
    setState(() => this.isCollapsed = value);
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (tabController != null) {
      if (pauseRectGetterIndex) return false;
      int lastTabIndex = tabController!.length - 1;
      List<int> visibleItems = getVisibleItemsIndex();

      bool reachLastTabIndex = visibleItems.length <= 2 && visibleItems.last == lastTabIndex;
      if (reachLastTabIndex) {
        tabController!.animateTo(lastTabIndex);
      } else {
        int sumIndex = visibleItems.reduce((value, element) => value + element);
        int middleIndex = sumIndex ~/ visibleItems.length;
        if (tabController!.index != middleIndex) tabController!.animateTo(middleIndex);
      }
    }

    return false;
  }

  Future<void> animateAndScrollTo(int index) async {
    pauseRectGetterIndex = true;
    if (tabController != null) {
      tabController!.animateTo(index);
    }
    await scrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin).then(
          (value) => pauseRectGetterIndex = false,
        );
    //scrollController.animateTo(scrollController.offset+200, duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  textFieldFilterWidget() {
    final size = MediaQuery.of(context).size;
    double widthSize = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 4),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Column(
                    children: <Widget>[
                      // SizedBox(
                      //   height: 10.0,
                      // ),
                      Container(
                        width: size.width * 0.75,
                        height: size.height * 0.055,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                        child: CupertinoTypeAheadFormField(
                          getImmediateSuggestions: true,
                          suggestionsBoxController: _suggestionsBoxController,
                          suggestionsBoxDecoration: CupertinoSuggestionsBoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textFieldConfiguration: CupertinoTextFieldConfiguration(
                              controller: _typeAheadController,
                              placeholder: 'Search',
                              onChanged: (value) {
                                if (_typeAheadController.text.isEmpty) {
                                  setState(() {
                                    clearSuggesstions = 'no';
                                  });
                                } else {
                                  setState(() {
                                    clearSuggesstions = '';
                                  });
                                }
                              }),
                          suggestionsCallback: (pattern) {
                            return Future.delayed(
                              Duration(seconds: 3),
                              () => getSuggestions(pattern),
                            );
                          },
                          itemBuilder: (context, CategoriesProductsModel suggestion) {
                            return
                                // clearSuggesstions == 'no' ? Container() :
                                suggestion.name!.toLowerCase().toString().contains(_typeAheadController.text.toString().toLowerCase()) ||
                                        suggestion.category!.name!.toLowerCase().toString().contains(_typeAheadController.text.toString().toLowerCase())
                                    ? Material(
                                        child: Card(
                                          child: ListTile(
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                color: lightButtonGreyColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  height: size.height * 0.1,
                                                  width: size.width * 0.25,
                                                  fit: BoxFit.cover,
                                                  imageUrl: imageConstUrlProduct + suggestion.image.toString(),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            title: Text(suggestion.name.toString()),
                                            subtitle: Text('R ${suggestion.price.toString()}'),
                                          ),
                                        ),
                                      )
                                    : Container();
                          },
                          onSuggestionSelected: (CategoriesProductsModel suggestion) {
                            _typeAheadController.text = suggestion.name.toString();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: suggestion))).then((value) {
                              setState(() {
                                _typeAheadController.clear();
                              });
                            });
                          },
                          validator: (value) => value!.isEmpty ? 'Please select a city' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 0.05,
              ),
              GestureDetector(
                onTap: () {
                  //uploadData();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:1)));
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.9],
                        colors: [lightRedColor, darkRedColor],
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  width: size.width * 0.15,
                  height: widthSize > 700 ? size.height * 0.05 : size.height * 0.06,
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  hideoutWidget() {
    final size = MediaQuery.of(context).size;
    double widthSize = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: size.height * 0.010,
        ),
        Container(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Hello, $name !',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        SizedBox(
          height: size.height * 0.005,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (restaurantList.isNotEmpty) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(
                              image: restaurantList[0].image.toString(),
                              latitude: restaurantList[0].latitude.toString(),
                              longitude: restaurantList[0].longitude.toString(),
                              address: restaurantList[0].address.toString(),
                              phone: restaurantList[0].phoneNo.toString(),
                              name: restaurantList[0].name.toString(),
                              weekId: restaurantList[0].weekIds!,
                            )));
              }
            },
            child: Container(
              width: size.width * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: size.width * 0.6,
                    child: Text(
                      restaurantName,
                      style: TextStyle(fontFamily: 'Montserrat', color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (restaurantList.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RestaurantDetailScreen(
                                      image: restaurantList[0].image.toString(),
                                      latitude: restaurantList[0].latitude.toString(),
                                      longitude: restaurantList[0].longitude.toString(),
                                      address: restaurantList[0].address.toString(),
                                      phone: restaurantList[0].phoneNo.toString(),
                                      name: restaurantList[0].name.toString(),
                                      weekId: restaurantList[0].weekIds!,
                                    )));
                      }
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              'assets/images/info.png',
                              height: 14,
                              width: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Container(
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: size.width * 0.75,
                height: size.height * 0.055,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: CupertinoTypeAheadFormField(
                  getImmediateSuggestions: true,
                  suggestionsBoxController: _suggestionsBoxController,
                  suggestionsBoxDecoration: CupertinoSuggestionsBoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textFieldConfiguration: CupertinoTextFieldConfiguration(
                      controller: _typeAheadController,
                      placeholder: 'Search',
                      onChanged: (value) {
                        if (_typeAheadController.text.isEmpty) {
                          setState(() {
                            clearSuggesstions = 'no';
                          });
                        } else {
                          setState(() {
                            clearSuggesstions = '';
                          });
                        }
                      }),
                  suggestionsCallback: (pattern) {
                    return Future.delayed(
                      Duration(seconds: 3),
                      () => getSuggestions(pattern),
                    );
                  },
                  itemBuilder: (context, CategoriesProductsModel suggestion) {
                    return
                        // clearSuggesstions == 'no' ? Container() :
                        suggestion.name!.toLowerCase().toString().contains(_typeAheadController.text.toString().toLowerCase()) ||
                                suggestion.category!.name!.toLowerCase().toString().contains(_typeAheadController.text.toString().toLowerCase())
                            ? Material(
                                child: Card(
                                  child: ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: lightButtonGreyColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          height: size.height * 0.1,
                                          width: size.width * 0.25,
                                          fit: BoxFit.cover,
                                          imageUrl: imageConstUrlProduct + suggestion.image.toString(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    title: Text(suggestion.name.toString()),
                                    subtitle: Text('R ${suggestion.price.toString()}'),
                                  ),
                                ),
                              )
                            : Container();
                  },
                  onSuggestionSelected: (CategoriesProductsModel suggestion) {
                    _typeAheadController.text = suggestion.name.toString();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: suggestion))).then((value) {
                      setState(() {
                        _typeAheadController.clear();
                      });
                    });
                  },
                  validator: (value) => value!.isEmpty ? 'Please select a city' : null,
                ),
              ),
              GestureDetector(
                onTap: () {
                  //uploadData();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:1)));
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.9],
                        colors: [lightRedColor, darkRedColor],
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  width: size.width * 0.15,
                  height: widthSize > 700 ? size.height * 0.05 : size.height * 0.06,
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Container(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Special Offers',
                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            )),
        SizedBox(
          height: size.height * 0.01,
        ),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.topCenter,
            child: CarouselSlider(
                items: banners1.isEmpty ? dummy : banners1,
                //  items:
                //  bannerList.isEmpty ? dummy :
                //  bannerList.where((element) => element.restaurant!.id == restaurantId)
                //      .map((item) => GestureDetector(
                //    onTap: () {
                //      print(item.category!.id.toString() + ' This is the cat id on banner');
                //    },
                //        child: Container(
                //    child: ClipRRect(
                //        borderRadius: BorderRadius.circular(10),
                //        child: CachedNetworkImage(
                //          height: MediaQuery.of(context).size.height*0.2,
                //          width: MediaQuery.of(context).size.width*0.95,
                //          fit: BoxFit.fill,
                //          imageUrl:  imageConstUrlBanner+item.image.toString(),
                //          //placeholder: (context, url) => CircularProgressIndicator(),
                //          errorWidget: (context, url, error) => Icon(Icons.error),
                //        ),
                //
                //    ),
                //  ),
                //      ))
                //      .toList(),
                options: CarouselOptions(
                  height: size.height * 0.2,
                  // aspectRatio: 1/9,
                  viewportFraction: 1,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  onPageChanged: (index, reason) {
                    setState(() {
                      current = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                )),
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSmoothIndicator(
              activeIndex: current,
              count: 3, //pages.length,
              effect: const JumpingDotEffect(
                dotHeight: 10,
                dotWidth: 10,
                jumpScale: .7,
                verticalOffset: 20,
                activeDotColor: darkPeachColor,
                dotColor: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  late Size screenSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    this.screenSize = size;
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapWithSourceDestinationField()));
          },
          child: Row(
            children: [
              Icon(
                Icons.my_location,
                color: Colors.black,
                size: 15,
              ),
              SizedBox(
                width: size.width * 0.55,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address.toString()}',
                        style: TextStyle(color: Colors.black, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Change Address?',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.black,
                size: 15,
              )
            ],
          ),
        ),
        leading: GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (prefs.getDouble('lat') != null && prefs.getDouble('long') != null) {
                print(prefs.getDouble('long')!);
                print(prefs.getDouble('lat')!);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChosseRestaurantScreen(
                              status: 'delete',
                              long: prefs.getDouble('long')!,
                              lat: prefs.getDouble('lat')!,
                            )));
              } else {}
            },
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Image.asset(
                'assets/images/locationIcon.png',
                height: 20,
                width: 20,
                fit: BoxFit.scaleDown,
              ),
            )),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : RectGetter(
              key: listViewKey,
              child: NotificationListener<ScrollNotification>(
                child: buildSliverScrollView(),
                onNotification: onScrollNotification,
              ),
            ),
    );
  }

  Widget buildSliverScrollView() {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      slivers: [
        if (tabController != null) buildAppBar(),
        buildBody(),
      ],
    );
  }

  SliverAppBar buildAppBar() {
    return FAppBar(
      data: scrollDataModel,
      context: context,
      scrollController: scrollController,
      //expandedHeight: expandedHeight,
      expandedHeight: screenSize.height * 0.53,
      collapsedHeight: collapsedHeight,
      isCollapsed: isCollapsed,
      onCollapsed: onCollapsed,
      tabController: tabController!,
      onTap: (index) => animateAndScrollTo(index),
      hideoutWidget: hideoutWidget(),
      filterTextFieldWidget: textFieldFilterWidget(),
    );
  }

  SliverList buildBody() {
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(scrollDataModel.length, (index) {
          itemKeys[index] = RectGetter.createGlobalKey();
          return buildCategoryItem(index);
        }),
      ),
    );
  }

  Widget buildCategoryItem(int index) {
    return RectGetter(
      key: itemKeys[index],
      child: AutoScrollTag(
        key: ValueKey(index),
        index: index,
        controller: scrollController,
        child: CategorySection(
          category: scrollDataModel[index],
          index: index,
        ),
      ),
    );
  }

// }
}
