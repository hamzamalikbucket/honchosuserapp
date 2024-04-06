import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
// import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_new_project/constants.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/cartModel.dart';
import 'package:figma_new_project/model/flames_model.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/coupon/coupon_screen.dart';
import 'package:figma_new_project/view/screen/orderPlaced/order_placed_screen.dart';
import 'package:figma_new_project/view/screen/payment/payment_method_screen.dart';
import 'package:figma_new_project/view/screen/payment/simple_webview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum PaymentMethod { cash, creditDebit }
class CheckOutScreen extends StatefulWidget {

  final List<ProductModel> productList;
  final List<CartModel> cartItemList;
  final List<List<int>> addOnsIdsList;

  const CheckOutScreen({Key? key, required this.productList, required this.cartItemList, required this.addOnsIdsList}) : super(key: key);

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen>
    with SingleTickerProviderStateMixin {

  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final cartController = Get.put(AddToCartController());
  List<FlamesModel> flamesList = [];
  TabController? _tabController;
  List<ProductModel> productListBackUp = [];
  List<Map<String, dynamic>> productListMap = [];
  List<int> addOns = [];
  String total = '0';
  String paymentMethod = '';
  String totalTest = '200';
  String pickUpTotal = '0';
  String deliveryFee = '0';
  String MD5 = '0';
  String subTotal = '0';
  String addOnTotal = '0';
  int totalOrder = 0;
  double discountedTotal = 0.0;
  double discountedTotalPickUp = 0.0;
  double discountedSubtotal = 0.0;
  double discount = 0.0;
  String flames = '0', flameId = '', getDiscount = '';
  String isDeliveryAvailable = '';
  String restaurantName = '';
  String restaurantImage = '';
  String Address = '';
  String  restaurantId = '';
  String isAddressThere = 'no';
  String deliveryType = '';
  List<ProductModel> _productList = [];

  bool isLoading = false;
  bool flameLoading = false;
  String addressUser = '';

  @override
  void initState() {
    super.initState();
    checkAddress();
    updateDiscount();
    setState(() {
      paymentMethod = 'COD';
      totalOrder = 0;
      flameLoading = false;
      isLoading = false;
      productListBackUp = widget.productList;
    });
    getFlames();
    print(widget.productList.length.toString() + ' length');
    print(productListBackUp.length.toString() + ' length back Up');
    print(productListBackUp[0].cartId.toString() + ' length back Up');
    getTotal();
    placeOrderList();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  updateDiscount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('useFlame', 'no');
    setState(() {
      getDiscount = '';
    });
  }

  getTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('subTotal') != null) {
      setState(() {
        subTotal = prefs.getString('subTotal')!;
      });
    }

    if(prefs.getString('addOnTotal') != null) {
      setState(() {
        addOnTotal = prefs.getString('addOnTotal')!;
      });
    }
    
    if(prefs.getString('cartTotal') != null) {
      setState(() {
        pickUpTotal = prefs.getString('cartTotal')!;
      });
    }

