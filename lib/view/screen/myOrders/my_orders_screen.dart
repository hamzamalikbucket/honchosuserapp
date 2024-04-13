import 'dart:convert';
import 'dart:developer';

import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/orderModel.dart' as orderModel;
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/orderDetail/order_detail_screen.dart';
import 'package:figma_new_project/view/screen/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  String isListEmpty = '';
  TabController? _tabController;
  String orders = 'Active Orders', accepting = '', readyToCollect = '', collected = '', delivered = '';
  int _selectedIndex = 0;
  List<orderModel.OrderModel> ordersList = [];
  List<orderModel.OrderModel> pendingOrdersList = [];
  bool isLoading = false;
  int totalAmount = 0;

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

  myOrders() async {
    print('we are in orders');
    setState(() {
      isLoading = true;
    });
    var headers = {'Cookie': 'restaurant_session=$cookie'};

    try {
      var request = http.Request('GET', Uri.parse('${apiBaseUrl}order'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print(response.reasonPhrase.toString());
      if (response.statusCode == 200) {
        print('GET we are in 200');
        setState(() {
          ordersList.clear();
        });
        final responseData = await response.stream.bytesToString();
        log('here printing API Response ${responseData}');
        // cartController.fetchCartItems();
        setState(() {
          ordersList = List<orderModel.OrderModel>.from(json.decode(responseData).map((x) => orderModel.OrderModel.fromJson(x)));
        });
        // print(await response.stream.bytesToString());

        // for(int i=0 ; i<ordersList.length; i++) {
        //
        //   if(ordersList[i].status.toString() == 'Accepting order') {
        //     setState(() {
        //       accepting = 'yes';
        //     });
        //   }
        //  else if(ordersList[i].status.toString() == 'Ready for collection') {
        //     setState(() {
        //       readyToCollect = 'yes';
        //     });
        //   } else if (ordersList[i].status.toString() == 'Collected') {
        //
        //     setState(() {
        //
        //       collected = 'yes';
        //     });
        //
        //   } else if(ordersList[i].status.toString() == 'Delivered') {
        //
        //     setState(() {
        //
        //       delivered = 'yes';
        //     });
        //
        //   }
        //
        // }

        if (ordersList.isEmpty) {
          setState(() {
            isListEmpty = 'yes';
            isLoading = false;
          });
        } else {
          setState(() {
            isListEmpty = 'no';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 302) {
        print('GET we are in 302');
        setState(() {
          ordersList.clear();
        });
        //final responseData = await response.stream.bytesToString();
        // cartController.fetchCartItems();
        setState(() {
          //  ordersList = List<OrderModel>.from(json.decode(responseData).map((x) => OrderModel.fromJson(x)));
          isLoading = false;
        });
        //print(await response.stream.bytesToString());
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
        print('else ');
        setState(() {
          isLoading = false;
        });
        print(response.reasonPhrase);
      }
    } on Exception catch (exception) {
      setState(() {
        isLoading = false;
      });
      // var snackBar = SnackBar(content: Text(exception.toString()
      //   ,style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // var snackBar = SnackBar(content: Text(error.toString()
      //   ,style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isListEmpty = '';
      accepting = '';
      readyToCollect = '';
      collected = '';
      delivered = '';
    });
    myOrders();
    setState(() {
      orders = 'Active Orders';
    });
    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
      if (_tabController!.index == 0) {
        setState(() {
          orders = 'Active Orders';
        });
      } else if (_tabController!.index == 1) {
        setState(() {
          orders = 'Ready';
        });
      } else if (_tabController!.index == 2) {
        setState(() {
          orders = 'Collected';
        });
      } else {
        setState(() {
          orders = 'Delivered Orders';
        });
      }
      print("Selected Index: " + _tabController!.index.toString());
    });
  }

  getIndex() {
    if (_tabController!.index == 0) {
      setState(() {
        orders = 'Active Orders';
      });
    } else if (_tabController!.index == 1) {
      setState(() {
        orders = 'Ready';
      });
    } else if (_tabController!.index == 2) {
      setState(() {
        orders = 'Collected';
      });
    } else {
      setState(() {
        orders = 'Delivered Orders';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //  getIndex();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: lightButtonGreyColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Orders',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              //   Navigator.pop(context);
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
          : (ordersList.isEmpty && isListEmpty == 'yes')
              ? Center(
                  child: Container(
                    child: Text('No Orders Found'),
                  ),
                )
              : SizedBox(
                  // height: size.height*0.25,
                  child: RefreshIndicator(
                    onRefresh: () => myOrders(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ordersList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, index) {
                        //print(DateTime.parse(ordersList[index].createdAt!).toLocal().toString());
                        print(ordersList.length);
                        // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                        //   totalAmount = totalAmount +
                        // }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
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
                                        SizedBox(
                                          height: size.height * 0.08,
                                          width: size.width * 0.25,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              'assets/images/order.png', fit: BoxFit.scaleDown,
                                              height: size.height * 0.08,
                                              width: size.width * 0.25,
                                              // height: 80,
                                              // width: 80,
                                            ),
                                          ),
                                        ),
                                        Container(
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Order ID: ${ordersList[index].orderNo.toString()}',
                                                      style: TextStyle(color: Color(0xFF585858), fontSize: 13, fontWeight: FontWeight.w600),
                                                    ),
                                                    // SizedBox(
                                                    //   height: 20,
                                                    //   width: 20,
                                                    //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                                    //
                                                    //     // height: 80,
                                                    //     // width: 80,
                                                    //   ),
                                                    //),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'items : ${ordersList[index].ordersItems!.length}',
                                                      style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${DateFormat.yMMMMd().format(ordersList[index].createdAt!.toLocal())} '
                                                          ' ${'${DateFormat.jm().format(ordersList[index].createdAt!.toLocal())}'}',
                                                      style: TextStyle(
                                                        color: Color(0xFF585858),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),

                                                    // Text('\$30.99',
                                                    //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: ordersList[index].status.toString() == 'Accepting order' || ordersList[index].status.toString() == 'Pending'
                                                              ? Colors.blue
                                                              : ordersList[index].status.toString() == 'Preparing your meal'
                                                                  ? Colors.indigo
                                                                  : ordersList[index].status.toString() == 'Ready for collection'
                                                                      ? Colors.teal
                                                                      : ordersList[index].status.toString() == 'Collected'
                                                                          ? Colors.deepOrangeAccent
                                                                          : ordersList[index].status.toString() == 'Delivered'
                                                                              ? Colors.green
                                                                              : Colors.blue),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          ordersList[index].status.toString() == 'Accepting order' || ordersList[index].status.toString() == 'Pending'
                                                              ? ' Pending'
                                                              : ordersList[index].status.toString(),
                                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                    // SizedBox(
                                                    //   height: 20,
                                                    //   width: 20,
                                                    //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                                    //
                                                    //     // height: 80,
                                                    //     // width: 80,
                                                    //   ),
                                                    //),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),

      // isLoading ? Center(child: CircularProgressIndicator(
      //   color: darkRedColor,
      //   strokeWidth: 1,
      // )) :
      //
      // SafeArea(child: Column(children: [
      //
      //   Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Container(
      //       width: size.width*0.95,
      //       height: 45,
      //       decoration: BoxDecoration(
      //         color: Color(0xFFFFD3D1),
      //         borderRadius: BorderRadius.circular(
      //           10.0,
      //         ),
      //       ),
      //       child: TabBar(
      //         controller: _tabController,
      //         // give the indicator a decoration (color and border radius)
      //         indicator: BoxDecoration(
      //           gradient: LinearGradient(
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //             stops: [0.0, 1.0],
      //             colors: [
      //               darkRedColor,
      //               lightRedColor,
      //             ],
      //           ),
      //           borderRadius: BorderRadius.circular(
      //             10.0,
      //           ),
      //         ),
      //         unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 12, color: Colors.black),
      //         labelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 12),
      //         labelColor: Colors.white,
      //         unselectedLabelColor:  Colors.black,
      //         onTap: (index) {
      //           if(index == 0) {
      //             setState(() {
      //               orders = 'Active Orders';
      //             });
      //           }
      //           else if(index == 1) {
      //             setState(() {
      //               orders = 'Ready';
      //             });
      //           }
      //           else if(index == 2) {
      //             setState(() {
      //               orders = 'Collected';
      //             });
      //           }
      //           else {
      //             setState(() {
      //               orders = 'Delivered Orders';
      //             });
      //           }
      //         },
      //
      //         tabs: [
      //           // first tab [you can add an icon using the icon property]
      //           Tab(
      //             text: 'Pending',
      //           ),
      //
      //           Tab(
      //             text: 'Ready',
      //           ),
      //
      //           Tab(
      //             text: 'Collected',
      //           ),
      //           // second tab [you can add an icon using the icon property]
      //           Tab(
      //             text: 'Delivered',
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      //   Expanded(child: TabBarView(
      //     controller: _tabController,
      //     children: [
      //       Container(
      //         child: Column(children: [
      //           SizedBox(
      //             height: size.height*0.01,
      //           ),
      //           (ordersList.isEmpty && isListEmpty == 'yes') || accepting == ''   ? Center(
      //             child: Container(
      //               child: Text('No New Orders Found'),
      //             ),
      //           ) :
      //           SizedBox(
      //             // height: size.height*0.25,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: ordersList.length,
      //               scrollDirection: Axis.vertical,
      //               itemBuilder: (BuildContext context,index
      //                   ) {
      //
      //                 // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
      //                 //   totalAmount = totalAmount +
      //                 // }
      //
      //                 return
      //                   ordersList[index].status.toString() == 'Accepting order' ?
      //
      //                   GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
      //                       );
      //                     },
      //                     child: Column(children: [
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 8,),
      //                       child: Container(
      //                         width: size.width*0.9,
      //                         decoration: BoxDecoration(
      //                           color: Colors.white,
      //                           borderRadius: BorderRadius.circular(10),
      //                           boxShadow: [
      //                             BoxShadow(
      //                                 color: lightButtonGreyColor,
      //                                 spreadRadius: 2,
      //                                 blurRadius: 3
      //                             )
      //                           ],
      //                         ),
      //                         child: Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: Row(
      //                             children: [
      //
      //                               SizedBox(
      //                                 height: size.height*0.08,
      //                                 width: size.width*0.25,
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.all(8.0),
      //                                   child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
      //                                     height: size.height*0.08,
      //                                     width: size.width*0.25,
      //                                     // height: 80,
      //                                     // width: 80,
      //                                   ),
      //                                 ),
      //                               ),
      //
      //                               Container(
      //                                 width: size.width*0.6,
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.only(left: 8),
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                         children: [
      //                                           Text('Products : ${ordersList[index].ordersItems!.length}',
      //                                             style: TextStyle(color: Colors.black,
      //                                                 fontSize: 14,fontWeight: FontWeight.w500),),
      //                                         ],),
      //
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.start,
      //                                         children: [
      //                                           Text('Order ID: ${ordersList[index].orderNo.toString()}',
      //                                             style: TextStyle(color: Color(0xFF585858),
      //                                                 fontSize: 12,fontWeight: FontWeight.w400),),
      //                                           // SizedBox(
      //                                           //   height: 20,
      //                                           //   width: 20,
      //                                           //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                           //
      //                                           //     // height: 80,
      //                                           //     // width: 80,
      //                                           //   ),
      //                                           //),
      //                                         ],),
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                         children: [
      //                                           Text(
      //                                             DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //                                           + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //
      //                                             ,
      //                                             style: TextStyle(color: Color(0xFF585858),
      //                                                 fontSize: 12,fontWeight: FontWeight.w500),),
      //
      //
      //                                           // Text('\$30.99',
      //                                           //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
      //
      //                                         ],),
      //
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.start,
      //                                         children: [
      //                                           Text(
      //
      //                                             ordersList[index].status.toString() == 'Accepting order' ?
      //                                             ' Pending' : ordersList[index].status.toString(),
      //                                             style: TextStyle(color: Colors.blue,
      //                                                 fontSize: 12,fontWeight: FontWeight.bold),),
      //                                           // SizedBox(
      //                                           //   height: 20,
      //                                           //   width: 20,
      //                                           //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                           //
      //                                           //     // height: 80,
      //                                           //     // width: 80,
      //                                           //   ),
      //                                           //),
      //                                         ],),
      //
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //
      //
      //
      //
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //
      //                 ],),
      //                   ) : Container();
      //               },
      //
      //             ),
      //           ),
      //           SizedBox(
      //             height: size.height*0.03,
      //           ),
      //         ],),
      //       ),
      //       Container(
      //         child: Column(children: [
      //           SizedBox(
      //             height: size.height*0.01,
      //           ),
      //           (ordersList.isEmpty && isListEmpty == 'yes') || readyToCollect == ''   ? Center(
      //             child: Container(
      //               child: Text('No Ready for Collection Orders Found'),
      //
      //             ),
      //           ) :
      //           SizedBox(
      //             // height: size.height*0.25,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: ordersList.length,
      //               scrollDirection: Axis.vertical,
      //               itemBuilder: (BuildContext context,index
      //                   ) {
      //
      //                 // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
      //                 //   totalAmount = totalAmount +
      //                 // }
      //
      //                 return
      //                   ordersList[index].status.toString() == 'Ready for collection' ?
      //
      //                   GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
      //                       );
      //                     },
      //                     child: Column(children: [
      //                       Padding(
      //                         padding: const EdgeInsets.only(top: 8,),
      //                         child: Container(
      //                           width: size.width*0.9,
      //                           decoration: BoxDecoration(
      //                             color: Colors.white,
      //                             borderRadius: BorderRadius.circular(10),
      //                             boxShadow: [
      //                               BoxShadow(
      //                                   color: lightButtonGreyColor,
      //                                   spreadRadius: 2,
      //                                   blurRadius: 3
      //                               )
      //                             ],
      //                           ),
      //                           child: Padding(
      //                             padding: const EdgeInsets.all(8.0),
      //                             child: Row(
      //                               children: [
      //
      //                                 SizedBox(
      //                                   height: size.height*0.08,
      //                                   width: size.width*0.25,
      //                                   child: Padding(
      //                                     padding: const EdgeInsets.all(8.0),
      //                                     child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
      //                                       height: size.height*0.08,
      //                                       width: size.width*0.25,
      //                                       // height: 80,
      //                                       // width: 80,
      //                                     ),
      //                                   ),
      //                                 ),
      //
      //                                 Container(
      //                                   width: size.width*0.6,
      //                                   child: Padding(
      //                                     padding: const EdgeInsets.only(left: 8),
      //                                     child: Column(
      //                                       crossAxisAlignment: CrossAxisAlignment.start,
      //                                       children: [
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                           children: [
      //                                             Text('Products : ${ordersList[index].ordersItems!.length}',
      //                                               style: TextStyle(color: Colors.black,
      //                                                   fontSize: 14,fontWeight: FontWeight.w500),),
      //                                           ],),
      //
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.start,
      //                                           children: [
      //                                             Text('Order ID: ${ordersList[index].orderNo.toString()}',
      //                                               style: TextStyle(color: Color(0xFF585858),
      //                                                   fontSize: 12,fontWeight: FontWeight.w400),),
      //                                             // SizedBox(
      //                                             //   height: 20,
      //                                             //   width: 20,
      //                                             //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                             //
      //                                             //     // height: 80,
      //                                             //     // width: 80,
      //                                             //   ),
      //                                             //),
      //                                           ],),
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                           children: [
      //                                             Text(
      //                                               DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //                                                   + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //
      //                                               ,
      //                                               style: TextStyle(color: Color(0xFF585858),
      //                                                   fontSize: 12,fontWeight: FontWeight.w500),),
      //
      //
      //                                             // Text('\$30.99',
      //                                             //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
      //
      //                                           ],),
      //
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.start,
      //                                           children: [
      //                                             Text(
      //
      //                                               ordersList[index].status.toString() == 'Ready for collection' ?
      //                                               'Waiting for driver to collect' : ordersList[index].status.toString(),
      //                                               style: TextStyle(color: Colors.blue,
      //                                                   fontSize: 12,fontWeight: FontWeight.bold),),
      //                                             // SizedBox(
      //                                             //   height: 20,
      //                                             //   width: 20,
      //                                             //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                             //
      //                                             //     // height: 80,
      //                                             //     // width: 80,
      //                                             //   ),
      //                                             //),
      //                                           ],),
      //
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ),
      //
      //
      //
      //
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //
      //                     ],),
      //                   ) : Container();
      //               },
      //
      //             ),
      //           ),
      //           SizedBox(
      //             height: size.height*0.03,
      //           ),
      //         ],),
      //       ),
      //       Container(
      //         child: Column(children: [
      //           SizedBox(
      //             height: size.height*0.01,
      //           ),
      //           (ordersList.isEmpty && isListEmpty == 'yes') || collected == ''   ? Center(
      //             child: Container(
      //               child: Text('No Collected Orders Found'),
      //
      //             ),
      //           ) :
      //           SizedBox(
      //             // height: size.height*0.25,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: ordersList.length,
      //               scrollDirection: Axis.vertical,
      //               itemBuilder: (BuildContext context,index
      //                   ) {
      //
      //                 // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
      //                 //   totalAmount = totalAmount +
      //                 // }
      //
      //                 return
      //                   ordersList[index].status.toString() == 'Collected' ?
      //
      //                   GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
      //                       );
      //                     },
      //                     child: Column(children: [
      //                       Padding(
      //                         padding: const EdgeInsets.only(top: 8,),
      //                         child: Container(
      //                           width: size.width*0.9,
      //                           decoration: BoxDecoration(
      //                             color: Colors.white,
      //                             borderRadius: BorderRadius.circular(10),
      //                             boxShadow: [
      //                               BoxShadow(
      //                                   color: lightButtonGreyColor,
      //                                   spreadRadius: 2,
      //                                   blurRadius: 3
      //                               )
      //                             ],
      //                           ),
      //                           child: Padding(
      //                             padding: const EdgeInsets.all(8.0),
      //                             child: Row(
      //                               children: [
      //
      //                                 SizedBox(
      //                                   height: size.height*0.08,
      //                                   width: size.width*0.25,
      //                                   child: Padding(
      //                                     padding: const EdgeInsets.all(8.0),
      //                                     child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
      //                                       height: size.height*0.08,
      //                                       width: size.width*0.25,
      //                                       // height: 80,
      //                                       // width: 80,
      //                                     ),
      //                                   ),
      //                                 ),
      //
      //                                 Container(
      //                                   width: size.width*0.6,
      //                                   child: Padding(
      //                                     padding: const EdgeInsets.only(left: 8),
      //                                     child: Column(
      //                                       crossAxisAlignment: CrossAxisAlignment.start,
      //                                       children: [
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                           children: [
      //                                             Text('Products : ${ordersList[index].ordersItems!.length}',
      //                                               style: TextStyle(color: Colors.black,
      //                                                   fontSize: 14,fontWeight: FontWeight.w500),),
      //                                           ],),
      //
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.start,
      //                                           children: [
      //                                             Text('Order ID: ${ordersList[index].orderNo.toString()}',
      //                                               style: TextStyle(color: Color(0xFF585858),
      //                                                   fontSize: 12,fontWeight: FontWeight.w400),),
      //                                             // SizedBox(
      //                                             //   height: 20,
      //                                             //   width: 20,
      //                                             //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                             //
      //                                             //     // height: 80,
      //                                             //     // width: 80,
      //                                             //   ),
      //                                             //),
      //                                           ],),
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                           children: [
      //                                             Text(
      //                                               DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //                                                   + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //
      //                                               ,
      //                                               style: TextStyle(color: Color(0xFF585858),
      //                                                   fontSize: 12,fontWeight: FontWeight.w500),),
      //
      //
      //                                             // Text('\$30.99',
      //                                             //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
      //
      //                                           ],),
      //
      //                                         SizedBox(
      //                                           height: size.height*0.01,
      //                                         ),
      //                                         Row(
      //                                           mainAxisAlignment: MainAxisAlignment.start,
      //                                           children: [
      //                                             Text(
      //
      //                                               ordersList[index].status.toString() == 'Collected' ?
      //                                               'Driver on their way' : ordersList[index].status.toString(),
      //                                               style: TextStyle(color: Colors.blue,
      //                                                   fontSize: 12,fontWeight: FontWeight.bold),),
      //                                             // SizedBox(
      //                                             //   height: 20,
      //                                             //   width: 20,
      //                                             //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                             //
      //                                             //     // height: 80,
      //                                             //     // width: 80,
      //                                             //   ),
      //                                             //),
      //                                           ],),
      //
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ),
      //
      //
      //
      //
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //
      //                     ],),
      //                   ) : Container();
      //               },
      //
      //             ),
      //           ),
      //           SizedBox(
      //             height: size.height*0.03,
      //           ),
      //         ],),
      //       ),
      //       Container(
      //         child: Column(children: [
      //           SizedBox(
      //             height: size.height*0.01,
      //           ),
      //
      //           (ordersList.isEmpty && isListEmpty == 'yes') || delivered == ''   ? Center(
      //             child: Container(
      //               child: Text('No New Orders Found'),
      //
      //             ),
      //           ) :
      //           SizedBox(
      //             // height: size.height*0.25,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //
      //               scrollDirection: Axis.vertical,
      //               itemBuilder: (BuildContext context,index
      //                   ) {
      //                 return ordersList[index].status.toString() ==  'Delivered' ?
      //
      //                 GestureDetector(
      //                   onTap: () {
      //                     Navigator.push(
      //                       context,
      //                       MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
      //                     );
      //                   },
      //                   child: Column(children: [
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 8,),
      //                       child: Container(
      //                         width: size.width*0.9,
      //                         decoration: BoxDecoration(
      //                           color: Colors.white,
      //                           borderRadius: BorderRadius.circular(10),
      //                           boxShadow: [
      //                             BoxShadow(
      //                                 color: lightButtonGreyColor,
      //                                 spreadRadius: 2,
      //                                 blurRadius: 3
      //                             )
      //                           ],
      //                         ),
      //                         child: Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: Row(
      //                             children: [
      //
      //                               SizedBox(
      //                                 height: size.height*0.08,
      //                                 width: size.width*0.25,
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.all(8.0),
      //                                   child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
      //                                     height: size.height*0.08,
      //                                     width: size.width*0.25,
      //                                     // height: 80,
      //                                     // width: 80,
      //                                   ),
      //                                 ),
      //                               ),
      //
      //                               Container(
      //                                 width: size.width*0.6,
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.only(left: 8),
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                         children: [
      //                                           Text('Products : ${ordersList[index].ordersItems!.length}',
      //                                             style: TextStyle(color: Colors.black,
      //                                                 fontSize: 14,fontWeight: FontWeight.w500),),
      //
      //                                           // SizedBox(
      //                                           //   height: 20,
      //                                           //   width: 20,
      //                                           //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                           //
      //                                           //     // height: 80,
      //                                           //     // width: 80,
      //                                           //   ),
      //                                           //),
      //                                         ],),
      //
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.start,
      //                                         children: [
      //                                           Text('Order ID: ${ordersList[index].orderNo.toString()}',
      //                                             style: TextStyle(color: Color(0xFF585858),
      //                                                 fontSize: 12,fontWeight: FontWeight.w400),),
      //                                           // SizedBox(
      //                                           //   height: 20,
      //                                           //   width: 20,
      //                                           //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                           //
      //                                           //     // height: 80,
      //                                           //     // width: 80,
      //                                           //   ),
      //                                           //),
      //                                         ],),
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                         children: [
      //                                           Text(
      //                                             DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //                                                 + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
      //
      //                                             ,
      //                                             style: TextStyle(color: Color(0xFF585858),
      //                                                 fontSize: 10,fontWeight: FontWeight.w500),),
      //
      //
      //                                           Text('ZAR 30.99',
      //                                             style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
      //
      //                                         ],),
      //
      //                                       SizedBox(
      //                                         height: size.height*0.01,
      //                                       ),
      //                                       Row(
      //                                         mainAxisAlignment: MainAxisAlignment.start,
      //                                         children: [
      //                                           Text(
      //
      //                                             ordersList[index].status.toString() == 'Collected' ?
      //                                             'Driver on their way' : ordersList[index].status.toString(),
      //                                             style: TextStyle(color: Colors.blue,
      //                                                 fontSize: 12,fontWeight: FontWeight.bold),),
      //                                           // SizedBox(
      //                                           //   height: 20,
      //                                           //   width: 20,
      //                                           //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
      //                                           //
      //                                           //     // height: 80,
      //                                           //     // width: 80,
      //                                           //   ),
      //                                           //),
      //                                         ],),
      //
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //
      //
      //
      //
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //
      //                   ],),
      //                 ) : SizedBox();
      //               },
      //               itemCount: ordersList.length,
      //             ),
      //           ),
      //           SizedBox(
      //             height: size.height*0.03,
      //           ),
      //         ],),
      //       ),
      //     ],
      //   )),
      //
      // ])),
    );
  }
}
