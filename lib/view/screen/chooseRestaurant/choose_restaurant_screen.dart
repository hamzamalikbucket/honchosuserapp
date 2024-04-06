import 'dart:convert';
import 'dart:developer';

import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/cartModel.dart';
import 'package:figma_new_project/model/delivery_fee_model.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/model/restaurant_model.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/chooseRestaurant/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:shared_preferences/shared_preferences.dart';

class ChosseRestaurantScreen extends StatefulWidget {
  final double lat;
  final double long;
  final String status;

  const ChosseRestaurantScreen({Key? key, required this.lat, required this.long, required this.status}) : super(key: key);

  @override
  _ChosseRestaurantScreenState createState() => _ChosseRestaurantScreenState();
}

class _ChosseRestaurantScreenState extends State<ChosseRestaurantScreen> {
  List<RestaurantModel> restaurantList = [];
  List<RestaurantModel> restaurantSpecific = [];
  List<RestaurantModel> restaurantListWithDistance = [];
  List<RestaurantModel> restaurantListWithDistanceSpecific = [];
  List<RestaurantModel> restaurantListWithDMS = [];
  DeliveryFeeModel? deliveryFeeModel;
  final cartController = Get.put(AddToCartController());
  String selectedIndexCollect = '';
  String selectedIndexDeliver = '';
  String distance = '';
  bool isLoading = false;
  bool isLoading2 = false;
  String selectedIndex = '';
  String selectedIndexmark = '\'';
  String selectedIndexDistance = '';
  String selectedIndexID = '';
  List<CartModel> cartList = [];
  List<ProductModel> productList = [];
  List<Map<String, dynamic>> locationListWithDistance = [];
  List<Map<String, dynamic>> locationListWithDistanceSpecific = [];
  List<Map<String, dynamic>> _restaurantsWithDisctance = [];

  @override
  void initState() {
    // TODO: implement initState
    if (widget.status == 'delete') {
      getAddedCart();
    }

    setState(() {
      restaurantListWithDistance.clear();
      distance = '';
      _restaurantsWithDisctance.clear();
      locationListWithDistance.clear();
      selectedIndexCollect = '';
      selectedIndexDeliver = '';
      isLoading = true;
      selectedIndex = '';
      selectedIndexDistance = '';
      selectedIndexID = '';
    });
    getRestaurants();
    super.initState();
  }