    if(prefs.getString('cartTotal') != null) {
      setState(() {
        total = prefs.getString('cartTotal')!;
      });
    }
    if(prefs.getString('delivery') != null) {
      setState(() {
        isDeliveryAvailable  = prefs.getString('delivery')!;

        if( isDeliveryAvailable == 'yes') {
          print(' we are in delivery yes ');

          if(prefs.getString('deliveryFee') != null) {
            setState(() {
              deliveryFee = prefs.getString('deliveryFee').toString();
              totalOrder = int.parse(total.toString()) + int.parse(prefs.getString('deliveryFee').toString());
              total = totalOrder.toString();
            });
          }


        }
      });
    }
    if(prefs.getString('userAddress') != null) {
      setState(() {
        Address  = prefs.getString('userAddress')!;
        //total = prefs.getString('delivery')!;
      });
    }
    if(prefs.getString('restaurantName') != null) {
      setState(() {
        restaurantName  = prefs.getString('restaurantName')!;
        //total = prefs.getString('delivery')!;
      });
    }
    if(prefs.getString('restaurantImage') != null) {
      setState(() {
        restaurantImage  = prefs.getString('restaurantImage')!;
        //total = prefs.getString('delivery')!;
      });
    }

  }

  placeOrderList() async {
    setState(() {
      productListMap.clear();
      addOns.clear();
    });

    for(int i=0;i<widget.cartItemList.length ; i++) {
      print('${widget.cartItemList[i].id.toString()}');

      setState(() {
        productListMap.add({
          "product_id":widget.cartItemList[i].product!.id.toString(),
          "quantity":widget.cartItemList[i].quantity.toString(),
          "payment": widget.cartItemList[i].product!.price.toString(),
          "addon_ids": widget.addOnsIdsList[i],
          "special_instruction":widget.cartItemList[i].specialInstruction.toString()
        });
      });



      if(widget.cartItemList.length-1 == i) {
        print(productListMap.toList().toString() + ' This is map');
      }






    }

    // for(int i=0;i<widget.productList.length ; i++) {
    //   print('${widget.productList[i].cartId.toString()}');
    //
    //   setState(() {
    //     productListMap.add({
    //       "product_id":widget.productList[i].id.toString(),
    //       "quantity":widget.productList[i].quantity.toString(),
    //       "payment": widget.productList[i].price.toString(),
    //     });
    //   });
    // }
  //  print(productListMap.toList().toString() + ' This is map');
  }

  getFlames() async {
    print('get flames');
    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.MultipartRequest(
        'GET', Uri.parse('${apiBaseUrl}api/flames'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    // final data = json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        flamesList = List<FlamesModel>.from(
            json.decode(responseData).map((x) => FlamesModel.fromJson(x)));
      });



      if (flamesList.isNotEmpty) {

        for(int i=0; i<flamesList.length; i++) {
          if (flamesList[i].status == 'Active') {
            setState(() {
              flames = flamesList[i].flames!;
              flameId = flamesList[i].id!.toString();
              flameLoading = false;
            });
          }
        }

      } else {
        setState(() {
          flames = '0';
          flameLoading = false;
        });
      }

    }
    else if (response.statusCode == 302) {
      setState(() {
        flameLoading = false;
        flames = '0';
      });
      print('get flames 302');
      print('get flames else');

      // print(await response.stream.bytesToString());
    }
    else {
      setState(() {
        flameLoading = false;
        flames = '0';
      });
      print(response.reasonPhrase);
    }
  }

  makePayment(String total) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(total.toString() + ' MD5 is here');
    String merchantProduction = 'merchant_id=${merchantId}&merchant_key=${merchantKey}&return_url=http%3A%2F%2Fwww.yourdomain.co.za%2Freturn&cancel_url=http%3A%2F%2Fwww.yourdomain.co.za%2Fcancel&';
    String product = 'amount=${total}&item_name=KFC&';
    String passphrase = 'passphrase=${merchantPassphrase}';
    String completedString = merchantProduction+product+passphrase;
    setState(() {
      MD5 = md5.convert(utf8.encode(completedString)).toString();
    });
    print(MD5.toString() + ' MD5 is here');
    print('we are in makepayment');
    var headers = {
      'Cookie': 'pf_bid=1.9b70085110adfe5c.1687245602',
      'Content-Type': 'application/json'
    };
    var request = http.MultipartRequest('POST', Uri.parse('$paymentBaseUrl/eng/process'));
    request.fields.addAll({
      'merchant_id': '$merchantId',
      'merchant_key': '$merchantKey',
      'return_url': '$returnUrl',
      'cancel_url': '$cancelUrl',
      'amount': '$total',//prefs.getString('finalTotal') != null ? prefs.getString('finalTotal').toString() : '20' ,
      'item_name': 'KFC',
      'signature': MD5.toString(),
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      print('200');
      print(await response.stream.bytesToString());
    }
    else {
      setState(() {
        isLoading = false;
      });
      // print(response.reasonPhrase);
      // print(response.statusCode);
      // print(await response.stream.bytesToString());







      await response.stream.bytesToString().then((value) {
        // print(value.toString());

        developer.log(value.toString());

        RegExp regex = new RegExp('(?<=href=").*?(?=")');
        var match = regex.firstMatch(value);

        if (match == null) {
          print("No match found.");
          return;
        }

        print("Result: " + match.group(0)!);

        if(match.group(0)!.startsWith("https://www.payfast.co.za/eng/")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewExample(
              url:match.group(0)!,
              productList: _productList,
              productListMap: productListMap,
              address: addressUser,
              deliveryFee: prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
              deliveryType: deliveryType.toString(),
              restaurantId: restaurantId.toString(),
              isAddressThere: isAddressThere.toString(),
            )),
          );
        }
       else if(match.group(0)!.startsWith("https://sandbox.payfast.co.za/eng/")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewExample(
              url:match.group(0)!,
              productList: _productList,
              productListMap: productListMap,
              address: addressUser,
              deliveryFee: prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
              deliveryType: deliveryType.toString(),
              restaurantId: restaurantId.toString(),
              isAddressThere: isAddressThere.toString(),
            )),
          );
        }
        else {
          var snackBar = SnackBar(content: Text('Something went wrong with payment'
            ,style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }



        // print(await response.stream.bytesToString());
        print(response.reasonPhrase);
        print(response.statusCode.toString() + ' Payment code 3' );
      });


    }



  }

  checkAddress() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('selectedRestaurant') != null) {
      setState(() {
        restaurantId =  prefs.getString('selectedRestaurant')!;
        //name =  prefs.getString('userName')!;
        print(restaurantId);
      });
    }
    // prefs.setString('delivery', 'no');
    if(prefs.getString('delivery') != null) {

      if(prefs.getString('delivery') == 'no') {
        setState(() {
          deliveryType =  'Self';
          //name =  prefs.getString('userName')!;
          print(deliveryType);
        });
      } else if (prefs.getString('delivery') == 'yes') {
        setState(() {
          deliveryType =  'Driver';
          //name =  prefs.getString('userName')!;
          print(deliveryType);
        });
      }


    }

    if(prefs.getString('userAddress') != null) {
      setState(() {
        addressUser =  prefs.getString('userAddress')!;
        print(addressUser.toString()+ ' userAddress');
        //name =  prefs.getString('userName')!;
      });
    }

    print(addressUser.toString()+ ' userAddress');
    FirebaseFirestore.instance.collection('UserAddress').where('uid',isEqualTo: prefs.getString('userId'))
        .where('lat',isEqualTo: prefs.getDouble('lat')).where('long',isEqualTo: prefs.getDouble('long')).get().then((value) {

      for(int i=0; i<value.docs.length ;i++) {
        print(value.docs[i]['long'].toString());
        print(value.docs[i]['lat'].toString());
        print(prefs.getDouble('long').toString());
        print(prefs.getDouble('lat').toString());

        if((value.docs[i]['long'] == prefs.getDouble('long'))  && (value.docs[i]['lat'] == prefs.getDouble('lat') ) &&
            (value.docs[i]['address'].toString() == prefs.getString('userAddress').toString() )
        ) {
          setState(() {
            isAddressThere = 'yes';
          });
        }
      }





      print(isAddressThere.toString() + 'yes its there');

    });

  }

  // placeOrder() async {
  //  // print(productListMap.toList().toString() + ' This is map');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(_tabController!.index == 1) {
  //     print(pickUpTotal.toString()+ ' Pick Up' );
  //     prefs.setString('finalTotal', pickUpTotal);
  //   }
  //   else {
  //     print(total.toString()+ ' delivery ' );
  //     prefs.setString('finalTotal', total.toString());
  //   }
  //
  //
  //
  //
  //   print(productListBackUp.length.toString()+ ' list length before going to payment' );
  //   print(widget.productList.length.toString()+ ' list length before going to payment' );
  //
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  //
  //
  //   Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) =>
  //           PaymentMethodScreen(orderId: 'order_no',productList1: productListBackUp, productListMap: productListMap,)));
  //
  // }

  placeOrder() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('userAddress') != null) {
      setState(() {
        addressUser =  prefs.getString('userAddress')!;
        print(addressUser.toString()+ ' userAddress');
        //name =  prefs.getString('userName')!;
      });
    }
    print(productListMap.toList().toString() + ' This is map');

    if( paymentMethod == 'Credit') {
      print('we are in credit');
      if(_tabController!.index == 1) {
        setState(() {
          deliveryType =  'Self';
        });
        if(getDiscount == 'yes') {
          print(pickUpTotal.toString()+ ' Pick Up' );
          prefs.setString('finalTotal', discountedTotalPickUp.toString());
          makePayment(discountedTotalPickUp.toString());
        }
        else {
          print(pickUpTotal.toString()+ ' Pick Up' );
          prefs.setString('finalTotal', pickUpTotal);
          makePayment(pickUpTotal.toString());
        }
      }
      else {
        if(getDiscount == 'yes') {
          print(pickUpTotal.toString()+ ' Pick Up' );
          prefs.setString('finalTotal', discountedTotal.toString());
          makePayment(discountedTotal.toString());

        } else {
          print(total.toString()+ ' delivery ' );
          prefs.setString('finalTotal', total.toString());
          makePayment(total.toString());
        }
      }
    }

    else if( paymentMethod == 'COD') {
      print('we are in cod');
      print(productListMap.toList().toString() + ' This is map COD');
      if(_tabController!.index == 1) {
        setState(() {
          deliveryType =  'Self';
        });
        print(deliveryType.toString() + ' This is deliveryType');

      }
      try {
        var headers = {
          'Content-Type': 'application/json',
          'Cookie': 'restaurant_session=$cookie'
        };

        print('Delivery Type :${deliveryType.toString()}');
        print('Delivery Fee :${prefs.getString('delivery') == 'yes' && deliveryType.toString() != 'Self' ? prefs.getString('deliveryFee').toString() :  '0'}');


        var request = http.Request('POST', Uri.parse('${apiBaseUrl}api/order_create'));

        request.body = json.encode({
          "transaction_id": Random().nextInt(1000000).toString(),
          "restaurant_id": restaurantId,
          "address": addressUser.toString(),
          "delivery_type":deliveryType.toString(),
          "delivery_fee": prefs.getString('delivery') == 'yes' && deliveryType.toString() != 'Self' ? prefs.getString('deliveryFee').toString() :  '0',
          "items": productListMap
        });

        // var request = http.Request('POST', Uri.parse('https://restaurant.wettlanoneinc.com/api/order_create'));
        // request.body = json.encode({
        //   "transaction_id": Random().nextInt(1000000).toString(),
        //   "restaurant_id": restaurantId,
        //   "address": addressUser.toString(),
        //   "delivery_type": deliveryType.toString(),
        //   "delivery_fee": prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
        //   "items": productListMap
        // });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          updateFlameStatus();
          //  deleteCart();

          final responseData = await response.stream.bytesToString();
          final data = json.decode(responseData);

          if(isAddressThere != 'yes') {
            FirebaseFirestore.instance.collection('UserAddress').doc().set({
              'address':prefs.getString('userAddress'),
              'lat':prefs.getDouble('lat'),
              'long':prefs.getDouble('long'),
              'uid':prefs.getString('userId'),
            }).then((value) {
              print('address saved');
            });
          }


          setState(() {
            isLoading = false;
          });
          cartController.clearCart();


          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderPlacedScreen(orderId: data['order_no'].toString(),productList: _productList,)));

        }
        else if (response.statusCode == 420) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          var snackBar = SnackBar(content: Text('Session expires login to continue'
            ,style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          await prefs.remove('userEmail').then((value){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          });
        }
        else {
          setState(() {
            isLoading = false;
          });

          var snackBar = SnackBar(content: Text(response.reasonPhrase.toString()
            ,style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

      } on Exception catch (exception) {

        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text(exception.toString()
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      } catch (error) {

        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text(error.toString()
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

  }

  void getRestaurantDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('selectedRestaurant') != null) {

      setState(() {
        restaurantName=prefs.getString('restaurantName').toString();
      });

      print(prefs.getString('selectedRestaurant').toString() + ' selectedRestaurant 123' );
    }
  }

  updateFlameStatus() async {
    print("we are in updateFlameStatus");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //prefs.setString('flameId', flameId.toString());


    if(prefs.getString('useFlame') != null) {
      if(prefs.getString('useFlame') == 'yes') {
        if(prefs.getString('flameId') != null) {
          updateStatusApi(prefs.getString('flameId').toString());
        }
      } else {
        print('useFlame is 0');
      }
    } else {
      print('useFlame is null');
    }

  }

  updateStatusApi(String flameId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("we are in updateStatusApi");

    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };

    var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}api/update_flame_status/$flameId'));
    request.fields.addAll({
      'status': 'Completed'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print("we are in updateStatusApi with 200");
      prefs.setString('useFlame', 'no');
      // print(await response.stream.bytesToString());
    }
    else {
      prefs.setString('useFlame', 'no');
      print("we are in updateStatusApi with else ${response.statusCode}");
      print(response.reasonPhrase);
    }


  }


  @override
  Widget build(BuildContext context) {
    // getTotal();
    // setState(() {
    //   flameLoading = false;
    // });
    // getFlames();
    // print(restaurantName.toString() + 'Name is here');
    // print(restaurantImage.toString() + '   Name is here');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Checkout',
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:1)));
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
            ),
        ),
      ),
      body:
      isDeliveryAvailable == 'no' ? SingleChildScrollView(
        child: Container(
          child: Column(children: [

            SizedBox(
              height: size.height*0.005,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,top:10),
              child: Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
               'Take away',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0,),
              child: Container(
                width: size.width*0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: lightButtonGreyColor,
                        spreadRadius: 2,
                        blurRadius: 3
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    //  height: size.height*0.1,
                    width: size.width*0.6,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height*0.02,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 0,right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Address',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.black,
                                      fontSize: 14,fontWeight: FontWeight.w600),),
                              ],),
                          ),

                          SizedBox(
                            height: size.height*0.02,
                          ),

                          



                          Container(
                            width: size.width*0.9,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0,right: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: size.width*0.05,
                                    child: Image.asset('assets/images/locationIcon.png', fit: BoxFit.scaleDown,
                                      height: 15,
                                      color: Colors.black,
                                      width: 15,
                                    ),
                                  ),

                                  Container(
                                    width: size.width*0.8,
                                    child: Text(Address.toString(),
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                  ),


                                ],),
                            ),
                          ),
                          SizedBox(
                            height: size.height*0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(restaurantName,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: darkRedColor,
                        fontSize: 16,fontWeight: FontWeight.w600,),),
                ],),
            ),

            // SizedBox(
            //   height: size.height*0.02,
            // ),

            SizedBox(
              height: size.height*0.03,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'Order Detail',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
            ),
            // SizedBox(
            //   height: size.height*0.01,
            // ),

            widget.cartItemList.isEmpty  ? Container(
              child: Text('No cart item found',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),),
            ) :
            SizedBox(
              // height: size.height*0.25,
              width: size.width*0.95,
              //width: size.width*0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.cartItemList.length,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context,index
                    ) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      // width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16,),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Container(
                                      decoration: BoxDecoration(
                                        color: lightButtonGreyColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          height: size.height*0.07,
                                          width: size.width*0.2,
                                          fit: BoxFit.cover,
                                          imageUrl: imageConstUrlProduct+widget.cartItemList[index].product!.image.toString(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      // height: size.height*0.07,
                                      width: size.width*0.65,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: size.width*0.5,
                                                  child: Text(widget.cartItemList[index].product!.name.toString(),
                                                    style: TextStyle(color: Color(0xFF585858),
                                                        fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                                ),

                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Quantity : ' + widget.cartItemList[index].quantity.toString(),
                                                  //quantity.toString(),
                                                  style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                                                // widget.order.ordersItems![index].product!.price.toString()
                                                Text('R '+ '${
                                                    int.parse(widget.cartItemList[index].product!.price.toString())*int.parse(widget.cartItemList[index].quantity.toString())
                                                }',
                                                  style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height*0.01,
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
                            height: size.height*0.01,
                          ),
                          widget.cartItemList[index].addon == null
                              || widget.cartItemList[index].addon.toString() == '[]'

                              ? Container() :
                          Container(
                            width: size.width*0.95,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 8,),
                            child: Text('Add Ons',
                              style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                          ),
                          SizedBox(height: 4,),

                          Container(
                            width: size.width*0.95,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.cartItemList[index].addon!.length,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context,addIndex
                                  ) {

                                return
                                  widget.cartItemList[index].addon![addIndex].addon == null ? Container() :
                                  Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 20,bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width*0.7,
                                        child: Text(

                                          widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '2' ?
                                          widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Chips)' :
                                          widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ?
                                          widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Flavour)' :
                                          widget.cartItemList[index].addon![addIndex].addon!.name.toString()
                                          ,
                                          //quantity.toString(),
                                          style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                      ),
                                      // widget.order.ordersItems![index].product!.price.toString()
                                      widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ||
                                          widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '1'
                                          ? Container() :
                                      Text('R '+widget.cartItemList[index].addon![addIndex].addon!.price.toString(),
                                        style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w500),),
                                    ],
                                  ),
                                );

                              },

                            ),
                          ),

                          SizedBox(
                            height: size.height*0.01,
                          ),
                          widget.cartItemList[index].specialInstruction.toString() == ''
                              || widget.cartItemList[index].specialInstruction == null
                              ? Container() :
                          Column(children: [
                            Container(
                              width: size.width*0.95,
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 8,),
                              child: Text('Special Instruction',
                                style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                            ),
                            SizedBox(height: 4,),
                            Container(
                              width: size.width*0.95,
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 8,),
                              child: Text(widget.cartItemList[index].specialInstruction.toString(),
                                style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 4,),
                            ),
                            SizedBox(height: 8,),
                          ],),


                        ],),
                      ),
                    ),
                  );
                },

              ),
            ),
            // SizedBox(
            //   // height: size.height*0.25,
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     itemCount: widget.productList.length,
            //     scrollDirection: Axis.vertical,
            //     itemBuilder: (BuildContext context,index
            //         ) {
            //       return Column(children: [
            //         Padding(
            //           padding: const EdgeInsets.only(top: 16,),
            //           child: Container(
            //             width: size.width*0.9,
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(10),
            //               boxShadow: [
            //                 BoxShadow(
            //                     color: lightButtonGreyColor,
            //                     spreadRadius: 2,
            //                     blurRadius: 3
            //                 )
            //               ],
            //             ),
            //             child: Padding(
            //               padding: const EdgeInsets.all(0.0),
            //               child: Row(
            //                 children: [
            //
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: lightButtonGreyColor,
            //                       borderRadius: BorderRadius.circular(10),
            //                     ),
            //                     child: ClipRRect(
            //                       borderRadius: BorderRadius.circular(10),
            //                       child: CachedNetworkImage(
            //                         height: size.height*0.07,
            //                         width: size.width*0.2,
            //                         fit: BoxFit.cover,
            //                         imageUrl: imageConstUrlProduct+widget.productList[index].image.toString(),
            //                         errorWidget: (context, url, error) => Icon(Icons.error),
            //                       ),
            //                     ),
            //                   ),
            //
            //                   Container(
            //                     height: size.height*0.085,
            //                     width: size.width*0.6,
            //                     child: Padding(
            //                       padding: const EdgeInsets.only(left: 8),
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           SizedBox(
            //                             height: size.height*0.01,
            //                           ),
            //                           Row(
            //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                             children: [
            //                               Container(
            //                                 width: size.width*0.5,
            //                                 child: Text(widget.productList[index].name.toString(),
            //                                   style: TextStyle(color: Color(0xFF585858),
            //                                       fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
            //                               ),
            //
            //                             ],
            //                           ),
            //                           SizedBox(
            //                             height: size.height*0.01,
            //                           ),
            //                           Row(
            //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                             children: [
            //                               Text(
            //                           'Quantity : ' + widget.productList[index].quantity.toString(),
            //                                 //quantity.toString(),
            //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
            //                               Text('R '+widget.productList[index].price.toString(),
            //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
            //                             ],
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //
            //       ],);
            //     },
            //
            //   ),
            // ),

            SizedBox(
              height: size.height*0.03,
            ),

            flameLoading ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :

            flames == '0'  ?  Padding(
              padding: const EdgeInsets.only(top: 0,),
              child: Container(
                width: size.width*0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: lightButtonGreyColor,
                        spreadRadius: 2,
                        blurRadius: 3
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    //  height: size.height*0.1,

                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0,right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: size.width*0.4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('My Wallet',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                            fontSize: 16,fontWeight: FontWeight.w600),),
                                      SizedBox(
                                        height: size.height*0.01,
                                      ),
                                      Container(
                                        width: size.width*0.9,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 0,right: 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Container(
                                                width: size.width*0.4,
                                                child: Row(children: [
                                                  Container(

                                                    child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                  ),

                                                  Container(

                                                    child: Text(' 0 Flames',
                                                      style: TextStyle(
                                                          fontFamily: 'Montserrat',
                                                          color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                  ),
                                                ],),
                                              ),

                                            ],),
                                        ),
                                      ),
                                    ],),
                                ),
                              ],),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ) :

            Padding(
              padding: const EdgeInsets.only(top: 0,),
              child: Container(
                width: size.width*0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: lightButtonGreyColor,
                        spreadRadius: 2,
                        blurRadius: 3
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    //  height: size.height*0.1,

                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Padding(
                            padding: const EdgeInsets.only(left: 0,right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: size.width*0.4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Text('My Wallet',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 15,fontWeight: FontWeight.w600),),
                                      SizedBox(
                                        height: size.height*0.01,
                                      ),
                                    Container(
                                      width: size.width*0.9,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0,right: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Container(
                                              width: size.width*0.4,
                                              child: Row(children: [
                                                Container(

                                                  child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                ),

                                                Container(

                                                  child: Text(
                                                    getDiscount == 'yes' ? ' 0 Flames' :
                                                    ' $flames Flames',
                                                    style: TextStyle(
                                                        fontFamily: 'Montserrat',
                                                        color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                ),
                                              ],),
                                            ),




                                          ],),
                                      ),
                                    ),
                                  ],),
                                ),
                                Container(

                                  child: Column(children: [
                                    GestureDetector(
                                      onTap: () async {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();

                                        if(double.parse(flames) > double.parse(total.toString())) {

                                          var snackBar = SnackBar(content: Text('Please add some more items to get this discount'
                                            ,style: TextStyle(color: Colors.white),),
                                            backgroundColor: Colors.red,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                        } else {

                                          if(getDiscount == '') {
                                            setState(() {
                                              getDiscount = 'yes';
                                              discount = double.parse(flames.toString());

                                              discountedTotal = double.parse(total.toString()) - double.parse(flames.toString());
                                            });
                                            prefs.setString('useFlame', 'yes');
                                            prefs.setString('discount', discount.toString());
                                            prefs.setString('discountTotal', discountedTotal.toString());
                                            prefs.setString('flameId', flameId.toString());
                                          }
                                          else {
                                            setState(() {
                                              getDiscount = '';
                                            });
                                            prefs.setString('useFlame', 'no');
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                          ],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            stops: [0.0, 1.0],
                                            colors:
                                            getDiscount == '' ?
                                            [
                                              darkRedColor,
                                              lightRedColor,
                                            ] : [

                                              Colors.green,
                                              Colors.green,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            getDiscount == 'yes' ? 'Discounted' :
                                            'Get Discount', style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w600),),
                                        ),
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),

            Container(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Payment Method',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height*0.0,
            ),
            Column(children: [

              Container(
            height: tileHeight,
                child: ListTile(
                  // tileColor: ,
                  // hoverColor: ,
                  onTap: () {
                    setState(() {
                      paymentMethod = 'COD';
                    });
                    print(paymentMethod.toString() + ' payment Method');
                  },
                  title:  Row(
                    children: [
                      Text('Cash on delivery', style:
                      TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  leading: Radio(
                    value: PaymentMethod.cash,
                    groupValue: _paymentMethod,
                    activeColor: darkRedColor,
                    onChanged: (PaymentMethod? value) {
                      setState(() {
                        _paymentMethod = value!;
                        paymentMethod = 'COD';

                      });
                    },
                  ),
                ),
              ),
              
              Container(
                  height: tileHeight,
                child: ListTile(
                   // tileColor: lightButtonGreyColor,
                  onTap: () {
                    setState(() {
                      paymentMethod = 'Credit';
                    });
                    print(paymentMethod.toString() + ' payment Method');
                  },
                  title:  Row(
                    children: [
                      Text('Debit / Credit Card',
                            style:
                        TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                           ),
                    ],
                  ),
                  leading: Radio(
                    value: PaymentMethod.creditDebit,
                    groupValue: _paymentMethod,
                    activeColor: darkRedColor,
                    onChanged: (PaymentMethod? value) {
                      setState(() {
                        _paymentMethod = value!;
                        paymentMethod = 'Credit';
                      });
                    },
                  ),
                ),
              ),

              SizedBox(
                height: size.height*0.02,
              ),



            ],),

            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25,top: 4),
                      child: Text(
                        'Order Amount',                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'Subtotal',
                        style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Obx(()=>Text('R '+cartController.subTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                      // Text('\$30.99',
                      //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                    ),
                  ],
                )),
            SizedBox(
              height: size.height*0.01,
            ),
            cartController.addOnsTotal.toString() == '0' ? Container() :
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'Add Ons total',
                        style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Obx(()=>Text('R '+cartController.addOnsTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                      // Text('\$30.99',
                      //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                    ),
                  ],
                )),
            getDiscount == 'yes' ? SizedBox(
              height: size.height*0.02,
            ) : SizedBox(),
            getDiscount == 'yes' ?   Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'Discount',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(

                        'R ${discount}' ,
                        //'\$39.99',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),),
                    ),
                  ],
                )) : SizedBox(),
            SizedBox(
              height: size.height*0.02,
            ),
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        getDiscount == 'yes' ?
                        'R ${discountedTotal}' :
                        'R ${total}',
                        //'\$39.99',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),),
                    ),
                  ],
                )),


            SizedBox(
              height: size.height*0.05,
            ),


            isLoading ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :

            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Container(

                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                  ],
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
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      // elevation: MaterialStateProperty.all(3),
                      shadowColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),

                    onPressed: () {
                     // getFlames();
                      setState(() {
                        isLoading = true;
                      });

                       placeOrder();
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => OrderPlacedScreen()));

                    }, child: Text('Place Order', style: buttonStyle)),
              ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),


          ],),
        ),
      ) :

      SafeArea(child: Column(children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: size.width*0.9,

            height: 45,
            decoration: BoxDecoration(
              color: Color(0xFFFFD3D1),

              borderRadius: BorderRadius.circular(
                10.0,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              // give the indicator a decoration (color and border radius)
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  colors: [
                    darkRedColor,
                    lightRedColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              //  color: authButtontextColor,



              ),
              onTap: (selectedTabIndex){
                print(selectedTabIndex);
              },
              unselectedLabelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,fontSize: 13, color: Colors.black),
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,fontSize: 15),
              labelColor: Colors.white,
              unselectedLabelColor:  Colors.black,
              tabs: [
                // first tab [you can add an icon using the icon property]
                Tab(
                  text: 'Delivery',
                ),

                // second tab [you can add an icon using the icon property]
                Tab(
                  text: 'PickUp',
                ),
              ],
            ),
          ),
        ),


        Expanded(child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(children: [

                  SizedBox(
                    height: size.height*0.015,
                  ),

                  Container(
                    width: size.width*0.7,
                    child: Center(
                        child: Text('Your address is within a 10km radius ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: darkGreyTextColor1, fontSize: 13,),)
                    ),
                  ),

                  SizedBox(
                    height: size.height*0.015,
                  ),


                  Padding(
                    padding: const EdgeInsets.only(top: 16,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                        //  height: size.height*0.1,
                          width: size.width*0.6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height*0.02,
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Delivery Address',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                            fontSize: 14,fontWeight: FontWeight.w600),),

                                    ],),
                                ),

                                SizedBox(
                                  height: size.height*0.02,
                                ),

                                Container(
                                  width: size.width*0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0,right: 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: size.width*0.05,
                                          child: Image.asset('assets/images/locationIcon.png', fit: BoxFit.scaleDown,
                                            height: 15,
                                            color: Colors.black,
                                            width: 15,
                                          ),
                                        ),

                                        Container(
                                          width: size.width*0.8,
                                          child: Text(Address.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                        ),


                                      ],),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height*0.02,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  SizedBox(
                    height: size.height*0.03,
                  ),


                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Order Detail',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      )),
                  widget.cartItemList.isEmpty  ? Container(
                    child: Text('No cart item found',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    width: size.width*0.95,
                    //width: size.width*0.9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.cartItemList.length,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context,index
                          ) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            // width: size.width*0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: lightButtonGreyColor,
                                    spreadRadius: 2,
                                    blurRadius: 3
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16,),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            decoration: BoxDecoration(
                                              color: lightButtonGreyColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                height: size.height*0.07,
                                                width: size.width*0.2,
                                                fit: BoxFit.cover,
                                                imageUrl: imageConstUrlProduct+widget.cartItemList[index].product!.image.toString(),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                          ),

                                          Container(
                                            // height: size.height*0.07,
                                            width: size.width*0.65,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: size.height*0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: size.width*0.5,
                                                        child: Text(widget.cartItemList[index].product!.name.toString(),
                                                          style: TextStyle(color: Color(0xFF585858),
                                                              fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                                      ),

                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height*0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Quantity : ' + widget.cartItemList[index].quantity.toString(),
                                                        //quantity.toString(),
                                                        style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                                                      // widget.order.ordersItems![index].product!.price.toString()
                                                      Text('R '+ '${
                                                          int.parse(widget.cartItemList[index].product!.price.toString())*int.parse(widget.cartItemList[index].quantity.toString())
                                                      }',
                                                        style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height*0.01,
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
                                  height: size.height*0.01,
                                ),
                                widget.cartItemList[index].addon == null
                                    || widget.cartItemList[index].addon.toString() == '[]'
                                   // || widget.cartItemList[index].addon.toString() ==  "[Instance of 'AddonElement']"
                                    ? Container() :
                                Container(
                                  width: size.width*0.95,
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 8,),
                                  child: Text('Add Ons',
                                    style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                                ),
                                SizedBox(height: 4,),

                                Container(
                                  width: size.width*0.95,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.cartItemList[index].addon!.length,
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context,addIndex
                                        ) {

                                      return
                                        widget.cartItemList[index].addon![addIndex].addon != null ?
                                        Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 20,bottom: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: size.width*0.7,
                                              child: Text(

                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '2' ?
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Chips)' :
                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ?
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Flavour)' :
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString()
                                                ,
                                                //quantity.toString(),
                                                style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                            ),
                                            // widget.order.ordersItems![index].product!.price.toString()
                                            widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ||
                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '1'
                                                ? Container() :
                                            Text('R '+widget.cartItemList[index].addon![addIndex].addon!.price.toString(),
                                              style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                      ) : Container();

                                    },

                                  ),
                                ),

                                SizedBox(
                                  height: size.height*0.01,
                                ),
                                widget.cartItemList[index].specialInstruction.toString() == ''
                                    || widget.cartItemList[index].specialInstruction == null
                                    ? Container() :
                                    Column(children: [
                                      Container(
                                        width: size.width*0.95,
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.only(left: 8,),
                                        child: Text('Special Instruction',
                                          style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                                      ),
                                      SizedBox(height: 4,),
                                      Container(
                                        width: size.width*0.95,
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.only(left: 8,),
                                        child: Text(widget.cartItemList[index].specialInstruction.toString(),
                                          style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 4,),
                                      ),
                                      SizedBox(height: 8,),
                                    ],),



                              ],),
                            ),
                          ),
                        );
                      },

                    ),
                  ),
                  // widget.productList.isEmpty  ? Container(
                  //   child: Text('No cart item found',
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w500),),
                  // ) :
                  // SizedBox(
                  //   // height: size.height*0.25,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: widget.productList.length,
                  //     scrollDirection: Axis.vertical,
                  //     itemBuilder: (BuildContext context,index
                  //         ) {
                  //       return Column(children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(top: 16,),
                  //           child: Container(
                  //             width: size.width*0.9,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                     color: lightButtonGreyColor,
                  //                     spreadRadius: 2,
                  //                     blurRadius: 3
                  //                 )
                  //               ],
                  //             ),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(0.0),
                  //               child: Row(
                  //                 children: [
                  //
                  //                   Container(
                  //                     decoration: BoxDecoration(
                  //                       color: lightButtonGreyColor,
                  //                       borderRadius: BorderRadius.circular(10),
                  //                     ),
                  //                     child: ClipRRect(
                  //                       borderRadius: BorderRadius.circular(10),
                  //                       child: CachedNetworkImage(
                  //                         height: size.height*0.07,
                  //                         width: size.width*0.2,
                  //                         fit: BoxFit.cover,
                  //                         imageUrl: imageConstUrlProduct+widget.productList[index].image.toString(),
                  //                         errorWidget: (context, url, error) => Icon(Icons.error),
                  //                       ),
                  //                     ),
                  //                   ),
                  //
                  //                   Container(
                  //                     height: size.height*0.081,
                  //                     width: size.width*0.6,
                  //                     child: Padding(
                  //                       padding: const EdgeInsets.only(left: 8),
                  //                       child: Column(
                  //                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                         children: [
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(widget.productList[index].name.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858),
                  //                                     fontSize: 13,fontWeight: FontWeight.w500),),
                  //
                  //                             ],
                  //                           ),
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(
                  //                                 'Quantity : ' + widget.productList[index].quantity.toString(),
                  //                                 //quantity.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 13,fontWeight: FontWeight.w600),),
                  //                               Text('R '+widget.productList[index].price.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                  //                             ],
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //
                  //       ],);
                  //     },
                  //
                  //   ),
                  // ),

                  SizedBox(
                    height: size.height*0.03,
                  ),

                  flameLoading ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :

                  flames == '0'  ? Padding(
                    padding: const EdgeInsets.only(top: 0,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //  height: size.height*0.1,

                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width*0.4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('My Wallet',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.black,
                                                  fontSize: 16,fontWeight: FontWeight.w600),),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.9,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0,right: 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Container(
                                                      width: size.width*0.4,
                                                      child: Row(children: [
                                                        Container(

                                                          child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),

                                                        Container(

                                                          child: Text(' 0 Flames',
                                                            style: TextStyle(
                                                                fontFamily: 'Montserrat',
                                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                        ),
                                                      ],),
                                                    ),




                                                  ],),
                                              ),
                                            ),
                                          ],),
                                      ),
                                    ],),
                                ),




                                // SizedBox(
                                //   height: size.height*0.02,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) :

                  Padding(
                    padding: const EdgeInsets.only(top: 0,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //  height: size.height*0.1,

                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width*0.4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('My Wallet',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.black,
                                                  fontSize: 16,fontWeight: FontWeight.w600),),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.9,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0,right: 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Container(
                                                      width: size.width*0.4,
                                                      child: Row(children: [
                                                        Container(

                                                          child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),

                                                        Container(

                                                          child: Text(
                                                            getDiscount == 'yes' ? ' 0 Flames' :
                                                            ' $flames Flames',
                                                            style: TextStyle(
                                                                fontFamily: 'Montserrat',
                                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                        ),
                                                      ],),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(

                                        child: Column(children: [
                                          GestureDetector(
                                            onTap: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              if(double.parse(flames) > double.parse(total.toString())) {

                                                var snackBar = SnackBar(content: Text('Please add some more items to get this discount'
                                                  ,style: TextStyle(color: Colors.white),),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                              } else {

                                                if(getDiscount == '') {
                                                  setState(() {
                                                    getDiscount = 'yes';
                                                    discount = double.parse(flames.toString());

                                                    discountedTotal = double.parse(total.toString()) - double.parse(flames.toString());
                                                  });
                                                  prefs.setString('useFlame', 'yes');
                                                  prefs.setString('discount', discount.toString());
                                                  prefs.setString('discountTotal', discountedTotal.toString());
                                                  prefs.setString('flameId', flameId.toString());

                                                }
                                                else {
                                                  setState(() {
                                                    getDiscount = '';
                                                  });
                                                  prefs.setString('useFlame', 'no');
                                                }

                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                ],
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  stops: [0.0, 1.0],
                                                  colors:
                                                  getDiscount == '' ?
                                                  [
                                                    darkRedColor,
                                                    lightRedColor,
                                                  ] : [

                                                    Colors.green,
                                                    Colors.green,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  getDiscount == 'yes' ? 'Discounted' :
                                                  'Get Discount',
                                                  style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],),
                                      ),


                                    ],),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            'Payment Method',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.0,
                  ),
                  Column(children: [

                    Container(
                      height: tileHeight,
                      child: ListTile(
                        // tileColor: ,
                        // hoverColor: ,
                        onTap: () {
                          setState(() {
                            paymentMethod = 'COD';
                          });
                          print(paymentMethod.toString() + ' payment Method');
                        },
                        title:  Row(
                          children: [
                            Text('Cash on delivery', style:
                            TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        leading: Radio(
                          value: PaymentMethod.cash,
                          groupValue: _paymentMethod,
                          activeColor: darkRedColor,
                          onChanged: (PaymentMethod? value) {
                            setState(() {
                              _paymentMethod = value!;
                              paymentMethod = 'COD';

                            });
                          },
                        ),
                      ),
                    ),

                    Container(
                      height: tileHeight,
                      child: ListTile(
                        // tileColor: lightButtonGreyColor,
                        onTap: () {
                          setState(() {
                            paymentMethod = 'Credit';
                          });
                          print(paymentMethod.toString() + ' payment Method');
                        },
                        title:  Row(
                          children: [
                            Text('Debit / Credit Card',
                              style:
                              TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        leading: Radio(
                          value: PaymentMethod.creditDebit,
                          groupValue: _paymentMethod,
                          activeColor: darkRedColor,
                          onChanged: (PaymentMethod? value) {
                            setState(() {
                              _paymentMethod = value!;
                              paymentMethod = 'Credit';
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height*0.02,
                    ),



                  ],),

                  Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25,top: 4),
                          child: Text(
                            'Order Amount',                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Subtotal',
                              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Obx(()=>Text('R '+cartController.subTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                            // Text('\$30.99',
                            //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )),

                  cartController.addOnsTotal.toString() == '0' ? Container() :
                  Column(
                    children: [
                      SizedBox(
                        height: size.height*0.01,
                      ),
                      Container(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  'Addons total',
                                  style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Obx(()=>Text('R '+cartController.addOnsTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                                // Text('\$30.99',
                                //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                              ),
                            ],
                          )),
                    ],
                  ),

                 
                 

                  // SizedBox(
                  //   height: size.height*0.02,
                  // ),
                  //
                  // Container(
                  //   width: size.width,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.only(left: 25),
                  //         child: Text(
                  //           'Payment Method',
                  //           style: TextStyle(
                  //               fontFamily: 'Montserrat',
                  //               color: Colors.black,
                  //               fontSize: 15,
                  //               fontWeight: FontWeight.w600),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: size.height*0.02,
                  // ),
                  // Column(children: [
                  //
                  //   ListTile(
                  //     // tileColor: ,
                  //     // hoverColor: ,
                  //
                  //     onTap: () {
                  //       setState(() {
                  //         paymentMethod = 'COD';
                  //       });
                  //       print(paymentMethod.toString() + ' payment Method');
                  //     },
                  //     title:  Row(
                  //       children: [
                  //         Text('Cash on delivery', style:
                  //         TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //     leading: Radio(
                  //       value: PaymentMethod.cash,
                  //       groupValue: _paymentMethod,
                  //       activeColor: darkRedColor,
                  //       onChanged: (PaymentMethod? value) {
                  //         setState(() {
                  //           _paymentMethod = value!;
                  //           paymentMethod = 'COD';
                  //         });
                  //       },
                  //     ),
                  //   ),
                  //
                  //   ListTile(
                  //     // tileColor: lightButtonGreyColor,
                  //     onTap: () {
                  //       setState(() {
                  //         paymentMethod = 'Credit';
                  //       });
                  //       print(paymentMethod.toString() + ' payment Method');
                  //     },
                  //     title:  Row(
                  //       children: [
                  //         Text('Debit / Credit Card',
                  //           style:
                  //           TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //     leading: Radio(
                  //       value: PaymentMethod.creditDebit,
                  //       groupValue: _paymentMethod,
                  //       activeColor: darkRedColor,
                  //       onChanged: (PaymentMethod? value) {
                  //         setState(() {
                  //           _paymentMethod = value!;
                  //           paymentMethod = 'Credit';
                  //         });
                  //       },
                  //     ),
                  //   ),
                  //
                  //   SizedBox(
                  //     height: size.height*0.02,
                  //   ),
                  //
                  //
                  //
                  // ],),
                  //
                  // Container(
                  //     width: size.width,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 25),
                  //           child: Text(
                  //             'Order Amount',
                  //             style: TextStyle(
                  //                 fontFamily: 'Montserrat',
                  //                 color: Colors.black,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  // ),
                  // SizedBox(
                  //   height: size.height*0.03,
                  // ),
                  //
                  // Container(
                  //     width: size.width,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(left: 25),
                  //           child: Text(
                  //             'Subtotal',
                  //             style: TextStyle(
                  //                 fontFamily: 'Montserrat',
                  //                 color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                  //           ),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.only(right: 20),
                  //           child: Text(
                  //             'R ${subTotal}',
                  //             //'\$30.99',
                  //             style: TextStyle(
                  //                 fontFamily: 'Montserrat',
                  //                 color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),),
                  //         ),
                  //       ],
                  //     )),
                  //
                  SizedBox(
                    height: size.height*0.01,
                  ),

                  isDeliveryAvailable == 'yes' ?
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Delivery Fee',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 13,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              'R $deliveryFee',
                              //'\$30.99',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )) : Container(),

                  getDiscount == 'yes' ? SizedBox(
                    height: size.height*0.01,
                  ) : SizedBox(),
                  getDiscount == 'yes' ?   Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Discount',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(

                              'R ${discount}' ,
                              //'\$39.99',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )) : SizedBox(),
                  SizedBox(
                    height: size.height*0.01,
                  ),
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Total',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              getDiscount == 'yes' ?
                              'R ${discountedTotal}' :
                              'R ${total}',
                              //'\$39.99',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),),
                          ),
                        ],
                      ),
                  ),
                  SizedBox(
                    height: size.height*0.05,
                  ),




                  isLoading ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :
                  Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: Container(

                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                        ],
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
                            backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                            // elevation: MaterialStateProperty.all(3),
                            shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                          ),

                          onPressed: () {
                            //getFlames();
                            setState(() {
                              isLoading = true;
                            });

                            placeOrder();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(builder: (context) => OrderPlacedScreen()));
                            //
                          }, child: Text('Place Order', style: buttonStyle)),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),


                ],),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                child: Column(children: [

                  // SizedBox(
                  //   height: size.height*0.015,
                  // ),

                  Padding(
                    padding: const EdgeInsets.only(top: 0,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //  height: size.height*0.1,
                          width: size.width*0.6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height*0.02,
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Delivery Address',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                            fontSize: 14,fontWeight: FontWeight.w600),),
                                    ],),
                                ),

                                SizedBox(
                                  height: size.height*0.02,
                                ),

                                Container(
                                  width: size.width*0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0,right: 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: size.width*0.05,
                                          child: Image.asset('assets/images/locationIcon.png', fit: BoxFit.scaleDown,
                                            height: 15,
                                            color: Colors.black,
                                            width: 15,
                                          ),
                                        ),

                                        Container(
                                          width: size.width*0.8,
                                          child: Text(Address.toString(),
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                        ),


                                      ],),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height*0.02,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.03,
                  ),
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Order Detail',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                  ),
                  widget.cartItemList.isEmpty  ? Container(
                    child: Text('No cart item found',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    width: size.width*0.95,
                    //width: size.width*0.9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.cartItemList.length,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context,index
                          ) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            // width: size.width*0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: lightButtonGreyColor,
                                    spreadRadius: 2,
                                    blurRadius: 3
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8,),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            decoration: BoxDecoration(
                                              color: lightButtonGreyColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                height: size.height*0.07,
                                                width: size.width*0.2,
                                                fit: BoxFit.cover,
                                                imageUrl: imageConstUrlProduct+widget.cartItemList[index].product!.image.toString(),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                          ),

                                          Container(
                                            // height: size.height*0.07,
                                            width: size.width*0.65,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: size.height*0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: size.width*0.5,
                                                        child: Text(widget.cartItemList[index].product!.name.toString(),
                                                          style: TextStyle(color: Color(0xFF585858),
                                                              fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                                      ),

                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height*0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Quantity : ' + widget.cartItemList[index].quantity.toString(),
                                                        //quantity.toString(),
                                                        style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                                                      // widget.order.ordersItems![index].product!.price.toString()
                                                      Text('R '+ '${
                                                          int.parse(widget.cartItemList[index].product!.price.toString())*int.parse(widget.cartItemList[index].quantity.toString())
                                                      }',
                                                        style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height*0.01,
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
                                  height: size.height*0.01,
                                ),
                                widget.cartItemList[index].addon == null
                                    || widget.cartItemList[index].addon.toString() == '[]'
                                  //  || widget.cartItemList[index].addon.toString() ==  "[Instance of 'AddonElement']"
                                    ? Container() :
                                Container(
                                  width: size.width*0.95,
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 8,),
                                  child: Text('Addons',
                                    style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                                ),
                                SizedBox(height: 4,),

                                Container(
                                  width: size.width*0.95,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.cartItemList[index].addon!.length,
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context,addIndex
                                        ) {

                                      return
                                        widget.cartItemList[index].addon![addIndex].addon == null ? Container() :
                                        Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 20,bottom: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: size.width*0.7,
                                              child: Text(

                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '2' ?
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Chips)' :
                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ?
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString() + ' (Flavour)' :
                                                widget.cartItemList[index].addon![addIndex].addon!.name.toString()
                                                ,
                                                //quantity.toString(),
                                                style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                            ),
                                            // widget.order.ordersItems![index].product!.price.toString()
                                            widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '4' ||
                                                widget.cartItemList[index].addon![addIndex].addon!.categoryId.toString() == '1'
                                                ? Container() :
                                            Text('R '+widget.cartItemList[index].addon![addIndex].addon!.price.toString(),
                                              style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                      );

                                    },

                                  ),
                                ),
                                SizedBox(
                                  height: size.height*0.01,
                                ),
                                widget.cartItemList[index].specialInstruction.toString() == ''
                                    || widget.cartItemList[index].specialInstruction == null
                                    ? Container() :
                                Column(children: [
                                  Container(
                                    width: size.width*0.95,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(left: 8,),
                                    child: Text('Special Instruction',
                                      style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                                  ),
                                  SizedBox(height: 4,),
                                  Container(
                                    width: size.width*0.95,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(left: 8,),
                                    child: Text(widget.cartItemList[index].specialInstruction.toString(),
                                      style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 4,),
                                  ),
                                  SizedBox(height: 8,),
                                ],),


                              ],),
                            ),
                          ),
                        );
                      },

                    ),
                  ),
                  // widget.productList.isEmpty  ? Container(
                  //   child: Text('No cart item found',
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w500),),
                  // ) :
                  // SizedBox(
                  //   // height: size.height*0.25,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: widget.productList.length,
                  //     scrollDirection: Axis.vertical,
                  //     itemBuilder: (BuildContext context,index
                  //         ) {
                  //       return Column(children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(top: 16,),
                  //           child: Container(
                  //             width: size.width*0.9,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                     color: lightButtonGreyColor,
                  //                     spreadRadius: 2,
                  //                     blurRadius: 3
                  //                 )
                  //               ],
                  //             ),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(0.0),
                  //               child: Row(
                  //                 children: [
                  //
                  //                   Container(
                  //                     decoration: BoxDecoration(
                  //                       color: lightButtonGreyColor,
                  //                       borderRadius: BorderRadius.circular(10),
                  //                     ),
                  //                     child: ClipRRect(
                  //                       borderRadius: BorderRadius.circular(10),
                  //                       child: CachedNetworkImage(
                  //                         height: size.height*0.07,
                  //                         width: size.width*0.2,
                  //                         fit: BoxFit.cover,
                  //                         imageUrl: imageConstUrlProduct+widget.productList[index].image.toString(),
                  //                         errorWidget: (context, url, error) => Icon(Icons.error),
                  //                       ),
                  //                     ),
                  //                   ),
                  //
                  //                   Container(
                  //                     height: size.height*0.081,
                  //                     width: size.width*0.6,
                  //                     child: Padding(
                  //                       padding: const EdgeInsets.only(left: 8),
                  //                       child: Column(
                  //                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                         children: [
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(widget.productList[index].name.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858),
                  //                                     fontSize: 13,fontWeight: FontWeight.w500),),
                  //
                  //                             ],
                  //                           ),
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(
                  //                                 'Quantity : ' + widget.productList[index].quantity.toString(),
                  //                                 //quantity.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 13,fontWeight: FontWeight.w600),),
                  //                               Text('R '+widget.productList[index].price.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                  //                             ],
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //
                  //       ],);
                  //     },
                  //
                  //   ),
                  // ),

                  SizedBox(
                    height: size.height*0.03,
                  ),

                  flameLoading ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :

                  flames == '0'  ? Padding(
                    padding: const EdgeInsets.only(top: 0,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //  height: size.height*0.1,

                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width*0.4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('My Wallet',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.black,
                                                  fontSize: 16,fontWeight: FontWeight.w600),),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.9,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0,right: 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Container(
                                                      width: size.width*0.4,
                                                      child: Row(children: [
                                                        Container(

                                                          child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),

                                                        Container(

                                                          child: Text(' 0 Flames',
                                                            style: TextStyle(
                                                                fontFamily: 'Montserrat',
                                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                        ),
                                                      ],),
                                                    ),




                                                  ],),
                                              ),
                                            ),
                                          ],),
                                      ),
                                    ],),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) :

                  Padding(
                    padding: const EdgeInsets.only(top: 0,),
                    child: Container(
                      width: size.width*0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          //  height: size.height*0.1,

                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width*0.4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('My Wallet',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.black,
                                                  fontSize: 16,fontWeight: FontWeight.w600),),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.9,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0,right: 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Container(
                                                      width: size.width*0.4,
                                                      child: Row(children: [
                                                        Container(

                                                          child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),

                                                        Container(

                                                          child: Text(
                                                            getDiscount == 'yes' ? ' 0 Flames' :
                                                            ' $flames Flames',
                                                            style: TextStyle(
                                                                fontFamily: 'Montserrat',
                                                                color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                        ),
                                                      ],),
                                                    ),




                                                  ],),
                                              ),
                                            ),
                                          ],),
                                      ),
                                      Container(

                                        child: Column(children: [
                                          GestureDetector(
                                            onTap: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              if(double.parse(flames) > double.parse(pickUpTotal.toString())) {

                                                var snackBar = SnackBar(content: Text('Please add some more items to get this discount'
                                                  ,style: TextStyle(color: Colors.white),),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                              } else {

                                                if(getDiscount == '') {
                                                  setState(() {
                                                    getDiscount = 'yes';
                                                    discount = double.parse(flames.toString());

                                                    discountedTotalPickUp = double.parse(pickUpTotal.toString()) - double.parse(flames.toString());
                                                  });
                                                  prefs.setString('useFlame', 'yes');
                                                  prefs.setString('discount', discount.toString());
                                                  prefs.setString('discountTotal', discountedTotalPickUp.toString());
                                                  prefs.setString('flameId', flameId.toString());

                                                }
                                                else {
                                                  setState(() {
                                                    getDiscount = '';
                                                  });
                                                  prefs.setString('useFlame', 'no');
                                                }

                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                ],
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  stops: [0.0, 1.0],
                                                  colors:
                                                  getDiscount == '' ?
                                                  [
                                                    darkRedColor,
                                                    lightRedColor,
                                                  ] : [

                                                    Colors.green,
                                                    Colors.green,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  getDiscount == 'yes' ? 'Discounted' :
                                                  'Get Discount', style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w600),),
                                              ),
                                            ),
                                          ),
                                        ],),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),


                  Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            'Payment Method',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.0,
                  ),
                  Column(children: [

                    Container(
                      height:tileHeight,
                      child: ListTile(
                        // tileColor: ,
                        // hoverColor: ,

                        onTap: () {
                          setState(() {
                            paymentMethod = 'COD';
                          });
                          print(paymentMethod.toString() + ' payment Method');
                        },
                        title:  Row(
                          children: [
                            Text('Cash on delivery', style:
                            TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        leading: Radio(
                          value: PaymentMethod.cash,
                          groupValue: _paymentMethod,
                          activeColor: darkRedColor,
                          onChanged: (PaymentMethod? value) {
                            setState(() {
                              _paymentMethod = value!;
                              paymentMethod = 'COD';
                            });
                          },
                        ),
                      ),
                    ),

                    Container(
                      height:tileHeight,
                      child: ListTile(
                        // tileColor: lightButtonGreyColor,
                        onTap: () {
                          setState(() {
                            paymentMethod = 'Credit';
                          });
                          print(paymentMethod.toString() + ' payment Method');
                        },
                        title:  Row(
                          children: [
                            Text('Debit / Credit Card',
                              style:
                              TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        leading: Radio(
                          value: PaymentMethod.creditDebit,
                          groupValue: _paymentMethod,
                          activeColor: darkRedColor,
                          onChanged: (PaymentMethod? value) {
                            setState(() {
                              _paymentMethod = value!;
                              paymentMethod = 'Credit';
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height*0.02,
                    ),



                  ],),

                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Order Amount',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Subtotal',
                              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Obx(()=>Text('R '+cartController.subTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                            // Text('\$30.99',
                            //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: size.height*0.01,
                  ),
                  cartController.addOnsTotal.toString() == '0' ? Container() :
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Addons total',
                              style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Obx(()=>Text('R '+cartController.addOnsTotal.toString(),style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),)),
                            // Text('\$30.99',
                            //   style: TextStyle(color: Colors.grey, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )),
                  getDiscount == 'yes' ? SizedBox(
                    height: size.height*0.01,
                  ) : SizedBox(),
                  getDiscount == 'yes' ?   Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Discount',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(

                              'R ${discount}' ,
                              //'\$39.99',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 14,fontWeight: FontWeight.w400),),
                          ),
                        ],
                      )) : SizedBox(),
                  SizedBox(
                    height: size.height*0.01,
                  ),
                  Container(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Total',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              getDiscount == 'yes' ?
                              'R ${discountedTotalPickUp}' :
                              'R ${pickUpTotal}',
                              //'\$39.99',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black, fontSize: 16,fontWeight: FontWeight.w600),),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: size.height*0.05,
                  ),


                  isLoading ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :

                  Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: Container(

                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                        ],
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
                            backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                            // elevation: MaterialStateProperty.all(3),
                            shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                          ),

                          onPressed: () {





                            setState(() {
                              isLoading = true;
                            });

                            placeOrder();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(builder: (context) => OrderPlacedScreen()));
                            //
                          }, child: Text('Place Order', style: buttonStyle)),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),


                ],),
              ),
            )
          ],
        )),

      ])),

    );
  }
}
