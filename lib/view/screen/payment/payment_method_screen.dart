import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/cartModel.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/view/screen/addCard/add_card_screen.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/orderPlaced/order_placed_screen.dart';
import 'package:figma_new_project/view/screen/payment/simple_webview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum PaymentMethod { visa, cash }
class PaymentMethodScreen extends StatefulWidget {
  final String orderId;
  final List<ProductModel> productList1;
  final List<Map<String, dynamic>> productListMap;
  const PaymentMethodScreen({Key? key,
  required this.productList1,
  required this.orderId,
  required this.productListMap,
  }) : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen>  with SingleTickerProviderStateMixin {
  var darkRedColor =  Color(0xff000000);
  bool isLoading = false;
  PaymentMethod _paymentMethod = PaymentMethod.visa;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardCVCController = TextEditingController();
  final TextEditingController _cardEdateController = TextEditingController();

  final cartController = Get.put(AddToCartController());
  String total = '0', restaurantId = '';
  String isAddressThere = 'no';
  String deliveryType = '';
  List<CartModel> cartList = [];
  List<ProductModel> _productList = [];
  String isDeliveryAvailable = '';
  String restaurantName = '';
  String restaurantImage = '';
  String Address = '',addressUser = '';


  @override
  void initState() {
    super.initState();
    checkAddress();
    setState(() {isAddressThere = 'no';});
    getPaymentData();
    if( widget.orderId == 'test' ) {}
    else {getAddedCart();}
    setState(() {isLoading = false;});
    print(widget.productList1.length.toString() + ' length in payment');
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

  getPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null) {
      FirebaseFirestore.instance.collection('UserCardDetais').doc(prefs.getString('userId')).get().then((value) {

        if(value.exists) {

          setState(() {

            _cardHolderNameController.text = value['name'];
            _cardNumberController.text = value['number'];
            _cardCVCController.text = value['cvc'];
            _cardEdateController.text = value['date'];
          });
        } else {

        }


      });
    }
  }

  // makePayment() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   print('we are in makepayment');
  //   var headers = {
  //     'Cookie': 'pf_bid=1.9b70085110adfe5c.1687245602',
  //     'Content-Type': 'application/json'
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse('https://sandbox.payfast.co.za/eng/process'))..followRedirects = true;
  //   request.fields.addAll({
  //     'merchant_id': '10029889',
  //     'merchant_key': 'w2vjpg42fc7a6',
  //     'amount': prefs.getString('finalTotal') != null ? prefs.getString('finalTotal').toString() : '20' ,
  //     'item_name': 'test',
  //    // 'return_url': 'https://developers.payfast.co.za/docs#step_1_form_fields'
  //   });
  //
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     print('200');
  //     print(await response.stream.bytesToString());
  //   }
  //   else {
  //     // print(response.reasonPhrase);
  //     // print(response.statusCode);
  //     // print(await response.stream.bytesToString());
  //     await response.stream.bytesToString().then((value) {
  //       print(value.toString());
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => WebViewExample(content: '''+${value}+''',)),
  //       );
  //       // print(await response.stream.bytesToString());
  //       print(response.reasonPhrase);
  //       print(response.statusCode.toString() + ' Payment code 3' );
  //     });
  //
  //
  //   }
  //
  //
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
    print(widget.productListMap.toList().toString() + ' This is map');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie'
      };
      var request = http.Request('POST', Uri.parse('${apiBaseUrl}api/order_create'));
      request.body = json.encode({
        "transaction_id": Random().nextInt(1000000).toString(),
        "restaurant_id": restaurantId,
        "address": addressUser.toString(),
        "delivery_type": deliveryType.toString(),
        "delivery_fee": prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
        "items": widget.productListMap
      });
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
        // var snackBar = SnackBar(content: Text(data['message'].toString()
        //   ,style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.green,
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        cartController.clearCart();

