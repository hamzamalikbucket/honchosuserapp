

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/orderPlaced/order_placed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
// #enddocregion platform_imports




class WebViewExample extends StatefulWidget {
  final String url;
  final String deliveryFee;
  final String deliveryType;
  final String address;
  final String restaurantId;
  final String isAddressThere;
  final List<ProductModel> productList;
  final List<Map<String, dynamic>> productListMap;

  const WebViewExample({super.key,
    required this.url,
    required this.deliveryFee,
    required this.deliveryType,
    required this.address,
    required this.isAddressThere,
    required this.productListMap,
    required this.restaurantId,
    required this.productList

  });

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
  final cartController = Get.put(AddToCartController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
               isLoading= false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (
            request.url.startsWith('https://www.payfast.co.za/eng/process/finish/')
            || request.url.toString().startsWith('https://sandbox.payfast.co.za/eng/process/finish/')


            ) {
              debugPrint('blocking navigation to ${request.url}');
             // popNow();
              return NavigationDecision.navigate;
            }
            else if(
            request.url.startsWith('http://www.yourdomain.co.za/cancel')
            ) {
              debugPrint('blocking navigation to we are in payment cancel ${request.url}');
              popNow();
              return NavigationDecision.prevent;
            }
            else if(
            request.url.startsWith('http://www.yourdomain.co.za/return')
            ) {
              placeOrder();
              debugPrint('blocking navigation to we are in return ${request.url}');
              //popNow();
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }





  popNow() async {
    Navigator.of(context).pop();
  }


  placeOrder() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();


    print(widget.productListMap.toList().toString() + ' This is map');


    try {
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie'
      };
      var request = http.Request('POST', Uri.parse('${apiBaseUrl}api/order_create'));
      request.body = json.encode({
        "transaction_id": Random().nextInt(1000000).toString(),
        "restaurant_id": widget.restaurantId,
        "address": widget.address.toString(),
        "delivery_type": widget.deliveryType.toString(),
        "delivery_fee": widget.deliveryFee, //prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
        "items": widget.productListMap
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        updateFlameStatus();
        //  deleteCart();

        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        if(widget.isAddressThere != 'yes') {
          FirebaseFirestore.instance.collection('UserAddress').doc().set({
            'address':prefs.getString('userAddress'),
            'lat':prefs.getDouble('lat'),
            'long':prefs.getDouble('long'),
            'uid':prefs.getString('userId'),
          }).then((value) {
            print('address saved');
          });
        }


        var snackBar = SnackBar(content: Text('Order Placed Successfully'
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        cartController.clearCart();




        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderPlacedScreen(orderId: data['order_no'].toString(),productList: widget.productList,)));
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


        var snackBar = SnackBar(content: Text(response.reasonPhrase.toString()
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

    } on Exception catch (exception) {


      var snackBar = SnackBar(content: Text(exception.toString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } catch (error) {

      var snackBar = SnackBar(content: Text(error.toString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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


  // placeOrderNow() async {
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(getDiscount == 'yes') {
  //     print(pickUpTotal.toString()+ ' Pick Up' );
  //     makePayment(pickUpTotal);
  //
  //   } else {
  //     print(total.toString()+ ' delivery ' );
  //     makePayment(total);
  //   }
  //   if(_tabController!.index == 1) {
  //     if(getDiscount == 'yes') {
  //       print(pickUpTotal.toString()+ ' Pick Up' );
  //       prefs.setString('finalTotal', discountedTotalPickUp.toString());
  //     } else {
  //       print(pickUpTotal.toString()+ ' Pick Up' );
  //       prefs.setString('finalTotal', pickUpTotal);
  //     }
  //
  //   }
  //   else {
  //     if(getDiscount == 'yes') {
  //       print(pickUpTotal.toString()+ ' Pick Up' );
  //       prefs.setString('finalTotal', discountedTotal.toString());
  //     } else {
  //       print(total.toString()+ ' delivery ' );
  //       prefs.setString('finalTotal', total.toString());
  //     }
  //
  //   }
  //   if(prefs.getString('userAddress') != null) {
  //     setState(() {
  //       addressUser =  prefs.getString('userAddress')!;
  //       print(addressUser.toString()+ ' userAddress');
  //       //name =  prefs.getString('userName')!;
  //     });
  //   }
  //   print(productListMap.toList().toString() + ' This is map');
  //
  //
  //   try {
  //     var headers = {
  //       'Content-Type': 'application/json',
  //       'Cookie': 'restaurant_session=$cookie'
  //     };
  //     var request = http.Request('POST', Uri.parse('https://restaurant.wettlanoneinc.com/api/order_create'));
  //     request.body = json.encode({
  //       "transaction_id": Random().nextInt(1000000).toString(),
  //       "restaurant_id": restaurantId,
  //       "address": addressUser.toString(),
  //       "delivery_type": deliveryType.toString(),
  //       "delivery_fee": prefs.getString('delivery') == 'yes' ? prefs.getString('deliveryFee').toString() :  '0',
  //       "items": productListMap
  //     });
  //     request.headers.addAll(headers);
  //
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       updateFlameStatus();
  //       //  deleteCart();
  //
  //       final responseData = await response.stream.bytesToString();
  //       final data = json.decode(responseData);
  //
  //       if(isAddressThere != 'yes') {
  //         FirebaseFirestore.instance.collection('UserAddress').doc().set({
  //           'address':prefs.getString('userAddress'),
  //           'lat':prefs.getDouble('lat'),
  //           'long':prefs.getDouble('long'),
  //           'uid':prefs.getString('userId'),
  //         }).then((value) {
  //           print('address saved');
  //         });
  //       }
  //
  //
  //       setState(() {
  //         isLoading = false;
  //       });
  //       // var snackBar = SnackBar(content: Text(data['message'].toString()
  //       //   ,style: TextStyle(color: Colors.white),),
  //       //   backgroundColor: Colors.green,
  //       // );
  //       // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       cartController.clearCart();
  //
  //       if(getDiscount == 'yes') {
  //         print(pickUpTotal.toString()+ ' Pick Up' );
  //         makePayment(pickUpTotal);
  //
  //       } else {
  //         print(total.toString()+ ' delivery ' );
  //         makePayment(total);
  //       }
  //
  //
  //       // Navigator.pushReplacement(
  //       //     context,
  //       //     MaterialPageRoute(builder: (context) => OrderPlacedScreen(orderId: data['order_no'].toString(),productList: _productList,)));
  //       // Navigator.pushReplacement(
  //       //     context,
  //       //     MaterialPageRoute(builder: (context) =>
  //       //         PaymentMethodScreen(orderId: data['order_no'].toString(),productList: widget.productList, productListMap: [],)));
  //
  //     }
  //     else if (response.statusCode == 420) {
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       var snackBar = SnackBar(content: Text('Session expires login to continue'
  //         ,style: TextStyle(color: Colors.white),),
  //         backgroundColor: Colors.red,
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       await prefs.remove('userEmail').then((value){
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => LoginScreen()),
  //         );
  //       });
  //     }
  //     else {
  //       // final responseData = await response.stream.bytesToString();
  //       // final data = json.decode(responseData);
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       var snackBar = SnackBar(content: Text(response.reasonPhrase.toString()
  //         ,style: TextStyle(color: Colors.white),),
  //         backgroundColor: Colors.green,
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //
  //   } on Exception catch (exception) {
  //
  //     setState(() {
  //       isLoading = false;
  //     });
  //     var snackBar = SnackBar(content: Text(exception.toString()
  //       ,style: TextStyle(color: Colors.white),),
  //       backgroundColor: Colors.green,
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //
  //   } catch (error) {
  //
  //     setState(() {
  //       isLoading = false;
  //     });
  //     var snackBar = SnackBar(content: Text(error.toString()
  //       ,style: TextStyle(color: Colors.white),),
  //       backgroundColor: Colors.green,
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,size: 20,), onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashBoardScreen(index: 0)));

        },),
        backgroundColor: darkRedColor,
        centerTitle: true,
        title: const Text('Payment'),
      ),
      body:
      Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          isLoading ? Center( child: CircularProgressIndicator(
            color: darkRedColor,
            strokeWidth: 1,
          ),)
              : Stack(),
        ],
      ),





    );
  }

}

