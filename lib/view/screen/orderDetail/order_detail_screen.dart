import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/orderModel.dart' as orderModel;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/restaurant_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final orderModel.OrderModel order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int total = 0;
  int subTotal = 0;
  int addOnsTotal = 0;
  List<RestaurantModel> restaurantList = [];
  String distance = '';
  double distanceInKm = 0.0;

  totalAmount() async {
    for (int i = 0; i < widget.order.ordersItems!.length; i++) {
      if (widget.order.ordersItems![i].addon!.isNotEmpty) {
        for (int j = 0; j < widget.order.ordersItems![i].addon!.length; j++) {
          if (widget.order.ordersItems![i].addon![j].addon != null) {
            setState(() {
              addOnsTotal = addOnsTotal + int.parse(widget.order.ordersItems![i].addon![j].addon!.price.toString());
            });
          } else {
            break;
          }
        }
      }

      setState(() {
        subTotal = subTotal + (int.parse(widget.order.ordersItems![i].payment.toString()) * int.parse(widget.order.ordersItems![i].quantity.toString()));
      });

      if (widget.order.ordersItems!.length - 1 == i) {
        setState(() {
          total = subTotal + addOnsTotal;
        });
      }
    }

    for (int i = 0; i < widget.order.ordersItems!.length; i++) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      distance = '';
    });
    print(widget.order.deliveryFee.toString() + ' delivery fee');
    getRestaurantsLatLong();
    totalAmount();
    phoneNumber = removeLeadingZeroFromFirstFourCharacters(widget.order.user!.phoneNo.toString());

    super.initState();
  }

  getRestaurantsLatLong() async {
    var headers = {'Content-Type': 'application/json', 'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}restaurants/${widget.order.ordersItems![0].product!.restaurantId.toString()}'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    //json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        restaurantList = List<RestaurantModel>.from(json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
      });
      print(widget.order.ordersItems![0].product!.restaurantId.toString());
      print(double.parse(restaurantList[0].latitude.toString()));
      print(double.parse(restaurantList[0].longitude.toString()));
      calculateDistace(restaurantList[0].latitude.toString(), restaurantList[0].longitude.toString());
    } else if (response.statusCode == 302) {
    } else {}
  }

  calculateDistace(String lat, String long) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      distance = '';
    });

    print('we are in calculate distance');
    print(prefs.getDouble('lat')!);
    print(prefs.getDouble('long')!);

    if (prefs.getDouble('lat') != null && prefs.getDouble('long') != null) {
      setState(() {
        distanceInKm = Geolocator.distanceBetween(double.parse(lat.toString()), double.parse(long.toString()), prefs.getDouble('lat')!, prefs.getDouble('long')!) / 1000;
      });

      print(distanceInKm.toString());
      print((distanceInKm / 60).toString());

      if ((distanceInKm / 60 * 60) > 60) {
        setState(() {
          distance = (distanceInKm / 60).toStringAsFixed(0) + ' h';
        });
      } else {
        setState(() {
          distance = (distanceInKm / 60 * 60).toStringAsFixed(0) + ' mins';
        });
      }
    }
  }

  String removeLeadingZeroFromFirstFourCharacters(String phoneNumber) {
    if (phoneNumber.length >= 4 && phoneNumber.substring(0, 4).contains('0')) {
      phoneNumber = phoneNumber.replaceFirst('0', '');
    }
    return phoneNumber;
  }

  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Order Detail',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
                // );
              },
              child: Center(
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
                              Container(
                                width: size.width * 0.8,
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
                                          Text(
                                            'Status ',
                                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: widget.order.status.toString() == 'Accepting order' || widget.order.status.toString() == 'Pending'
                                                    ? Colors.blue
                                                    : widget.order.status.toString() == 'Ready for collection'
                                                        ? Colors.teal
                                                        : widget.order.status.toString() == 'Preparing your meal'
                                                            ? Colors.indigo
                                                            : widget.order.status.toString() == 'Collected'
                                                                ? Colors.deepOrangeAccent
                                                                : widget.order.status.toString() == 'Delivered'
                                                                    ? Colors.green
                                                                    : Colors.blue),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                widget.order.status.toString() == 'Accepting order' || widget.order.status.toString() == 'Pending'
                                                    ? ' Pending'
                                                    : widget.order.status.toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
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
                    widget.order.deliveryType == null
                        ? Container()
                        : Padding(
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
                                    Container(
                                      width: size.width * 0.8,
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
                                                Text(
                                                  'Delivery ',
                                                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      widget.order.deliveryType.toString(),
                                                      style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height * 0.01,
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
                              Container(
                                width: size.width * 0.8,
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
                                          Text(
                                            'Order Number : ${widget.order.orderNo.toString()}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
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
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat.yMMMMd()
                                                    .format(widget.order.createdAt!.toLocal())
                                                    .toString() +
                                                ' ' +
                                                DateFormat.jm().format(widget.order.createdAt!.toLocal()).toString(),
                                            style: TextStyle(color: Color(0xFF585858), fontSize: 13, fontWeight: FontWeight.w500),
                                          ),

                                          // Text('\$30.99',
                                          //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      distance == ''
                                          ? Container()
                                          : widget.order.status.toString() == 'pending' && distance != ''
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Estimated time of arrival',
                                                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                                    ),
                                                    Text(
                                                      ' $distance',
                                                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                              Container(
                                width: size.width * 0.8,
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
                                          Text(
                                            'Delivered To ',
                                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${widget.order.user!.name.toString()}\n${widget.order.user!.email.toString()}\n${phoneNumber} ',
                                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    widget.order.address != null

                        //&&  widget.order.deliveryType == 'Driver'

                        ? Padding(
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
                                    Container(
                                      width: size.width * 0.8,
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
                                                Text(
                                                  'Delivery Address ',
                                                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: size.width * 0.7,
                                                  child: Text(
                                                    widget.order.address.toString(),
                                                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    widget.order.ordersItems!.isEmpty
                        ? Container(
                            child: Text(
                              'No order item found',
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          )
                        : SizedBox(
                            // height: size.height*0.25,
                            width: size.width * 0.9,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.order.ordersItems!.length,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    // width: size.width*0.9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: lightButtonGreyColor, spreadRadius: 2, blurRadius: 3)],
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Container(
                                            // width: size.width*0.9,
                                            // decoration: BoxDecoration(
                                            //   color: Colors.white,
                                            //   borderRadius: BorderRadius.circular(10),
                                            //   boxShadow: [
                                            //     BoxShadow(
                                            //         color: lightButtonGreyColor,
                                            //         spreadRadius: 2,
                                            //         blurRadius: 3
                                            //     )
                                            //   ],
                                            // ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(0.0),
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
                                                        height: size.height * 0.07,
                                                        width: size.width * 0.2,
                                                        fit: BoxFit.cover,
                                                        imageUrl: imageConstUrlProduct + widget.order.ordersItems![index].product!.image.toString(),
                                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    // height: size.height*0.07,
                                                    width: size.width * 0.65,
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
                                                                width: size.width * 0.5,
                                                                child: Text(
                                                                  widget.order.ordersItems![index].product!.name.toString(),
                                                                  style: TextStyle(color: Color(0xFF585858), fontSize: 14, fontWeight: FontWeight.w500),
                                                                  overflow: TextOverflow.ellipsis,
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
                                                              Text(
                                                                'Quantity : ' + widget.order.ordersItems![index].quantity.toString(),
                                                                //quantity.toString(),
                                                                style: TextStyle(color: Color(0xFF585858), fontSize: 14, fontWeight: FontWeight.w600),
                                                              ),
                                                              // widget.order.ordersItems![index].product!.price.toString()
                                                              Text(
                                                                'R ' +
                                                                    '${int.parse(widget.order.ordersItems![index].product!.price.toString()) * int.parse(widget.order.ordersItems![index].quantity.toString())}',
                                                                style: TextStyle(color: Color(0xFF585858), fontSize: 12, fontWeight: FontWeight.w600),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: size.height * 0.01,
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
                                        widget.order.ordersItems![index].addon == null || widget.order.ordersItems![index].addon.toString() == "[]"
                                            // ||  widget.order.ordersItems![index].addon.toString() == "[Instance of 'AddonElement']"
                                            ? Container()
                                            : Container(
                                                width: size.width * 0.9,
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Text(
                                                  'Add Ons',
                                                  style: TextStyle(color: darkRedColor, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        widget.order.ordersItems![index].addon != null
                                            ? Container(
                                                width: size.width * 0.9,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: widget.order.ordersItems![index].addon!.length,
                                                  scrollDirection: Axis.vertical,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemBuilder: (BuildContext context, addIndex) {
                                                    print(widget.order.ordersItems![index].addon.toString());

                                                    return widget.order.ordersItems![index].addon![addIndex].addon != null
                                                        ? Padding(
                                                            padding: const EdgeInsets.only(left: 8, right: 20, bottom: 5),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width: size.width * 0.5,
                                                                  child: Text(
                                                                    widget.order.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '2'
                                                                        ? widget.order.ordersItems![index].addon![addIndex].addon!.name.toString() + ' (Chips)'
                                                                        : widget.order.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '4'
                                                                            ? widget.order.ordersItems![index].addon![addIndex].addon!.name.toString() + ' (Flavour)'
                                                                            : widget.order.ordersItems![index].addon![addIndex].addon!.name.toString(),
                                                                    //quantity.toString(),
                                                                    style: TextStyle(color: Color(0xFF585858), fontSize: 12, fontWeight: FontWeight.w500),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                // widget.order.ordersItems![index].product!.price.toString()
                                                                widget.order.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '4' ||
                                                                        widget.order.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '1'
                                                                    ? Container()
                                                                    : Text(
                                                                        'R ' + widget.order.ordersItems![index].addon![addIndex].addon!.price.toString(),
                                                                        style: TextStyle(color: darkRedColor, fontSize: 12, fontWeight: FontWeight.w500),
                                                                      ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container();
                                                  },
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        widget.order.ordersItems![index].specialInstruction.toString() == '' || widget.order.ordersItems![index].specialInstruction == null
                                            ? Container()
                                            : Column(
                                                children: [
                                                  Container(
                                                    width: size.width * 0.95,
                                                    alignment: Alignment.topLeft,
                                                    padding: const EdgeInsets.only(
                                                      left: 8,
                                                    ),
                                                    child: Text(
                                                      'Special Instruction',
                                                      style: TextStyle(color: darkRedColor, fontSize: 12, fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Container(
                                                    width: size.width * 0.95,
                                                    alignment: Alignment.topLeft,
                                                    padding: const EdgeInsets.only(
                                                      left: 8,
                                                    ),
                                                    child: Text(
                                                      widget.order.ordersItems![index].specialInstruction.toString(),
                                                      style: TextStyle(color: Color(0xFF585858), fontSize: 12, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    widget.order.deliveryFee == null || widget.order.deliveryFee.toString() == '0'
                        ? Container()
                        : Column(
                            children: [
                              SizedBox(
                                height: size.height * 0.03,
                              ),
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
                                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: size.width * 0.82,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 2),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Delivery Fee : ',
                                                      style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                                                    ),
                                                    Text(
                                                      'R ' + widget.order.deliveryFee.toString(),
                                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    subTotal == 0
                        ? Container()
                        : Padding(
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
                                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.82,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Subtotal : ',
                                                  style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  'R ' + subTotal.toString(),
                                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
                    addOnsTotal == 0
                        ? Container()
                        : Padding(
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
                                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.82,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            addOnsTotal.toString() == '0'
                                                ? Container()
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Add Ons Total : ',
                                                        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                                                      ),
                                                      Text(
                                                        'R ' + addOnsTotal.toString(),
                                                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
                    widget.order.deliveryFee == null || widget.order.deliveryFee.toString() == '0'
                        ? Padding(
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
                                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.82,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Order Total : ',
                                                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  'R ' + total.toString(),
                                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
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
                                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.82,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Order Total : ',
                                                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  'R ${int.parse(total.toString()) + int.parse(widget.order.deliveryFee.toString())}',
                                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