//        makePayment();

        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => OrderPlacedScreen(orderId: data['order_no'].toString(),productList: _productList,)));
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) =>
        //         PaymentMethodScreen(orderId: data['order_no'].toString(),productList: widget.productList, productListMap: [],)));

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
        // final responseData = await response.stream.bytesToString();
        // final data = json.decode(responseData);
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


  getAddedCart() async {


    try {

      var headers = {
        'Cookie': 'restaurant_session=$cookie'
      };
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/cart'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        final responseData = await response.stream.bytesToString();
        //cartController.fetchCartItems();
        setState(() {
          cartList = List<CartModel>.from(json.decode(responseData).map((x) => CartModel.fromJson(x)));

        });

        if(cartList.isNotEmpty) {

          for(int i=0; i<cartList.length; i++) {
            setState(() {
              _productList.add(
                  ProductModel(
                      id: cartList[i].product!.id.toString(),
                      cartId: cartList[i].id.toString(),
                      image: cartList[i].product!.image.toString(),
                      name: cartList[i].product!.name.toString(),
                      quantity: cartList[i].quantity.toString(),
                      price: cartList[i].product!.price.toString())
              );
            });

            print(cartList.length.toString() + ' length' + i.toString());
            print(_productList.length.toString() + ' length');


          }

        }



      }
      else {

      }

    } catch(e) {
     print(e.toString());
      }

    }


  // deleteCart() async {
  //
  //
  //   var headers = {
  //     'Cookie': 'restaurant_session=$cookie'
  //   };
  //   print('we are in delete cart');
  //
  //   for(int i=0 ;i<widget.productList.length; i++) {
  //     print(widget.productList[i].cartId.toString() + ' This is the cart Id $i');
  //     var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/delete_cart/${widget.productList[i].cartId.toString()}'));
  //
  //     request.headers.addAll(headers);
  //
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       print(' deleted from cart ${widget.productList[i].cartId.toString()}');
  //       //${widget.productList[number].cartId.toString()}
  //     }
  //     else {
  //       print(response.reasonPhrase);
  //     }
  //
  //   }
  //
  //   // int number = 0;
  //   //
  //   //
  //   //
  //   // do {
  //   //
  //   //   var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/delete_cart/${widget.productList[number].cartId.toString()}'));
  //   //
  //   //   request.headers.addAll(headers);
  //   //
  //   //   http.StreamedResponse response = await request.send();
  //   //
  //   //   if (response.statusCode == 200) {
  //   //     print(' deleted from cart ${widget.productList[number].cartId.toString()}');
  //   //     //${widget.productList[number].cartId.toString()}
  //   //   }
  //   //   else {
  //   //     print(response.reasonPhrase);
  //   //   }
  //   //
  //   //
  //   //   number++;
  //   //
  //   //   if(number == widget.productList.length) {
  //
  //   //   }
  //   //
  //   // } while (number < widget.productList.length);
  //
  //
  //
  //
  //
  //
  // }


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
    final size = MediaQuery.of(context).size;
    //print(widget.productList.length.toString() + ' length');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Payment Method',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:2)));
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
        child: Column(children: [

          SizedBox(
            height: size.height*0.015,
          ),

          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()));
            },
            title:  Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.asset('assets/images/credit.png', fit: BoxFit.scaleDown,
                    height: 30,
                    width: 50,
                  ),
                ),
                Text('Debit / Credit Card'),
              ],
            ),
            leading: Radio(
              value: PaymentMethod.visa,
              groupValue: _paymentMethod,
              activeColor: darkRedColor,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
          ),

          _paymentMethod == PaymentMethod.visa ?

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: lightButtonGreyColor,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardHolderNameController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,

                      ),
                      onChanged: (value) {
                        // setState(() {
                        //   userInput.text = value.toString();
                        // });
                      },
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        focusColor: Colors.white,

                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Image.asset('assets/images/credit.png', fit: BoxFit.scaleDown,
                            height: 30,
                            width: 50,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "Card Holder Name",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Holder Name',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,

                      ),
                      onChanged: (value) {
                        // setState(() {
                        //   userInput.text = value.toString();
                        // });
                      },
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        focusColor: Colors.white,
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "Card Number",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Number',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardCVCController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,

                      ),
                      onChanged: (value) {
                        // setState(() {
                        //   userInput.text = value.toString();
                        // });
                      },
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        focusColor: Colors.white,
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "CVC",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'CVC',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: _cardEdateController,
                      keyboardType: TextInputType.datetime,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,

                      ),
                      onChanged: (value) {
                        // setState(() {
                        //   userInput.text = value.toString();
                        // });
                      },
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        focusColor: Colors.white,
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "DD/MM/YY",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Expiry Date',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                ],),
              )

              ,),
          ) : Container(),

          ListTile(
            title:  Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.asset('assets/images/cash.png', fit: BoxFit.scaleDown,
                    height: 20,
                    width: 50,
                  ),
                ),
                Text('Cash'),
              ],
            ),
            leading: Radio(
              value: PaymentMethod.cash,
              groupValue: _paymentMethod,
              activeColor: darkRedColor,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
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
                    Color(0xffBB1B20),
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

                    if(_paymentMethod == PaymentMethod.visa) {

                      if(_cardHolderNameController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card holder name is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      } else if(_cardNumberController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card number is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);


                      } else if(_cardCVCController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card cvc is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      } else if(_cardEdateController.text.isEmpty) {
                        var snackBar = SnackBar(content: Text('Card expire date is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        placeOrder();
                      }

                    } else {

                      if( widget.orderId == 'test') {

                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        placeOrder();
                      }


                    }
                    }, child: Text(
                  widget.orderId == 'test' ? 'Pay Now' :
                  'Place Order', style: buttonStyle)),
            ),
          ),
          SizedBox(
            height: size.height*0.02,
          ),


        ],),
      ),

    );
  }
}
