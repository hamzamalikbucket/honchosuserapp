import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/cartModel.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/model/restaurant_model.dart';
import 'package:figma_new_project/view/screen/checkout/checkout_screen.dart';
import 'package:figma_new_project/view/screen/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartController = Get.put(AddToCartController());
  int y = 0;
  List<CartModel> cartList = [];
  List<List<int>> addOnsIdsList = [];
  List<ProductModel> _productList = [];
  bool isLoading = false;
  int quantity = 1, selectedIndex = -1;
  String emptyCart = '';
  List<int> addOns = [];
  int total = 0;
  List<RestaurantModel> restaurantList = [];

  List<FoodItem> items = [
    FoodItem(
      image: 'assets/images/cart.png',
      title: 'Family Meal',
      description: 'Single burger with beef',
    ),
    FoodItem(
      image: 'assets/images/cart.png',
      title: 'Double Up',
      description: 'Single burger with beef',
    ),
    FoodItem(
      image: 'assets/images/cart.png',
      title: 'Sushi Pasta',
      description: 'Single burger with beef',
    ),
  ];

  List<FoodItem> total1 = [
    FoodItem(image: '2', title: '10', description: ''),
    FoodItem(image: '1', title: '8', description: ''),
    FoodItem(image: '0', title: '0', description: ''),
  ];

  getAddedCart() async {
    setState(() {
      cartList.clear();
      y = 1;
      isLoading = true;
    });
    try {
      var headers = {'Cookie': 'restaurant_session=$cookie'};
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/cart'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        cartController.fetchCartItems();
        setState(() {
          cartList = List<CartModel>.from(json.decode(responseData).map((x) => CartModel.fromJson(x)));
          emptyCart = 'no';
          isLoading = false;
        });

        if (cartList.isNotEmpty) {
          getAddOnIds(cartList);
        }
      } else {
        if (cartList.isEmpty) {
          setState(() {
            emptyCart = 'yes';
            isLoading = false;
          });
        }
        print(response.reasonPhrase);
        cartController.fetchCartItems();
      }
    } catch (e) {
      cartController.fetchCartItems();
      print('In catch error');
      if (cartList.isEmpty) {
        setState(() {
          emptyCart = 'yes';
        });
      }
      setState(() {
        isLoading = false;
      });
      log(e.toString());
    }
  }

  getAddOnIds(List<CartModel> cartList) {
    List<int> adds = [];
    List<int> addsTwo = [];
    setState(() {
      adds.clear();
      addOnsIdsList.clear();
      addOnsIdsList = List<List<int>>.generate(cartList.length, (index) => [index]);
    });
    for (int i = 0; i < cartList.length; i++) {
      setState(() {
        adds.clear();
      });
      for (int j = 0; j < cartList[i].addon!.length; j++) {
        setState(() {
          adds.add(int.parse(cartList[i].addon![j].addonId.toString()));
        });

        if (cartList[i].addon!.length - 1 == j) {
          print(adds.toList().toString() + ' This is adds $i List');
          setState(() {
            addsTwo = adds;
            addOnsIdsList[i] = adds.toList();
            //  print(addOnsIdsList.toList().toString() + ' This is map');
            // adds.clear();
          });
          break;
        }
      }

      if (cartList.length - 1 == i) {
        print(addOnsIdsList.toList().toString() + ' This is map');
      }
    }
  }

  deleteCart(String cartId) async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/delete_cart/$cartId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      cartController.clearCart();
      setState(() {
        // emptyCart = 'yes';
        emptyCart = '';
        cartList.clear();
      });

      getAddedCart();
    } else {
      print(response.reasonPhrase);
    }
  }

  void addToCart(String productId, String quantity, List<AddonElement> addonList) async {
    setState(() {
      addOns.clear();
      emptyCart = '';
    });
    var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('POST', Uri.parse('${apiBaseUrl}api/add_to_cart'));
    if (addonList.isNotEmpty) {
      for (int i = 0; i < addonList.length; i++) {
        setState(() {
          addOns.add(int.parse(addonList[i].addonId.toString()));
        });

        if (addonList.length - 1 == i) {
          request.body = json.encode({
            "product_id": productId.toString(),
            "quantity": quantity.toString(),
            "addon_ids": addOns, //addOns,//myList,//["10","14","16","21"]//jsonEncode(addOns)
          });
          request.headers.addAll(headers);
          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            setState(() {
              selectedIndex = -1;
            });
            getAddedCart();

            // Navigator.of(context,rootNavigator: false).pop();
            var snackBar = SnackBar(
              content: Text(
                'Quantity Updated',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            // print(await response.stream.bytesToString());
          } else {
            print(response.reasonPhrase);
          }
        }
      }
    } else {
      request.body = json.encode({
        "product_id": productId.toString(),
        "quantity": quantity.toString(),
        "addon_ids": addOns, //addOns,//myList,//["10","14","16","21"]//jsonEncode(addOns)
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          selectedIndex = -1;
        });
        getAddedCart();

        // Navigator.of(context,rootNavigator: false).pop();
        var snackBar = SnackBar(
          content: Text(
            'Quantity Updated',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  void addProductList() async {
    setState(() {
      _productList.clear();
    });
    for (int i = 0; i < cartList.length; i++) {
      setState(() {
        _productList.add(ProductModel(
            id: cartList[i].product!.id.toString(),
            cartId: cartList[i].id.toString(),
            image: cartList[i].product!.image.toString(),
            name: cartList[i].product!.name.toString(),
            quantity: cartList[i].quantity.toString(),
            price: cartList[i].product!.price.toString()));
      });
    }
  }

  getRestaurantTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("today");
    prefs.remove("closingTime");
    prefs.remove("openingTime");
    print('Selected ${prefs.getString('selectedRestaurant')}');
    if (prefs.getString('selectedRestaurant') != null) {
      prefs.remove("today");
      prefs.remove("closingTime");
      prefs.remove("openingTime");

      print(prefs.getString('selectedRestaurant').toString() + ' selectedRestaurant 123');
      var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/restaurants/${prefs.getString('selectedRestaurant')}'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseData = await response.stream.bytesToString();
      log('Here is the response data $responseData');
      //json.decode(responseData);
      if (response.statusCode == 200) {
        print(' 200 selectedRestaurant 123');
        restaurantList = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
        print(DateFormat('EEEE').format(DateTime.now()).toString() + ' 200 selectedRestaurant 123');

        if (restaurantList.isNotEmpty) {
          // setState(() {
          //   restaurantList = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
          // });

          if (restaurantList[0].weekIds!.isNotEmpty) {
            print(restaurantList[0].weekIds![0].toJson());

            for (int weekIds = 0; weekIds < restaurantList[0].weekIds!.length; weekIds++) {
              print(restaurantList[0].weekIds![weekIds].restaurantTimings!.name);
              print('---------here i am testing=--------${restaurantList[0].weekIds![weekIds].restaurantTimings!.name}');
              print('---------here i am testing=--------${restaurantList.toString()}');
              if (restaurantList[0].weekIds![weekIds].restaurantTimings!.name == "Mon - Sun") {
                print(' yes Mon - Sun ');
                print(' openingTime ${restaurantList[0].weekIds![weekIds].restaurantTimings!.openingTime.toString()} ');
                print(' closingTime ${restaurantList[0].weekIds![weekIds].restaurantTimings!.closingTime.toString()} ');

                prefs.setString('openingTime', restaurantList[0].weekIds![weekIds].restaurantTimings!.openingTime.toString());
                prefs.setString('today', "Mon - Sun");
                prefs.setString('closingTime', restaurantList[0].weekIds![weekIds].restaurantTimings!.closingTime.toString());
              } else if (restaurantList[0].weekIds![weekIds].restaurantTimings!.name == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                print(' openingTime ${restaurantList[0].weekIds![weekIds].restaurantTimings!.openingTime.toString()} ');
                print(' closingTime ${restaurantList[0].weekIds![weekIds].restaurantTimings!.closingTime.toString()} ');
                prefs.setString('today', restaurantList[0].weekIds![weekIds].restaurantTimings!.name.toString());
                prefs.setString('openingTime', restaurantList[0].weekIds![weekIds].restaurantTimings!.openingTime.toString());
                prefs.setString('closingTime', restaurantList[0].weekIds![weekIds].restaurantTimings!.closingTime.toString());
              }
            }
          }
        }
      } else if (response.statusCode == 302) {
      } else {}
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // cartController.fetchCartItems();
    getRestaurantTime();
    setState(() {
      emptyCart = '';
      _productList.clear();
    });
    getAddedCart();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (y == 0) {
      // getAddedCart();
    }
    // getAddOnIds(cartList);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Your Cart',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DashBoardScreen(index: 0)));
              // Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Image.asset(
                'assets/images/arrow_back.png',
                height: 20,
                width: 20,
                fit: BoxFit.scaleDown,
              ),
            )),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            emptyCart == ''
                ? Center(
                    child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  ))
                : cartList.isEmpty && emptyCart == 'yes'
                    ? Container(
                        child: Text(
                          'No cart item found',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      )
                    : SizedBox(
                        // height: size.height*0.25,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cartList.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                  ),
                                  child: Container(
                                    width: size.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: lightButtonGreyColor, spreadRadius: 2, blurRadius: 3)],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Container(
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
                                                imageUrl: imageConstUrlProduct + cartList[index].product!.image.toString(),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: size.height * 0.1,
                                            width: size.width * 0.6,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: size.width * 0.45,
                                                        child: Text(
                                                          cartList[index].product!.name.toString(),
                                                          style: TextStyle(color: Color(0xFF585858), fontSize: 14, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          deleteCart(cartList[index].id.toString());
                                                        },
                                                        child: SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: Image.asset(
                                                            'assets/images/cross.png',
                                                            fit: BoxFit.scaleDown,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 0),
                                                        child: Container(
                                                          height: size.height * 0.045,
                                                          width: size.width * 0.3,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(5),
                                                            border: Border.all(color: darkGreyTextColor1, width: 0.5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (quantity > 0) {
                                                                    setState(() {
                                                                      selectedIndex = index;
                                                                      quantity = int.parse(cartList[index].quantity.toString());
                                                                      quantity = quantity - 1;
                                                                    });
                                                                    addToCart(cartList[index].productId.toString(), quantity.toString(), cartList[index].addon!);
                                                                  }
                                                                },
                                                                child: Image.asset(
                                                                  'assets/images/minus.png',
                                                                  fit: BoxFit.scaleDown,
                                                                  height: size.height * 0.015,
                                                                  width: 20,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                              Text(
                                                                selectedIndex == index ? quantity.toString() : cartList[index].quantity.toString(),
                                                                //quantity.toString(),
                                                                style: TextStyle(color: Color(0xFF585858), fontSize: 14, fontWeight: FontWeight.w600),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    selectedIndex = index;
                                                                    quantity = int.parse(cartList[index].quantity.toString());
                                                                    quantity = quantity + 1;
                                                                  });
                                                                  addToCart(cartList[index].productId.toString(), quantity.toString(), cartList[index].addon!);
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(right: 0),
                                                                  child: Image.asset(
                                                                    'assets/images/add1.png',
                                                                    fit: BoxFit.scaleDown,
                                                                    height: size.height * 0.015,
                                                                    width: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'R ' + cartList[index].product!.price.toString(),
                                                        style: TextStyle(color: Color(0xFF585858), fontSize: 12, fontWeight: FontWeight.w600),
                                                      ),
                                                    ],
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
                              ],
                            );
                          },
                        ),
                      ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Order Amount',
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: size.height * 0.03,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Subtotal',
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Obx(() => Text(
                            'R ' + cartController.subTotal.toString(),
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                          )),
                      // Text('\$30.99',
                      //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                    ),
                  ],
                )),
            SizedBox(
              height: size.height * 0.01,
            ),
            cartController.addOnsTotal.toString() == '0'
                ? Container()
                : Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            'Add Ons total',
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Obx(() => Text(
                                'R ' + cartController.addOnsTotal.toString(),
                                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                              )),
                          // Text('\$30.99',
                          //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                        ),
                      ],
                    )),
            SizedBox(
              height: size.height * 0.01,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Total',
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Obx(() => Text(
                            'R ' + cartController.cartTotal.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                          )),
                      // Text('\$30.99',
                      //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                    ),
                  ],
                )),
            SizedBox(
              height: size.height * 0.08,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      darkRedColor,
                      lightRedColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      // elevation: MaterialStateProperty.all(3),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      print(prefs.getString("openingTime").toString());
                      print(prefs.getString("today").toString());
                      print(prefs.getString("closingTime").toString());
                      print(prefs.getString("closingTime").toString().split(":")[0]);
                      var now = DateTime.now();

                      if (prefs.getString("today") != null &&
                          (prefs.getString("today").toString() == "Mon - Sun" ||
                              prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase() ||
                              prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString())) {
                        if (now.isAfter(DateTime(
                              now.year,
                              now.month,
                              now.day,
                              int.parse(prefs.getString("openingTime").toString().split(":")[0]),
                              int.parse(prefs.getString("openingTime").toString().split(":")[1]),
                            )) &&
                            now.isBefore(DateTime(
                              now.year,
                              now.month,
                              now.day,
                              int.parse(prefs.getString("closingTime").toString().split(":")[0]),
                              int.parse(prefs.getString("closingTime").toString().split(":")[1]),
                            ))) {
                          setState(() {
                            _productList.clear();
                          });
                          for (int i = 0; i < cartList.length; i++) {
                            setState(() {
                              _productList.add(ProductModel(
                                  id: cartList[i].product!.id.toString(),
                                  cartId: cartList[i].id.toString(),
                                  image: cartList[i].product!.image.toString(),
                                  name: cartList[i].product!.name.toString(),
                                  quantity: cartList[i].quantity.toString(),
                                  price: cartList[i].product!.price.toString()));
                            });

                            print(cartList.length.toString() + ' length' + i.toString());
                            print(_productList.length.toString() + ' length');
                            if (i == cartList.length - 1) {
                              print(_productList.length.toString() + ' length');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CheckOutScreen(
                                            productList: _productList,
                                            cartItemList: cartList,
                                            addOnsIdsList: addOnsIdsList,
                                          ) //DashBoardScreen(index:5)

                                      )).then((value) {
                                setState(() {
                                  emptyCart = '';
                                  _productList.clear();
                                });
                                getAddedCart();
                              });
                            }
                          }
                        } else {
                          var snackBar = SnackBar(
                            content: Text(
                              'Restaurant is closed now.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        var snackBar = SnackBar(
                          content: Text(
                            'Restaurant is closed today.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text('Proceed to Checkout', style: buttonStyle)),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
          ],
        ),
      ),

      // SingleChildScrollView(
      //   child: Column(children: [
      //
      //
      //     SizedBox(
      //       height: size.height*0.01,
      //     ),
      //
      //
      //     cartController.productsList.isEmpty ? Center(child: CircularProgressIndicator(
      //       color: darkRedColor,
      //       strokeWidth: 1,
      //     )) :
      //     cartController.productsList.isEmpty && cartController.cartIssue.value  == 'yes' ? Container(
      //       child: Text('No cart item found',
      //         style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 15,
      //             fontWeight: FontWeight.w500),),
      //     ) :
      //     SizedBox(
      //       // height: size.height*0.25,
      //       child: ListView.builder(
      //         shrinkWrap: true,
      //         itemCount: cartController.productsList.length,
      //         scrollDirection: Axis.vertical,
      //         itemBuilder: (BuildContext context,index
      //             ) {
      //           return Column(children: [
      //             Padding(
      //               padding: const EdgeInsets.only(top: 16,),
      //               child: Container(
      //                 width: size.width*0.9,
      //                 decoration: BoxDecoration(
      //                   color: Colors.white,
      //                   borderRadius: BorderRadius.circular(10),
      //                   boxShadow: [
      //                     BoxShadow(
      //                         color: lightButtonGreyColor,
      //                         spreadRadius: 2,
      //                         blurRadius: 3
      //                     )
      //                   ],
      //                 ),
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: Row(
      //                     children: [
      //
      //                       Container(
      //                         decoration: BoxDecoration(
      //                           color: lightButtonGreyColor,
      //                           borderRadius: BorderRadius.circular(10),
      //                         ),
      //                         child: ClipRRect(
      //                           borderRadius: BorderRadius.circular(10),
      //                           child: CachedNetworkImage(
      //                             height: size.height*0.1,
      //                             width: size.width*0.25,
      //                             fit: BoxFit.cover,
      //                             imageUrl: imageConstUrlProduct+cartController.productsList[index].product!.image.toString(),
      //                             errorWidget: (context, url, error) => Icon(Icons.error),
      //                           ),
      //                         ),
      //                       ),
      //
      //                       Container(
      //                         height: size.height*0.1,
      //                         width: size.width*0.6,
      //                         child: Padding(
      //                           padding: const EdgeInsets.only(left: 8),
      //                           child: Column(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: [
      //                               SizedBox(
      //                                 height: size.height*0.01,
      //                               ),
      //                               Row(
      //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                 children: [
      //                                   Container(
      //                                     width: size.width*0.45,
      //                                     child: Text(cartController.productsList[index].product!.name.toString(),
      //                                       style: TextStyle(color: Color(0xFF585858),
      //                                           fontSize: 14,fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),),
      //                                   ),
      //                                   GestureDetector(
      //                                     onTap: () {
      //                                       cartController.deleteCart(cartController.productsList[index].id.toString());
      //                                       setState(() {
      //
      //                                       });
      //                                     },
      //                                     child: SizedBox(
      //                                       height: 20,
      //                                       width: 20,
      //                                       child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                               SizedBox(
      //                                 height: size.height*0.01,
      //                               ),
      //                               Row(
      //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                 children: [
      //                                   Padding(
      //                                     padding: const EdgeInsets.only(left: 0),
      //                                     child: Container(
      //                                       height: size.height*0.045,
      //                                       width: size.width*0.3,
      //                                       decoration: BoxDecoration(
      //                                         color: Colors.white,
      //                                         borderRadius: BorderRadius.circular(5),
      //                                         border: Border.all(color: darkGreyTextColor1,width: 0.5),
      //                                       ),
      //                                       child: Row(
      //                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //
      //                                         children: [
      //
      //                                           GestureDetector(
      //                                             onTap:() {
      //                                               if(quantity>0) {
      //                                                 setState(() {
      //                                                   selectedIndex = index;
      //                                                   quantity = int.parse(cartController.productsList[index].quantity.toString());
      //                                                   quantity = quantity -1;
      //                                                 });
      //                                                 addToCart(cartController.productsList[index].productId.toString(), quantity.toString(),cartController.productsList[index].addon!);
      //                                               }
      //                                             },
      //                                             child: Image.asset('assets/images/minus.png', fit: BoxFit.scaleDown,
      //                                               height: size.height*0.015,
      //                                               width: 20,
      //                                               color: Colors.black,
      //                                             ),
      //                                           ),
      //                                           Text(
      //                                             selectedIndex == index ? quantity.toString() :
      //                                             cartController.productsList[index].quantity.toString(),
      //                                             //quantity.toString(),
      //                                             style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
      //                                           GestureDetector(
      //                                             onTap:() {
      //                                               setState(() {
      //                                                 selectedIndex = index;
      //                                                 quantity = int.parse(cartController.productsList[index].quantity.toString());
      //                                                 quantity = quantity+1;
      //                                               });
      //                                               addToCart(cartController.productsList[index].productId.toString(), quantity.toString(),cartController.productsList[index].addon!);
      //                                             },
      //                                             child: Padding(
      //                                               padding: const EdgeInsets.only(right: 0),
      //                                               child: Image.asset('assets/images/add1.png', fit: BoxFit.scaleDown,
      //                                                 height: size.height*0.015,
      //                                                 width: 20,
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                     ),
      //                                   ),
      //                                   Text('R '+cartController.productsList[index].product!.price.toString(),
      //                                     style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
      //                                 ],
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ),
      //
      //           ],);
      //         },
      //
      //       ),
      //     ),
      //     SizedBox(
      //       height: size.height*0.03,
      //     ),
      //     Container(
      //         width: size.width,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.start,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(left: 20),
      //               child: Text(
      //                 'Order Amount',
      //                 style: TextStyle(
      //                     color: Colors.black,
      //                     fontSize: 15,
      //                     fontWeight: FontWeight.w500),
      //               ),
      //             ),
      //           ],
      //         )),
      //     SizedBox(
      //       height: size.height*0.03,
      //     ),
      //
      //     Container(
      //         width: size.width,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(left: 20),
      //               child: Text(
      //                 'Subtotal',
      //                 style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(right: 20),
      //               child: Obx(()=>Text('R '+cartController.subTotal.toString(),style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),)),
      //               // Text('\$30.99',
      //               //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
      //             ),
      //           ],
      //         )),
      //     SizedBox(
      //       height: size.height*0.01,
      //     ),
      //     cartController.addOnsTotal.toString() == '0' ? Container() :
      //     Container(
      //         width: size.width,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(left: 20),
      //               child: Text(
      //                 'Addons total',
      //                 style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(right: 20),
      //               child: Obx(()=>Text('R '+cartController.addOnsTotal.toString(),style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),)),
      //               // Text('\$30.99',
      //               //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
      //             ),
      //           ],
      //         )),
      //     SizedBox(
      //       height: size.height*0.01,
      //     ),
      //     Container(
      //         width: size.width,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(left: 20),
      //               child: Text(
      //                 'Total',
      //                 style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w600),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(right: 20),
      //               child: Obx(()=>Text('R '+cartController.cartTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w600),)),
      //               // Text('\$30.99',
      //               //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
      //             ),
      //           ],
      //         )),
      //     SizedBox(
      //       height: size.height*0.08,
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.only(left: 16,right: 16),
      //       child: Container(
      //
      //         decoration: BoxDecoration(
      //           boxShadow: [
      //             BoxShadow(
      //                 color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
      //           ],
      //           gradient: LinearGradient(
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //             stops: [0.0, 1.0],
      //             colors: [
      //               darkRedColor,
      //               lightRedColor,
      //             ],
      //           ),
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         child: ElevatedButton(
      //             style: ButtonStyle(
      //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //                 RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(10.0),
      //                 ),
      //               ),
      //               minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
      //               backgroundColor:
      //               MaterialStateProperty.all(Colors.transparent),
      //               // elevation: MaterialStateProperty.all(3),
      //               shadowColor:
      //               MaterialStateProperty.all(Colors.transparent),
      //             ),
      //
      //             onPressed: () async {
      //
      //               SharedPreferences prefs = await SharedPreferences.getInstance();
      //
      //               print(prefs.getString("openingTime").toString());
      //               print(prefs.getString("today").toString());
      //               print(prefs.getString("closingTime").toString());
      //               print(prefs.getString("closingTime").toString().split(":")[0]);
      //               var now = DateTime.now();
      //
      //
      //               if(
      //
      //               prefs.getString("today") != null &&
      //                   (
      //                       prefs.getString("today").toString() == "Mon - Sun" || prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase() || prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString()
      //                   )
      //
      //
      //               ) {
      //
      //                 if(
      //
      //                 now.isAfter(DateTime(now.year, now.month, now.day,
      //                   int.parse(prefs.getString("openingTime").toString().split(":")[0]),
      //                   int.parse(prefs.getString("openingTime").toString().split(":")[1]),
      //                 ))
      //                     && now.isBefore(
      //                     DateTime(now.year, now.month, now.day,
      //                       int.parse(prefs.getString("closingTime").toString().split(":")[0]),
      //                       int.parse(prefs.getString("closingTime").toString().split(":")[1]),
      //
      //                     )
      //
      //                 )
      //
      //                 ) {
      //
      //                   setState(() {
      //                     _productList.clear();
      //                   });
      //                   for(int i=0; i<cartList.length; i++) {
      //                     setState(() {
      //                       _productList.add(
      //                           ProductModel(
      //                               id: cartList[i].product!.id.toString(),
      //                               cartId: cartList[i].id.toString(),
      //                               image: cartList[i].product!.image.toString(),
      //                               name: cartList[i].product!.name.toString(),
      //                               quantity: cartList[i].quantity.toString(),
      //                               price: cartList[i].product!.price.toString())
      //                       );
      //                     });
      //
      //                     print(cartList.length.toString() + ' length' + i.toString());
      //                     print(_productList.length.toString() + ' length');
      //                     if(i==cartList.length-1) {
      //                       print(_productList.length.toString() + ' length');
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(builder: (context) =>
      //                               CheckOutScreen(productList: _productList,cartItemList: cartList,addOnsIdsList: addOnsIdsList,)//DashBoardScreen(index:5)
      //
      //                           )).then((value) {
      //
      //                         setState(() {
      //                           emptyCart = '';
      //                           _productList.clear();
      //                         });
      //                         getAddedCart();
      //
      //                       });
      //                     }
      //
      //
      //                   }
      //
      //
      //
      //
      //
      //
      //                 }
      //                 else {
      //
      //                   var snackBar = SnackBar(content: Text('Restaurant is closed now.'
      //                     ,style: TextStyle(color: Colors.white),),
      //                     backgroundColor: Colors.red,
      //                   );
      //                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //
      //                 }
      //
      //               }
      //               else {
      //                 var snackBar = SnackBar(content: Text('Restaurant is closed today.'
      //                   ,style: TextStyle(color: Colors.white),),
      //                   backgroundColor: Colors.red,
      //                 );
      //                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //               }
      //
      //
      //
      //
      //
      //
      //
      //
      //             }, child: Text('Proceed to Checkout', style: buttonStyle)),
      //       ),
      //     ),
      //     SizedBox(
      //       height: size.height*0.02,
      //     ),
      //
      //   ],),
      // ),
    );
  }
}