  insertLocation() async {
    // Geolocator.getCurrentPosition().then((value) {
    //   setState(() {
    //     lat = value.altitude;
    //     long = value.longitude;
    //   });
    //   print('my lat long $lat $long');
    // });
    var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('POST', Uri.parse('${apiBaseUrl}api/location_insert?longitude=${widget.lat}&latitude=${widget.long}'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);
    if (response.statusCode == 200) {
      print('location Inserted');
    } else if (response.statusCode == 302) {
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
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          await response.stream.bytesToString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  bool checkDpo(String latLong) {
    String pattern = "^[-+]?([0-9]|[1-8][0-9]|90)°([0-9]|[1-5][0-9])\'([0-9]|[1-5][0-9])(\.\d+)?\"?";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(latLong))
      return false;
    else
      return true;
  }

  Future<double> distanceFromMyLocation(RestaurantModel restaurantModel) async {
    double distance =
        await Geolocator.distanceBetween(widget.lat, widget.long, double.parse(restaurantModel.latitude.toString()), double.parse(restaurantModel.longitude.toString())) / 1000;
    return distance;
  }

  getRestaurantsSpecific(String id) async {
    setState(() {
      isLoading2 = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/restaurants/$id'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    //json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        restaurantSpecific.clear();
        locationListWithDistanceSpecific.clear();
        restaurantSpecific = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
      });

      if (restaurantSpecific.isNotEmpty) {
        // associate location with distance
        for (var restaurant in restaurantSpecific) {
          // double distance = await distanceFromMyLocation(restaurant);
          setState(() {
            locationListWithDistanceSpecific.add({
              'distance': Geolocator.distanceBetween(widget.lat, widget.long, double.parse(restaurant.latitude.toString()), double.parse(restaurant.longitude.toString())) / 1000,
              'restaurantName': restaurant.name.toString(),
              'restaurantImage': restaurant.image.toString(),
              'restaurantId': restaurant.id.toString(),
              'restaurantLat': restaurant.latitude.toString(),
              'restaurantLong': restaurant.longitude.toString(),
              'weekIds': restaurant.weekIds,
              'phone': restaurant.phoneNo,
              'address': restaurant.address,
            });
            restaurantListWithDistanceSpecific.add(
              RestaurantModel(
                name: restaurant.name.toString(),
                image: restaurant.image.toString(),
                id: restaurant.id,
                latitude: restaurant.latitude.toString(),
                longitude: restaurant.longitude.toString(),
                address: restaurant.address.toString(),
                weekIds: restaurant.weekIds,
              ),
            );
          });
          if (restaurant.weekIds!.isNotEmpty) {
            print(' yes we are in weekids ');
            //  print(locationListWithDistance[index]['weekIds'][0].toJson());
            for (int weekIds = 0; weekIds < restaurant.weekIds!.length; weekIds++) {
              print(' yes we are in loop ');
              // print(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name);

              if (restaurant.weekIds![weekIds].restaurantTimings!.name == "Mon - Sun") {
                print(' yes Mon - Sun ');
                print(' openingTime ${restaurant.weekIds![weekIds].restaurantTimings!.openingTime.toString()} ');
                print(' closingTime ${restaurant.weekIds![weekIds].restaurantTimings!.closingTime.toString()} ');

                prefs.setString('openingTime', restaurant.weekIds![weekIds].restaurantTimings!.openingTime.toString());
                prefs.setString('today', "Mon - Sun");
                prefs.setString('closingTime', restaurant.weekIds![weekIds].restaurantTimings!.closingTime.toString());
                setState(() {
                  isLoading2 = false;
                });
              } else if (restaurant.weekIds![weekIds].restaurantTimings!.name == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                print(' yes we are here ');
                print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                print(' openingTime ${restaurant.weekIds![weekIds].restaurantTimings!.openingTime.toString()} ');
                print(' closingTime ${restaurant.weekIds![weekIds].restaurantTimings!.closingTime.toString()} ');
                prefs.setString('today', restaurant.weekIds![weekIds].restaurantTimings!.name.toString());
                prefs.setString('openingTime', restaurant.weekIds![weekIds].restaurantTimings!.openingTime.toString());
                prefs.setString('closingTime', restaurant.weekIds![weekIds].restaurantTimings!.closingTime.toString());
                setState(() {
                  isLoading2 = false;
                });
              }
            }
          }
        }
        // sort by distance
        locationListWithDistanceSpecific.sort((a, b) {
          double d1 = a['distance'];
          double d2 = b['distance'];
          if (d1 > d2)
            return 1;
          else if (d1 < d2)
            return -1;
          else
            return 0;
        });

        if (locationListWithDistanceSpecific.length == restaurantSpecific.length && restaurantSpecific.isNotEmpty) {
          print(locationListWithDistanceSpecific.length);
          print(restaurantSpecific.length);
          // setState(() {
          //   isLoading = false;
          // });
        }
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        setState(() {
          isLoading2 = false;
        });
        print('Empty List');
      }

      print('location Inserted');
    } else if (response.statusCode == 302) {
      // setState(() {
      //   isLoading = false;
      // });
      setState(() {
        isLoading2 = false;
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
      setState(() {
        isLoading2 = false;
      });
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
      // setState(() {
      //   isLoading = false;
      // });
      setState(() {
        isLoading2 = false;
      });
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          await response.stream.bytesToString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  getRestaurants() async {
    var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/restaurants'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    //json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        restaurantList = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
      });

      if (restaurantList.isNotEmpty) {
        // associate location with distance
        for (var restaurant in restaurantList) {
          // double distance = await distanceFromMyLocation(restaurant);
          setState(() {
            locationListWithDistance.add({
              'distance': Geolocator.distanceBetween(widget.lat, widget.long, double.parse(restaurant.latitude.toString()), double.parse(restaurant.longitude.toString())) / 1000,
              'restaurantName': restaurant.name.toString(),
              'restaurantImage': restaurant.image.toString(),
              'restaurantId': restaurant.id.toString(),
              'restaurantLat': restaurant.latitude.toString(),
              'restaurantLong': restaurant.longitude.toString(),
              'weekIds': restaurant.weekIds,
              'phone': restaurant.phoneNo,
              'address': restaurant.address,
            });
            restaurantListWithDistance.add(
              RestaurantModel(
                name: restaurant.name.toString(),
                image: restaurant.image.toString(),
                id: restaurant.id,
                latitude: restaurant.latitude.toString(),
                longitude: restaurant.longitude.toString(),
                address: restaurant.address.toString(),
                weekIds: restaurant.weekIds,
              ),
            );
          });
        }

        // sort by distance
        locationListWithDistance.sort((a, b) {
          double d1 = a['distance'];
          double d2 = b['distance'];
          if (d1 > d2)
            return 1;
          else if (d1 < d2)
            return -1;
          else
            return 0;
        });

        if (locationListWithDistance.length == restaurantList.length && restaurantList.isNotEmpty) {
          print(locationListWithDistance.length);
          print(restaurantList.length);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Empty List');
      }

      print('location Inserted');
    } else if (response.statusCode == 302) {
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
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          await response.stream.bytesToString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  deleteCart() async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};

    int number = 0;
    if (productList.isNotEmpty) {
      do {
        var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/delete_cart/${productList[number].cartId.toString()}'));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('${productList[number].cartId.toString()} deleted from cart');
        } else {
          print(response.reasonPhrase);
        }
        number++;
        if (number == productList.length) {
          cartController.clearCart();
          print('we are here in equality');
        }
      } while (number < productList.length);
    }
  }

  getAddedCart() async {
    try {
      var headers = {'Cookie': 'restaurant_session=$cookie'};

      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/cart'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        cartController.fetchCartItems();
        setState(() {
          productList.clear();
          cartList.clear();
          cartList = List<CartModel>.from(json.decode(responseData).map((x) => CartModel.fromJson(x)));
          for (int i = 0; i < cartList.length; i++) {
            setState(() {
              productList.add(ProductModel(
                  id: cartList[i].product!.id.toString(),
                  cartId: cartList[i].id.toString(),
                  image: cartList[i].product!.image.toString(),
                  name: cartList[i].product!.name.toString(),
                  quantity: cartList[i].quantity.toString(),
                  price: cartList[i].product!.price.toString()));
            });
          }
        });
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
        print(widget.lat.toString() + ' Lat');
        print(widget.long.toString() + ' Long');
      }
    } catch (e) {}
  }

  bool isDmsFormat(String latLngString) {
    RegExp dmsRegExp = RegExp(r'^\s*[+-]?\d{1,3}°\s\d{1,2}\s\d{1,2}(\.\d+)?\"[NSEW]\s*$');
    return dmsRegExp.hasMatch(latLngString);
  }

  getDeliveryFee(String distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}api/get_delivery_fee'));
    request.fields.addAll({'distance': distance});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      // print(responseData.toString() +  ' Status Code in 200');
      if (responseData == '0') {
        print(' responseData 0 ');
        prefs.setString('deliveryFee', '0');
        // print(response.statusCode.toString() +  ' in response data 0');
      } else {
        deliveryFeeModel = DeliveryFeeModel.fromJson(json.decode(responseData));

        if (deliveryFeeModel != null) {
          print(deliveryFeeModel!.deliveryFee.toString() + ' Status Code in deliveryFeeModel');
          prefs.setString('deliveryFee', deliveryFeeModel!.deliveryFee.toString());
          print(response.statusCode.toString() + ' Status Code in if deliveryFeeModel');
        }
      }
    } else {
      print(response.reasonPhrase);
      print(response.statusCode.toString() + ' Status Code in else');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(widget.lat.toString() + 'Lat is here');
    print(widget.long.toString() + 'Long is here');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(
                  //   height: size.height*0.05,
                  // ),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightRedColor.withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/images/locationIcon.png', fit: BoxFit.scaleDown,
                            height: 30,
                            width: 30,
                            // height: 80,
                            // width: 80,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.025,
                  ),

                  Container(
                    width: size.width * 0.7,
                    child: Center(
                        child: Text(
                      'Please note delivery is only available within 10 km radius. Choose your favourite restaurant and continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF585858), fontSize: 15, wordSpacing: 2, height: 1.4),
                    )),
                  ),

                  SizedBox(
                    height: size.height * 0.025,
                  ),

                  locationListWithDistance.isEmpty
                      ? Center(
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  'No Restaurants Found Nearby',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF585858), fontSize: 15, wordSpacing: 2, height: 1.4),
                                ),
                                SizedBox(
                                  height: size.height * 0.05,
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
                                        onPressed: () {
                                          Navigator.pop(context);
                                          //
                                        },
                                        child: Text('Back', style: buttonStyle)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: size.height * 0.55,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: locationListWithDistance.length,
                            itemBuilder: (BuildContext context, index) {
                              print(locationListWithDistance.length.toString() + 'Res length');
                              return GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.remove("today");
                                  prefs.remove("closingTime");
                                  prefs.remove("openingTime");

                                  // getRestaurantsSpecific(locationListWithDistance[index]['restaurantId'].toString());

                                  if (locationListWithDistance[index]['weekIds'].isNotEmpty) {
                                    print(' yes we are in weekids ');
                                    print(locationListWithDistance[index]['weekIds'][0].toJson());

                                    for (int weekIds = 0; weekIds < locationListWithDistance[index]['weekIds'].length; weekIds++) {
                                      print(' yes we are in loop ');
                                      // print(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name);

                                      if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name == "Mon - Sun") {
                                        print(' yes Mon - Sun ');
                                        print(' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                        print(' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');

                                        prefs.setString('openingTime', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString());
                                        prefs.setString('today', "Mon - Sun");
                                        prefs.setString('closingTime', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString());
                                      } else if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name ==
                                          DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                                        print(' yes we are here ');
                                        print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                                        print(' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                        print(' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');
                                        prefs.setString('today', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name.toString());
                                        prefs.setString('openingTime', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString());
                                        prefs.setString('closingTime', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString());
                                      }
                                    }
                                  }
                                  setState(() {
                                    selectedIndex = index.toString();
                                  });

                                  prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                  prefs.setString('restaurantImage', imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());
                                  prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                  if ((Geolocator.distanceBetween(widget.lat, widget.long, double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                  double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                              1000)
                                          .toInt() >
                                      10) {
                                    print('no');
                                    prefs.setString('delivery', 'no');
                                  } else {
                                    print('yes');
                                    prefs.setString('delivery', 'yes');
                                    prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                    prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                    prefs.setString('restaurantImage', imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());
                                  }
                                },
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: selectedIndex == index.toString() ? darkGreyTextColor.withOpacity(0.3) : Colors.white,
                                  // ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16),
                                        child: Container(
                                          width: size.width,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: size.height * 0.1,
                                                width: size.width * 0.28,
                                                decoration: BoxDecoration(
                                                  color: lightButtonGreyColor,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Image.network(
                                                    '${apiBaseUrl}image/restaurants/' + locationListWithDistance[index]['restaurantImage'].toString(),
                                                    fit: BoxFit.cover,
                                                    height: size.height * 0.1,
                                                    width: size.width * 0.28,
                                                    // height: 80,
                                                    // width: 80,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: Container(
                                                  // height: size.height*0.1,
                                                  width: size.width * 0.6,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: size.width * 0.38,
                                                                child: Text(
                                                                  locationListWithDistance[index]['restaurantName'].toString(),
                                                                  style: TextStyle(
                                                                      fontFamily: 'Montserrat',
                                                                      color: Color(0xFF585858),
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.bold,
                                                                      overflow: TextOverflow.ellipsis),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => RestaurantDetailScreen(
                                                                                image: locationListWithDistance[index]['restaurantImage'].toString(),
                                                                                latitude: locationListWithDistance[index]['restaurantLat'].toString(),
                                                                                longitude: locationListWithDistance[index]['restaurantLong'].toString(),
                                                                                address: locationListWithDistance[index]['address'].toString(),
                                                                                phone: locationListWithDistance[index]['phone'].toString(),
                                                                                name: locationListWithDistance[index]['restaurantName'].toString(),
                                                                                weekId: locationListWithDistance[index]['weekIds'],
                                                                              )));
                                                                },
                                                                child: Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 8),
                                                                        child: Image.asset(
                                                                          'assets/images/info.png',
                                                                          height: 13,
                                                                          width: 13,
                                                                          color: Colors.black,
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => RestaurantDetailScreen(
                                                                                        image: locationListWithDistance[index]['restaurantImage'].toString(),
                                                                                        latitude: locationListWithDistance[index]['restaurantLat'].toString(),
                                                                                        longitude: locationListWithDistance[index]['restaurantLong'].toString(),
                                                                                        address: locationListWithDistance[index]['address'].toString(),
                                                                                        phone: locationListWithDistance[index]['phone'].toString(),
                                                                                        name: locationListWithDistance[index]['restaurantName'].toString(),
                                                                                        weekId: locationListWithDistance[index]['weekIds'],
                                                                                      )));
                                                                        },
                                                                        child: Container(
                                                                          child: Text('Detail', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),

                                                        Container(
                                                          height: size.height * 0.04,
                                                          width: size.width * 0.6,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              (Geolocator.distanceBetween(
                                                                                  widget.lat,
                                                                                  widget.long,
                                                                                  double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                                  double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                              1000)
                                                                          .toInt() >
                                                                      10
                                                                  ? Padding(
                                                                      padding: const EdgeInsets.only(left: 0, right: 0),
                                                                      child: Container(
                                                                        width: size.width * 0.25,
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
                                                                          gradient: LinearGradient(
                                                                            begin: Alignment.topLeft,
                                                                            end: Alignment.bottomRight,
                                                                            stops: [0.0, 1.0],
                                                                            colors: [
                                                                              darkGreyTextColor1,
                                                                              darkGreyTextColor,
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
                                                                              minimumSize: MaterialStateProperty.all(Size(size.width * 0.2, 40)),
                                                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                              // elevation: MaterialStateProperty.all(3),
                                                                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                            ),
                                                                            onPressed: () async {
                                                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                              prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                                                              prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                                                              prefs.setString('restaurantImage',
                                                                                  imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());

                                                                              prefs.remove("today");
                                                                              prefs.remove("closingTime");
                                                                              prefs.remove("openingTime");
                                                                              //   getRestaurantsSpecific(locationListWithDistance[index]['restaurantId'].toString());

                                                                              if (locationListWithDistance[index]['weekIds'].isNotEmpty) {
                                                                                print(' yes we are in weekids ');
                                                                                print(locationListWithDistance[index]['weekIds'][0].toJson());

                                                                                for (int weekIds = 0; weekIds < locationListWithDistance[index]['weekIds'].length; weekIds++) {
                                                                                  print(' yes we are in loop ');
                                                                                  // print(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name);

                                                                                  if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name == "Mon - Sun") {
                                                                                    print(' yes Mon - Sun ');
                                                                                    print(
                                                                                        ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                    print(
                                                                                        ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');

                                                                                    prefs.setString(
                                                                                        'openingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .openingTime
                                                                                            .toString());
                                                                                    prefs.setString('today', "Mon - Sun");
                                                                                    prefs.setString(
                                                                                        'closingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .closingTime
                                                                                            .toString());
                                                                                  } else if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name ==
                                                                                      DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                                                                                    print(' yes we are here ');
                                                                                    print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                                                                                    print(
                                                                                        ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                    print(
                                                                                        ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');
                                                                                    prefs.setString('today',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name.toString());
                                                                                    prefs.setString(
                                                                                        'openingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .openingTime
                                                                                            .toString());
                                                                                    prefs.setString(
                                                                                        'closingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .closingTime
                                                                                            .toString());
                                                                                  }
                                                                                }
                                                                              }

                                                                              if ((Geolocator.distanceBetween(
                                                                                              widget.lat,
                                                                                              widget.long,
                                                                                              double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                                              double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                                          1000)
                                                                                      .toInt() >
                                                                                  10) {
                                                                                print('no');
                                                                                prefs.setString('delivery', 'no');
                                                                                setState(() {
                                                                                  selectedIndexCollect = 'no';
                                                                                  selectedIndexDeliver = 'no';
                                                                                });

                                                                                var snackBar = SnackBar(
                                                                                  duration: Duration(milliseconds: 200),
                                                                                  content: Text(
                                                                                    'Restaurant Selected',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                  backgroundColor: Colors.green,
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                              } else {
                                                                                setState(() {
                                                                                  selectedIndexCollect = 'no';
                                                                                  selectedIndexDeliver = 'yes';
                                                                                });
                                                                                print('yes');
                                                                                prefs.setString('delivery', 'yes');
                                                                                prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                                                                prefs.setString('restaurantImage',
                                                                                    imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());
                                                                              }
                                                                              setState(() {
                                                                                selectedIndexCollect = 'no';
                                                                                selectedIndex = index.toString();
                                                                              });

                                                                              var snackBar = SnackBar(
                                                                                  backgroundColor: Colors.red,
                                                                                  content: Text(
                                                                                    'Delivery is only available in 10 km radius',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ));
                                                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                              // Navigator.push(
                                                                              //     context,
                                                                              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index: 0,)));
                                                                            },
                                                                            child: Text('Deliver', style: TextStyle(color: Colors.white, fontSize: 11))),
                                                                      ),
                                                                    )
                                                                  : Padding(
                                                                      padding: const EdgeInsets.only(left: 0, right: 0),
                                                                      child: Container(
                                                                        width: size.width * 0.25,
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
                                                                          gradient: LinearGradient(
                                                                            begin: Alignment.topLeft,
                                                                            end: Alignment.bottomRight,
                                                                            stops: [0.0, 1.0],
                                                                            colors: [
                                                                              selectedIndexDeliver == 'yes' && selectedIndex == index.toString() ? Colors.green : darkRedColor,
                                                                              selectedIndexDeliver == 'yes' && selectedIndex == index.toString() ? Colors.green : lightRedColor,
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
                                                                              minimumSize: MaterialStateProperty.all(Size(size.width * 0.2, 40)),
                                                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                              // elevation: MaterialStateProperty.all(3),
                                                                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                            ),
                                                                            onPressed: () async {
                                                                              SharedPreferences prefs = await SharedPreferences.getInstance();

                                                                              prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                                                              prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                                                              prefs.setString('restaurantImage',
                                                                                  imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());

                                                                              prefs.remove("today");
                                                                              prefs.remove("closingTime");
                                                                              prefs.remove("openingTime");

                                                                              var now = DateTime.now();
                                                                              //     getRestaurantsSpecific(locationListWithDistance[index]['restaurantId'].toString());

                                                                              if (locationListWithDistance[index]['weekIds'].isNotEmpty) {
                                                                                print(' yes we are in weekids ');
                                                                                print(locationListWithDistance[index]['weekIds'][0].toJson());

                                                                                for (int weekIds = 0; weekIds < locationListWithDistance[index]['weekIds'].length; weekIds++) {
                                                                                  print(' yes we are in loop ');
                                                                                  // print(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name);

                                                                                  if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name == "Mon - Sun") {
                                                                                    print(' yes Mon - Sun ');
                                                                                    print(
                                                                                        ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                    print(
                                                                                        ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');

                                                                                    prefs.setString(
                                                                                        'openingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .openingTime
                                                                                            .toString());
                                                                                    prefs.setString('today', "Mon - Sun");
                                                                                    prefs.setString(
                                                                                        'closingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .closingTime
                                                                                            .toString());
                                                                                  } else if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name ==
                                                                                      DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                                                                                    print(' yes we are here ');
                                                                                    print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                                                                                    print(
                                                                                        ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                    print(
                                                                                        ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');
                                                                                    prefs.setString('today',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name.toString());
                                                                                    prefs.setString(
                                                                                        'openingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .openingTime
                                                                                            .toString());
                                                                                    prefs.setString(
                                                                                        'closingTime',
                                                                                        locationListWithDistance[index]['weekIds'][weekIds]
                                                                                            .restaurantTimings!
                                                                                            .closingTime
                                                                                            .toString());
                                                                                  }
                                                                                }
                                                                              }

                                                                              if ((Geolocator.distanceBetween(
                                                                                              widget.lat,
                                                                                              widget.long,
                                                                                              double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                                              double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                                          1000)
                                                                                      .toInt() >
                                                                                  10) {
                                                                                print('no');
                                                                                prefs.setString('delivery', 'no');

                                                                                setState(() {
                                                                                  selectedIndexCollect = 'no';
                                                                                  selectedIndexDeliver = 'no';
                                                                                });
                                                                              } else {
                                                                                setState(() {
                                                                                  selectedIndexCollect = 'no';
                                                                                  selectedIndexDeliver = 'yes';
                                                                                });

                                                                                print('yes');
                                                                                prefs.setString('delivery', 'yes');
                                                                                prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                                                                prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                                                                prefs.setString('restaurantImage',
                                                                                    imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());
                                                                              }

                                                                              setState(() {
                                                                                distance = (Geolocator.distanceBetween(
                                                                                            widget.lat,
                                                                                            widget.long,
                                                                                            double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                                            double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                                        1000)
                                                                                    .toStringAsFixed(0);
                                                                                selectedIndexCollect = 'no';
                                                                                selectedIndex = index.toString();
                                                                              });
                                                                              var snackBar = SnackBar(
                                                                                duration: Duration(milliseconds: 200),
                                                                                content: Text(
                                                                                  'Restaurant Selected',
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                                backgroundColor: Colors.green,
                                                                              );
                                                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                                                              // Navigator.push(
                                                                              //     context,
                                                                              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index: 0,)));
                                                                              //
                                                                            },
                                                                            child: Text('Deliver', style: TextStyle(color: Colors.white, fontSize: 11))),
                                                                      ),
                                                                    ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                                child: Container(
                                                                  width: size.width * 0.28,
                                                                  decoration: BoxDecoration(
                                                                    boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)],
                                                                    gradient: LinearGradient(
                                                                      begin: Alignment.topLeft,
                                                                      end: Alignment.bottomRight,
                                                                      stops: [0.0, 1.0],
                                                                      colors: [
                                                                        selectedIndexCollect == 'yes' && selectedIndex == index.toString() ? Colors.green : darkRedColor,
                                                                        selectedIndexCollect == 'yes' && selectedIndex == index.toString() ? Colors.green : lightRedColor,
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
                                                                        minimumSize: MaterialStateProperty.all(Size(size.width * 0.2, 30)),
                                                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                        // elevation: MaterialStateProperty.all(3),
                                                                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                      ),
                                                                      onPressed: () async {
                                                                        // if(){
                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                                          prefs.setString('selectedRestaurant', locationListWithDistance[index]['restaurantId'].toString());
                                                                          prefs.setString('restaurantName', locationListWithDistance[index]['restaurantName'].toString());
                                                                          prefs.setString(
                                                                              'restaurantImage', imageConstUrlRes + locationListWithDistance[index]['restaurantImage'].toString());
                                                                          prefs.remove("today");
                                                                          prefs.remove("closingTime");
                                                                          prefs.remove("openingTime");

                                                                          //  getRestaurantsSpecific(locationListWithDistance[index]['restaurantId'].toString());

                                                                          if (locationListWithDistance[index]['weekIds'].isNotEmpty) {
                                                                            print(' yes we are in weekids ${locationListWithDistance[index]['weekIds'][0].toJson()}');
                                                                            print(' yes we are in weekids ${DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()}');

                                                                            for (int weekIds = 0; weekIds < locationListWithDistance[index]['weekIds'].length; weekIds++) {
                                                                              print(' yes we are in loop ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name}');
                                                                              // print(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name);

                                                                              if(locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings == null){
                                                                                var snackBar = SnackBar(
                                                                                  duration: Duration(milliseconds: 1500),
                                                                                  content: Text(
                                                                                    'Unknown timings',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                                  backgroundColor: Colors.red,
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                return;
                                                                              }else if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name == "Mon - Sun") {
                                                                                print(' yes Mon - Sun ');
                                                                                print(
                                                                                    ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                print(
                                                                                    ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');

                                                                                prefs.setString('openingTime',
                                                                                    locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString());
                                                                                prefs.setString('today', "Mon - Sun");
                                                                                prefs.setString('closingTime',
                                                                                    locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString());
                                                                              }
                                                                              else if (locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name ==
                                                                                  DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
                                                                                print(' yes we are here ');
                                                                                print(' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ');
                                                                                print(
                                                                                    ' openingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString()} ');
                                                                                print(
                                                                                    ' closingTime ${locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString()} ');
                                                                                prefs.setString(
                                                                                    'today', locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.name.toString());
                                                                                prefs.setString('openingTime',
                                                                                    locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.openingTime.toString());
                                                                                prefs.setString('closingTime',
                                                                                    locationListWithDistance[index]['weekIds'][weekIds].restaurantTimings!.closingTime.toString());
                                                                              }
                                                                            }
                                                                          }

                                                                          if ((Geolocator.distanceBetween(
                                                                              widget.lat,
                                                                              widget.long,
                                                                              double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                              double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                              1000)
                                                                              .toInt() >
                                                                              10) {
                                                                            print('no');
                                                                            prefs.setString('delivery', 'no');
                                                                          } else {
                                                                            print('yes');
                                                                            prefs.setString('delivery', 'yes');
                                                                          }

                                                                          setState(() {
                                                                            distance = (Geolocator.distanceBetween(
                                                                                widget.lat,
                                                                                widget.long,
                                                                                double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                                double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                                1000)
                                                                                .toStringAsFixed(0);
                                                                          });

                                                                          var snackBar = SnackBar(
                                                                            duration: Duration(milliseconds: 200),
                                                                            content: Text(
                                                                              'Restaurant Selected',
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                            backgroundColor: Colors.green,
                                                                          );
                                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                          setState(() {
                                                                            selectedIndexCollect = 'yes';
                                                                            selectedIndexDeliver = 'no';
                                                                            selectedIndex = index.toString();
                                                                          });
                                                                          print('-------------------');
                                                                          print(prefs.getString("openingTime").toString());
                                                                          print(prefs.getString("today").toString());
                                                                          print(prefs.getString("closingTime").toString());
                                                                          print(prefs.getString("closingTime").toString().split(":")[0]);
                                                                          print('-------------------');
                                                                       // }


                                                                        // Navigator.push(
                                                                        //     context,
                                                                        //     MaterialPageRoute(builder: (context) => DashBoardScreen(index: 0,)));
                                                                        //
                                                                      },
                                                                      child: Text('Collect', style: TextStyle(color: Colors.white, fontSize: 11))),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Text('Lorem ipsum text lorem ipsum',
                                                        //   style: TextStyle(
                                                        //       fontFamily: 'Montserrat',
                                                        //       color: darkGreyTextColor, fontSize: 12,fontWeight: FontWeight.w400),),

                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),

                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/locationIcon.png',
                                                              fit: BoxFit.scaleDown,
                                                              height: 15,
                                                              width: 15,
                                                            ),
                                                            Text(
                                                              // restaurantList[index].latitude.toString()
                                                              (Geolocator.distanceBetween(
                                                                              widget.lat,
                                                                              widget.long,
                                                                              double.parse(locationListWithDistance[index]['restaurantLat'].toString()),
                                                                              double.parse(locationListWithDistance[index]['restaurantLong'].toString())) /
                                                                          1000)
                                                                      .toStringAsFixed(0)
                                                                  // (calculateDistance(double.parse(restaurantList[index].latitude.toString()), double.parse(restaurantList[index].longitude.toString()),
                                                                  //     widget.lat,widget.long )).toStringAsFixed(0)
                                                                  +
                                                                  ' Km',
                                                              style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF585858), fontSize: 12, fontWeight: FontWeight.w600),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.015,
                                      ),
                                      index == 2
                                          ? Container()
                                          : Container(
                                              width: size.width * 0.8,
                                              child: Divider(
                                                color: darkGreyTextColor,
                                                height: 1,
                                              ),
                                            ),
                                      SizedBox(
                                        height: size.height * 0.015,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  SizedBox(
                    height: size.height * 0.05,
                  ),

                  locationListWithDistance.isEmpty
                      ? Container()
                      :

                      // isLoading2 ? Center( child: CircularProgressIndicator(
                      //   color: darkRedColor,
                      //   strokeWidth: 1,
                      // ),):

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

                                  if (selectedIndex == '') {
                                    var snackBar = SnackBar(
                                      content: Text(
                                        'Kindly choose one of the restaurant.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  } else {
                                    log('Bool value ${prefs.getString("today") != null}');
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
                                        cartController.clearCart();
                                        if (widget.status == 'delete') {
                                          deleteCart();
                                        }
                                        cartController.clearCart();
                                        if (prefs.getString('delivery') == 'yes') {
                                          getDeliveryFee(distance);
                                        }
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DashBoardScreen(
                                                      index: 0,
                                                    )));
                                      } else {
                                        var snackBar = SnackBar(
                                          content: Text(
                                            'Restaurant is closed.',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    } else {
                                      var snackBar = SnackBar(
                                        content: Text(
                                          'Restaurant is closed.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  }

                                  //
                                },
                                child: Text('Continue', style: buttonStyle)),
                          ),
                        ),

                  SizedBox(
                    height: size.height * 0.05,
                  ),
                ],
              ),
            ),
    );
  }
}
