import 'dart:async';

import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/view/screen/myOrders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class OrderPlacedScreen extends StatefulWidget {
  final String orderId;
  final List<ProductModel> productList;
  //final
  const OrderPlacedScreen({Key? key, required this.orderId, required this.productList}) : super(key: key);

  @override
  _OrderPlacedScreenState createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  final cartController = Get.put(AddToCartController());
  int y=0;
  bool isLoading = false;
  String itemDeleted = '';



  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      y=0;
      isLoading = false;
      itemDeleted = '';
    });
    deleteCart1();
    super.initState();
  }




//   Future<void> deleteItem(String id) async {
//
//     try {
//
//       var headers = {
//         'Cookie': 'restaurant_session=kFgvAjt0MzIHYUCsQ5CVzMk1LtSl2pdradtLAmHj'
//       };
//       var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/delete_cart/$id'));
//
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//
//         print(' deleted from cart '); // ${widget.productList[i].cartId.toString()}
//
//         // if(i == widget.productList.length-1 ) {
//
//         setState(() {
//           isLoading = false;
//         });
//
//         Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => MyOrdersScreen()));
//
//         //}
//
//
//
//       }
//       else {
//         setState(() {
//           isLoading = false;
//         });
//         print(await response.stream.bytesToString());
//         print(response.reasonPhrase);
//
//       }
//
//     } on Exception catch (exception) {
//       setState(() {
//         isLoading = false;
//       });
//       // setState(() {
//       //   isLoading = false;
//       // });
//       //   print(' else ${widget.productList[i].cartId.toString()}' + exception.toString() );
//       var snackBar = SnackBar(content: Text(exception.toString()
//         ,style: TextStyle(color: Colors.white),),
//         backgroundColor: Colors.green,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
//     } catch (error) {
//       setState(() {
//         isLoading = false;
//       });
//       //print(' else ${widget.productList[i].cartId.toString()}' + error.toString() );
//       // setState(() {
//       //   isLoading = false;
//       // });
//       var snackBar = SnackBar(content: Text(error.toString()
//         ,style: TextStyle(color: Colors.white),),
//         backgroundColor: Colors.green,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//
//   }
//
//
//   deleteCart() async {
//
//     print('we are in delete cart');
//     print(widget.productList.length.toString() + ' length');
//
//     for(int i=0 ;i<widget.productList.length; i++) {
//       print(widget.productList[i].cartId.toString() + ' This is the cart Id $i');
//
//       try {
//         // if(i == widget.productList.length-1) {
//         //   setState(() {
//         //     itemDeleted = 'deleted';
//         //   });
//         //   print('items deleted');
//         //   timer.cancel();
//         // }
//         await deleteItem(widget.productList[i].cartId.toString());
//       } catch (e) {
//         print(e);
//       }
//
// //       final timer = Timer.periodic(Duration(seconds: 5), (timer) async {
// //
// //       });
// //
// // // To stop the loop after 1 minute
// //       await Future.delayed(Duration(minutes: 1));
// //       timer.cancel();
//
//
//
//
//
//
//
//     }
//
//
//
//
//
//     int number = 0;
//
//
//
//     do {
//
//       var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/delete_cart/${widget.productList[number].cartId.toString()}'));
//
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//         print(' deleted from cart ${widget.productList[number].cartId.toString()}');
//         //${widget.productList[number].cartId.toString()}
//       }
//       else {
//         print(response.reasonPhrase);
//       }
//
//
//       number++;
//
//       if(number == widget.productList.length) {
//
//       }
//
//     } while (number < widget.productList.length);
//
//
//
//
//
//
//   }



  // deleteCart() async {
  //   var headers = {
  //     'Cookie': 'restaurant_session=$cookie'
  //   };
  //
  //   int number = 0;
  //   do {
  //
  //     var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/delete_cart/${widget.productList[number].cartId.toString()}'));
  //
  //     request.headers.addAll(headers);
  //
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       print('${widget.productList[number].cartId.toString()} deleted from cart');
  //     }
  //     else {
  //       print(response.reasonPhrase);
  //     }
  //
  //
  //     number++;
  //
  //     if(number == widget.productList.length) {
  //       cartController.clearCart();

  //     }
  //
  //   } while (number < widget.productList.length);
  //
  //
  //
  //
  //
  //
  // }


  deleteCart1() async {
    print('we are in delete cart');

    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };
    print('we are in delete cart');

    int number = 0;
    do {

      var request = http.Request('GET', Uri.parse('${apiBaseUrl}api/delete_cart/${widget.productList[number].cartId.toString()}'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(' deleted from cart ${widget.productList[number].cartId.toString()}');
        cartController.clearCart();
        //${widget.productList[number].cartId.toString()}
      }
      else {
        print(response.reasonPhrase);
      }


      number++;

      if(number == widget.productList.length) {

      }

    } while (number < widget.productList.length);






  }

  @override
  Widget build(BuildContext context) {
   // deleteCart();
    // setState(() {
    //   y=0;
    //   isLoading = false;
    // });
    Future<bool> _onWillPop() async {
      return (await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Orders'),
          content: new Text('Do you want to see your orders?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
              //  cartController.clearCart();
                Navigator.of(context).pop(true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashBoardScreen(index: 0)));
                });
              },
              child: new Text('No'),
            ),
            TextButton(
              onPressed: () {
                //cartController.clearCart();
                Navigator.of(context).pop(true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyOrdersScreen()));
                });
              },
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ?? false;
    }

    final size = MediaQuery.of(context).size;
    // if(y==0) {
    //   clearCart();
    // }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(

        body: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,

            children: [
            Container(
                width: size.width,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height*0.2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 70,
                          backgroundImage: AssetImage( 'assets/images/check.png'),
                        ),
                      ],
                    ),

                  ],
                )),
            Container(
                width: size.width,
                height: size.height,
                child:   Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [



                    SizedBox(
                      height: size.height*0.45,
                    ),

                    Container(
                      width: size.width*0.55,
                      child: Center(
                          child: Text(

                            widget.orderId.toString() == 'null' ? 'Congratulations! your order has been updated. ' :
                            'Congratulations! your order has been placed. '
                            ,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87, fontSize: 20,),)
                      ),
                    ),

                    SizedBox(
                      height: size.height*0.03,
                    ),
                    widget.orderId.toString() == 'null' ? Container() :
                    Container(
                      width: size.width*0.7,
                      child: Center(
                          child: Text('Order ID: ${widget.orderId.toString()} ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: darkRedColor, fontSize: 25,fontWeight: FontWeight.bold),)
                      ),
                    ),

                    SizedBox(
                      height: size.height*0.1,
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

                            onPressed: (){
                             // cartController.clearCart();



                              // if(itemDeleted == 'deleted') {
                              //   setState(() {
                              //     isLoading = false;
                              //   });
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(builder: (context) => MyOrdersScreen()));
                              // } else {
                              //   setState(() {
                              //     isLoading = true;
                              //   });
                              // }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyOrdersScreen()));

                            }, child: Text('Go to orders', style: buttonStyle)),
                      ),
                    ),
                    SizedBox(
                      height: size.height*0.075,
                    ),


                  ],),

            ),
          ],),
        ),



      ),
    );
  }
}
