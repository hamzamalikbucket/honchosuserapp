import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:figma_new_project/view/screen/search/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String restaurantId;
  final String categoryImage;
  const DetailScreen(
      {Key? key,
      required this.restaurantId,
      required this.categoryName,
      required this.categoryId,
      required this.categoryImage})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isLoading = false;
  final cartController = Get.put(AddToCartController());
  bool isLoadingAddCart = false;

  List<FoodItem> items = [
    FoodItem(
      image: 'assets/images/food1.png',
      title: 'Famil Meal',
      description: 'Single burger with beef',
    ),
    FoodItem(
      image: 'assets/images/food2.png',
      title: 'Double Up',
      description: 'Single burger with beef',
    ),
    FoodItem(
      image: 'assets/images/food3.png',
      title: 'Famil Meal',
      description: 'Single burger with beef',
    ),
    FoodItem(
      image: 'assets/images/locationOne.png',
      title: 'Double Up',
      description: 'Single burger with beef',
    ),
  ];

  String isLoaded = '';

  int y = 0, quantity = 1;
  List<CategoriesProductsModel> categoriesProductsList1 = [];
  List<CategoriesProductsModel> categoriesProductsList = [];

  List<String> pages = [
    'assets/images/home_1.png',
    'assets/images/burger.png',
    'assets/images/burger1.png',
  ];

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = false;
      isLoadingAddCart = false;
      categoriesProductsList.clear();
      y = 0;
      quantity = 1;
      isLoaded = '';
    });
    getProducts();
    super.initState();
  }

  void getProducts() async {
    setState(() {
      categoriesProductsList.clear();
    });
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'restaurant_session=$cookie'
    };

    var request = http.Request(
        'GET', Uri.parse('${apiBaseUrl}products'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    // final data = json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        categoriesProductsList1 = List<CategoriesProductsModel>.from(json
            .decode(responseData)
            .map((x) => CategoriesProductsModel.fromJson(x)));
      });

      for (int i = 0; i < categoriesProductsList1.length; i++) {
        if (categoriesProductsList1[i].restaurantId ==
                widget.restaurantId.toString() &&
            categoriesProductsList1[i].categoryId.toString() ==
                widget.categoryId.toString()) {
          setState(() {
            categoriesProductsList.add(CategoriesProductsModel(
              id: categoriesProductsList1[i].id,
              categoryId: categoriesProductsList1[i].categoryId,
              restaurantId: categoriesProductsList1[i].restaurantId,
              name: categoriesProductsList1[i].name,
              image: categoriesProductsList1[i].image,
              description: categoriesProductsList1[i].description,
              price: categoriesProductsList1[i].price,
              flavourIds: categoriesProductsList1[i].flavourIds
            ));
          });
        }
      }

      setState(() {
        isLoaded = 'yes';
        isLoading = false;
      });

      // var snackBar = SnackBar(content: Text('Categories added successfully'
      //   ,style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      // );
      // print(await response.stream.bytesToString());
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
    } else {
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
  }

  void addToCart(String productId, String quantity1) async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.MultipartRequest('POST',
        Uri.parse('${apiBaseUrl}add_to_cart'));
    request.fields.addAll({'product_id': productId, 'quantity': quantity1});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        isLoadingAddCart = false;
        quantity = 1;
      });
      cartController.fetchCartItems();
      Navigator.of(context, rootNavigator: false).pop();
      var snackBar = SnackBar(
        content: Text(
          'Added to cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // print(await response.stream.bytesToString());
    } else {
      setState(() {
        isLoadingAddCart = false;
        quantity = 1;
      });
      print(response.reasonPhrase);
    }
  }

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
          'Details',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
            Container(
              height: size.height * 0.22,
              width: size.width * 0.9,
              decoration: BoxDecoration(color: lightButtonGreyColor),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: size.height * 0.25,
                      width: size.width * 0.9,
                      fit: BoxFit.cover,
                      imageUrl: widget.categoryImage.toString(),
                      //placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Container(
                    height: size.height * 0.25,
                    width: size.width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.categoryName.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold),
                          ),
                          // SizedBox(
                          //   height: size.height * 0.005,
                          // ),
                          // Text(
                          //   '10+ items',
                          //   style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w400),
                          // ),

                          SizedBox(
                            height: size.height * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            'Products',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    )),
                isLoaded == 'yes' && categoriesProductsList.isEmpty
                    ? Container(
                        width: size.width,
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : categoriesProductsList.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              //  color: Color(0xFFFBFBFB),
                              // height: size.height*0.66,
                              child: GridView.builder(
                                  padding: EdgeInsets.only(top: 8),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: size.height * 0.22,
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10),
                                  itemCount: 4,
                                  itemBuilder: (BuildContext ctx, index) {
                                    // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                    // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses!.length);
                                    // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                    // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses![index].verseRecording.toString() + " surah record");

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4),
                                      child: Container(
                                        // height: size.height*0.25,
                                        width: size.width * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                                color: lightButtonGreyColor,
                                                spreadRadius: 2,
                                                blurRadius: 3)
                                          ],
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Container(
                                                height: size.height * 0.13,
                                                width: size.width * 0.4,
                                                color: lightButtonGreyColor,
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Container(
                                                width: size.width * 0.4,
                                                height: 10,
                                                color: lightButtonGreyColor,
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Container(
                                                width: size.width * 0.4,
                                                height: 10,
                                                color: lightButtonGreyColor,
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          )

                        // Center(
                        //         child: CircularProgressIndicator(
                        //           color: darkRedColor,
                        //           strokeWidth: 0.5,
                        //         ),
                        //       )
                        : Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              width: size.width,
                              //  color: Color(0xFFFBFBFB),
                              // height: size.height*0.66,
                              child: GridView.builder(
                                  padding: EdgeInsets.only(top: 8),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: size.height * 0.24,
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10),
                                  itemCount: categoriesProductsList.length,
                                  itemBuilder: (BuildContext ctx, index) {
                                    // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                    // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses!.length);
                                    // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                    // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses![index].verseRecording.toString() + " surah record");

                                    print(imageConstUrlProduct +
                                        categoriesProductsList[index]
                                            .image
                                            .toString() +
                                        '${baseUrlMain}image/product/burger.jpg');
                                    return categoriesProductsList[index]
                                                    .categoryId
                                                    .toString() ==
                                                widget.categoryId.toString() &&
                                            categoriesProductsList[index]
                                                    .restaurantId
                                                    .toString() ==
                                                widget.restaurantId.toString()
                                        ? InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    // <-- SEE HERE
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(25.0),
                                                    ),
                                                  ),
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return SizedBox(
                                                        height:
                                                            size.height * 0.4,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Container(
                                                              width: size.width,
                                                              height:
                                                                  size.height *
                                                                      0.15,
                                                              child: Row(
                                                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        top: 13,
                                                                        right:
                                                                            8,
                                                                        bottom:
                                                                            20),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          size.height *
                                                                              0.1,
                                                                      width: size
                                                                              .width *
                                                                          0.3,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          color:
                                                                              lightButtonGreyColor),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height:
                                                                              size.height * 0.1,
                                                                          width:
                                                                              size.width * 0.3,
                                                                          imageUrl:
                                                                              imageConstUrlProduct + categoriesProductsList[index].image.toString(),
                                                                          placeholder: (context, url) =>
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(10), color: lightButtonGreyColor),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(Icons.error),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        size.height *
                                                                            0.1,
                                                                    width:
                                                                        size.width *
                                                                            0.5,
                                                                    //  color: Colors.red,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            categoriesProductsList[index].name.toString(),
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                size.height * 0.01,
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                size.height * 0.06,
                                                                            width:
                                                                                size.width * 0.55,
                                                                            child:
                                                                                Text(
                                                                              categoriesProductsList[index].description.toString(),
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                           // categoriesProductsList[index].flavourIds != null ?
                                                           //  Container(
                                                           //    child: Row(
                                                           //      children: [
                                                           //        Padding(
                                                           //          padding: const EdgeInsets
                                                           //              .only(
                                                           //              left:
                                                           //              16,
                                                           //              top: 0,
                                                           //              right:
                                                           //              8,
                                                           //              bottom:
                                                           //              10),
                                                           //          child: Text(
                                                           //            'Flavour',
                                                           //            style: TextStyle(
                                                           //                color: Colors
                                                           //                    .black,
                                                           //                fontSize:
                                                           //                15,
                                                           //                fontWeight:
                                                           //                FontWeight.bold),
                                                           //          ),
                                                           //        ),
                                                           //        Padding(
                                                           //          padding: const EdgeInsets
                                                           //              .only(
                                                           //              left:
                                                           //              16,
                                                           //              top: 0,
                                                           //              right:
                                                           //              8,
                                                           //              bottom:
                                                           //              10),
                                                           //          child: Text(
                                                           //            categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.MILD' ?  'Mild' :
                                                           //            categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.COLD' ?  'Cold' :
                                                           //            categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.HOT' ?  'Hot' :
                                                           //            categoriesProductsList[index].flavourIds![0].flavours!.name.toString()
                                                           //            ,
                                                           //            style: TextStyle(
                                                           //                color: Colors
                                                           //                    .red,
                                                           //                fontSize:
                                                           //                15,
                                                           //                fontWeight:
                                                           //                FontWeight.bold),
                                                           //          ),
                                                           //        ),
                                                           //      ],
                                                           //    ),
                                                           //  ) ,
                                                                //: Container(),
                                                            Container(
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        top: 0,
                                                                        right:
                                                                            8,
                                                                        bottom:
                                                                            10),
                                                                    child: Text(
                                                                      'Price',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        top: 0,
                                                                        right:
                                                                            8,
                                                                        bottom:
                                                                            10),
                                                                    child: Text(
                                                                      'R ${categoriesProductsList[index].price.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .red,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 16,
                                                                      top: 0,
                                                                      right: 8,
                                                                      bottom:
                                                                          10),
                                                                  child: Text(
                                                                    'Add Quantity',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                                  child:
                                                                      Container(
                                                                    height: size
                                                                            .height *
                                                                        0.055,
                                                                    width:
                                                                        size.width *
                                                                            0.5,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      border: Border.all(
                                                                          color:
                                                                              darkGreyTextColor1,
                                                                          width:
                                                                              0.5),
                                                                      // boxShadow: [
                                                                      //   BoxShadow(
                                                                      //       color: lightButtonGreyColor,
                                                                      //       spreadRadius: 2,
                                                                      //       blurRadius: 3
                                                                      //   )
                                                                      // ],
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (quantity >
                                                                                0) {
                                                                              setState(() {
                                                                                quantity = quantity - 1;
                                                                              });
                                                                            }
                                                                          },
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/minus.png',
                                                                            fit:
                                                                                BoxFit.scaleDown,
                                                                            height:
                                                                                size.height * 0.02,
                                                                            width:
                                                                                30,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          quantity
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Color(0xFF585858),
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              quantity = quantity + 1;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 0),
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/add1.png',
                                                                              fit: BoxFit.scaleDown,
                                                                              height: size.height * 0.02,
                                                                              width: 30,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  size.height *
                                                                      0.015,
                                                            ),
                                                            isLoadingAddCart
                                                                ? Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                    color:
                                                                        darkRedColor,
                                                                    strokeWidth:
                                                                        1,
                                                                  ))
                                                                : Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16),
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              color: Colors.black26,
                                                                              offset: Offset(0, 4),
                                                                              blurRadius: 5.0)
                                                                        ],
                                                                        gradient:
                                                                            LinearGradient(
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          stops: [
                                                                            0.0,
                                                                            1.0
                                                                          ],
                                                                          colors: [
                                                                            darkRedColor,
                                                                            lightRedColor,
                                                                          ],
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child: ElevatedButton(
                                                                          style: ButtonStyle(
                                                                            shape:
                                                                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                              RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),
                                                                            ),
                                                                            minimumSize:
                                                                                MaterialStateProperty.all(Size(size.width, 50)),
                                                                            backgroundColor:
                                                                                MaterialStateProperty.all(Colors.transparent),
                                                                            // elevation: MaterialStateProperty.all(3),
                                                                            shadowColor:
                                                                                MaterialStateProperty.all(Colors.transparent),
                                                                          ),
                                                                          onPressed: () {
                                                                            if (quantity <=
                                                                                0) {
                                                                              var snackBar = SnackBar(
                                                                                content: Text(
                                                                                  'Add Quantity',
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                                backgroundColor: Colors.green,
                                                                              );
                                                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                            } else {
                                                                              setState(() {
                                                                                isLoadingAddCart = true;
                                                                              });
                                                                              addToCart(categoriesProductsList[index].id.toString(), quantity.toString());
                                                                            }
                                                                          },
                                                                          child: Text('Add to Cart', style: buttonStyle)),
                                                                    ),
                                                                  ),
                                                            SizedBox(
                                                              height:
                                                                  size.height *
                                                                      0.02,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: Container(
                                                // height: size.height*0.25,
                                                width: size.width * 0.45,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color:
                                                            lightButtonGreyColor,
                                                        spreadRadius: 2,
                                                        blurRadius: 3)
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            size.height * 0.005,
                                                      ),
                                                      Container(
                                                        height:
                                                            size.height * 0.13,
                                                        width: size.width * 0.4,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                lightButtonGreyColor),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                height:
                                                                    size.height *
                                                                        0.13,
                                                                width:
                                                                    size.width *
                                                                        0.4,
                                                                imageUrl: imageConstUrlProduct +
                                                                    categoriesProductsList[
                                                                            index]
                                                                        .image
                                                                        .toString(),
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color:
                                                                          lightButtonGreyColor),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                            // Padding(
                                                            //   padding: const EdgeInsets.all(8.0),
                                                            //   child: Container(
                                                            //     width: size.width*0.22,
                                                            //     decoration: BoxDecoration(
                                                            //         color: Colors.white,
                                                            //         borderRadius: BorderRadius.circular(10)
                                                            //     ),
                                                            //     child: Padding(
                                                            //       padding: const EdgeInsets.all(6.0),
                                                            //       child: Row(children: [
                                                            //         Icon(Icons.star,size: 12,color: Colors.amber,),
                                                            //         Text(' (5.0) 34',
                                                            //           style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.bold),),
                                                            //       ],),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.height * 0.005,
                                                      ),
                                                      Container(
                                                        width: size.width * 0.4,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  size.width *
                                                                      0.3,
                                                              child: Text(
                                                                categoriesProductsList[
                                                                        index]
                                                                    .name
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF585858),
                                                                    fontSize:
                                                                        12,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      // <-- SEE HERE
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .vertical(
                                                                        top: Radius.circular(
                                                                            25.0),
                                                                      ),
                                                                    ),
                                                                    builder:
                                                                        (context) {
                                                                      return StatefulBuilder(builder:
                                                                          (context,
                                                                              setState) {
                                                                        return SizedBox(
                                                                          height:
                                                                              size.height * 0.36,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                width: size.width,
                                                                                height: size.height * 0.15,
                                                                                child: Row(
                                                                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 16, top: 13, right: 8, bottom: 20),
                                                                                      child: Container(
                                                                                        height: size.height * 0.1,
                                                                                        width: size.width * 0.3,
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: lightButtonGreyColor),
                                                                                        child: ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          child: CachedNetworkImage(
                                                                                            fit: BoxFit.cover,
                                                                                            height: size.height * 0.1,
                                                                                            width: size.width * 0.3,
                                                                                            imageUrl: imageConstUrlProduct + categoriesProductsList[index].image.toString(),
                                                                                            placeholder: (context, url) => Container(
                                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: lightButtonGreyColor),
                                                                                            ),
                                                                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      height: size.height * 0.1,
                                                                                      width: size.width * 0.5,
                                                                                      //  color: Colors.red,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 10),
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              categoriesProductsList[index].name.toString(),
                                                                                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: size.height * 0.01,
                                                                                            ),
                                                                                            Container(
                                                                                              height: size.height * 0.06,
                                                                                              width: size.width * 0.55,
                                                                                              child: Text(
                                                                                                categoriesProductsList[index].description.toString(),
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                                maxLines: 2,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                child: Row(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 16, top: 0, right: 8, bottom: 20),
                                                                                      child: Text(
                                                                                        'Price',
                                                                                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 16, top: 0, right: 8, bottom: 20),
                                                                                      child: Text(
                                                                                        'R ${categoriesProductsList[index].price.toString()}',
                                                                                        style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 16, top: 0, right: 8, bottom: 20),
                                                                                    child: Text(
                                                                                      'Add Quantity',
                                                                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 10),
                                                                                    child: Container(
                                                                                      height: size.height * 0.055,
                                                                                      width: size.width * 0.5,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        border: Border.all(color: darkGreyTextColor1, width: 0.5),
                                                                                        // boxShadow: [
                                                                                        //   BoxShadow(
                                                                                        //       color: lightButtonGreyColor,
                                                                                        //       spreadRadius: 2,
                                                                                        //       blurRadius: 3
                                                                                        //   )
                                                                                        // ],
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                        children: [
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              if (quantity > 0) {
                                                                                                setState(() {
                                                                                                  quantity = quantity - 1;
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                            child: Image.asset(
                                                                                              'assets/images/minus.png',
                                                                                              fit: BoxFit.scaleDown,
                                                                                              height: size.height * 0.02,
                                                                                              width: 30,
                                                                                              color: Colors.black,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            quantity.toString(),
                                                                                            style: TextStyle(color: Color(0xFF585858), fontSize: 18, fontWeight: FontWeight.w600),
                                                                                          ),
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                quantity = quantity + 1;
                                                                                              });
                                                                                            },
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(right: 0),
                                                                                              child: Image.asset(
                                                                                                'assets/images/add1.png',
                                                                                                fit: BoxFit.scaleDown,
                                                                                                height: size.height * 0.02,
                                                                                                width: 30,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: size.height * 0.015,
                                                                              ),
                                                                              isLoadingAddCart
                                                                                  ? Center(
                                                                                      child: CircularProgressIndicator(
                                                                                      color: darkRedColor,
                                                                                      strokeWidth: 1,
                                                                                    ))
                                                                                  : Padding(
                                                                                      padding: const EdgeInsets.only(left: 16, right: 16),
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          boxShadow: [
                                                                                            BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
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
                                                                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                                              // elevation: MaterialStateProperty.all(3),
                                                                                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                                            ),
                                                                                            onPressed: () {
                                                                                              if (quantity <= 0) {
                                                                                                var snackBar = SnackBar(
                                                                                                  content: Text(
                                                                                                    'Add Quantity',
                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                  ),
                                                                                                  backgroundColor: Colors.green,
                                                                                                );
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  isLoadingAddCart = true;
                                                                                                });
                                                                                                addToCart(categoriesProductsList[index].id.toString(), quantity.toString());
                                                                                              }
                                                                                            },
                                                                                            child: Text('Add to Cart', style: buttonStyle)),
                                                                                      ),
                                                                                    ),
                                                                              SizedBox(
                                                                                height: size.height * 0.02,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      });
                                                                    });

                                                                // showModalBottomSheet(
                                                                //     context: context,
                                                                //     shape: const RoundedRectangleBorder( // <-- SEE HERE
                                                                //       borderRadius: BorderRadius.vertical(
                                                                //         top: Radius.circular(25.0),
                                                                //       ),
                                                                //     ),
                                                                //     builder: (context) {
                                                                //       return StatefulBuilder(
                                                                //       builder: (context, setState) {
                                                                //         return SizedBox(
                                                                //           height: size.height*0.35,
                                                                //           child: Column(
                                                                //             crossAxisAlignment: CrossAxisAlignment.start,
                                                                //             mainAxisSize: MainAxisSize.min,
                                                                //             children:  <Widget>[
                                                                //
                                                                //               Container(
                                                                //                 width: size.width*0.9,
                                                                //                 child: Row(children: [
                                                                //
                                                                //
                                                                //                   Padding(
                                                                //                     padding: const EdgeInsets.only(left: 16,top: 16,right: 8,bottom: 20),
                                                                //                     child:
                                                                //
                                                                //                     Container(
                                                                //                       decoration: BoxDecoration(
                                                                //                         color: lightButtonGreyColor,
                                                                //                         borderRadius: BorderRadius.circular(10),
                                                                //                       ),
                                                                //                       child: ClipRRect(
                                                                //                         borderRadius: BorderRadius.circular(10),
                                                                //                         child: CachedNetworkImage(
                                                                //                           height:
                                                                //                           size.height *
                                                                //                               0.1,
                                                                //                           width: size.width *
                                                                //                               0.3,
                                                                //                           fit: BoxFit.cover,
                                                                //                           imageUrl:  imageConstUrlProduct +
                                                                //                               categoriesProductsList[
                                                                //                               index]
                                                                //                                   .image
                                                                //                                   .toString(),
                                                                //                           //placeholder: (context, url) => CircularProgressIndicator(),
                                                                //                           errorWidget: (context, url, error) => Icon(Icons.error),
                                                                //                         ),
                                                                //
                                                                //
                                                                //                         // Image.network(imageConstUrl+categoriesProductsList[index].image.toString() , fit: BoxFit.cover,
                                                                //                         //   height: size.height*0.16,
                                                                //                         //   width: size.width*0.7,
                                                                //                         //   // height: 80,
                                                                //                         //   // width: 80,
                                                                //                         // ),
                                                                //                       ),
                                                                //                     ),
                                                                //                   ),
                                                                //                   Padding(
                                                                //                     padding: const EdgeInsets.only(left: 10),
                                                                //                     child: Column(
                                                                //                       mainAxisAlignment: MainAxisAlignment.start,
                                                                //                       crossAxisAlignment: CrossAxisAlignment.start,
                                                                //                       children: [
                                                                //                       Text(
                                                                //                         categoriesProductsList[index].name.toString(), style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                                                                //                       SizedBox(
                                                                //                         height: 10,
                                                                //                       ),
                                                                //                       Container(
                                                                //                         width: size.width *
                                                                //                             0.5,
                                                                //                         child: Text(
                                                                //                           categoriesProductsList[index].description.toString(), style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500),),
                                                                //                       ),
                                                                //
                                                                //                     ],),
                                                                //                   ),
                                                                //                 ],),
                                                                //               ),
                                                                //               Row(children: [
                                                                //                 Padding(
                                                                //                   padding: const EdgeInsets.only(left: 16,top: 16,right: 8,bottom: 20),
                                                                //                   child: Text( 'Add Quantity', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                                                                //                 ),
                                                                //
                                                                //                 Padding(
                                                                //                   padding: const EdgeInsets.only(left: 10),
                                                                //                   child: Container(
                                                                //                     height: size.height*0.055,
                                                                //                     width: size.width*0.5,
                                                                //                     decoration: BoxDecoration(
                                                                //                       color: Colors.white,
                                                                //                       borderRadius: BorderRadius.circular(5),
                                                                //                       border: Border.all(color: darkGreyTextColor1,width: 0.5),
                                                                //                       // boxShadow: [
                                                                //                       //   BoxShadow(
                                                                //                       //       color: lightButtonGreyColor,
                                                                //                       //       spreadRadius: 2,
                                                                //                       //       blurRadius: 3
                                                                //                       //   )
                                                                //                       // ],
                                                                //                     ),
                                                                //
                                                                //                     child: Row(
                                                                //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                //
                                                                //                       children: [
                                                                //
                                                                //                         GestureDetector(
                                                                //                           onTap:() {
                                                                //                             if(quantity>0) {
                                                                //                               setState(() {
                                                                //                                 quantity = quantity -1;
                                                                //                               });
                                                                //                             }
                                                                //                           },
                                                                //                           child: Image.asset('assets/images/minus.png', fit: BoxFit.scaleDown,
                                                                //                             height: size.height*0.02,
                                                                //                             width: 30,
                                                                //                             color: Colors.black,
                                                                //                           ),
                                                                //                         ),
                                                                //
                                                                //                         Text(quantity.toString(),
                                                                //                           style: TextStyle(color: Color(0xFF585858), fontSize: 18,fontWeight: FontWeight.w600),),
                                                                //
                                                                //                         GestureDetector(
                                                                //                           onTap:() {
                                                                //                             setState(() {
                                                                //                               quantity = quantity+1;
                                                                //                             });
                                                                //                           },
                                                                //                           child: Padding(
                                                                //                             padding: const EdgeInsets.only(right: 0),
                                                                //                             child: Image.asset('assets/images/add1.png', fit: BoxFit.scaleDown,
                                                                //                               height: size.height*0.02,
                                                                //                               width: 30,
                                                                //                             ),
                                                                //                           ),
                                                                //                         ),
                                                                //                       ],
                                                                //                     ),
                                                                //                   ),
                                                                //                 ),
                                                                //
                                                                //               ],),
                                                                //               SizedBox(
                                                                //                 height: size.height * 0.02,
                                                                //               ),
                                                                //
                                                                //
                                                                //               isLoadingAddCart ? Center(child: CircularProgressIndicator(
                                                                //                 color: darkRedColor,
                                                                //                 strokeWidth: 1,
                                                                //               )) :
                                                                //               Padding(
                                                                //                 padding: const EdgeInsets.only(left: 16, right: 16),
                                                                //                 child: Container(
                                                                //                   decoration: BoxDecoration(
                                                                //                     boxShadow: [
                                                                //                       BoxShadow(
                                                                //                           color: Colors.black26,
                                                                //                           offset: Offset(0, 4),
                                                                //                           blurRadius: 5.0)
                                                                //                     ],
                                                                //                     gradient: LinearGradient(
                                                                //                       begin: Alignment.topLeft,
                                                                //                       end: Alignment.bottomRight,
                                                                //                       stops: [0.0, 1.0],
                                                                //                       colors: [
                                                                //                         darkRedColor,
                                                                //                         lightRedColor,
                                                                //                       ],
                                                                //                     ),
                                                                //                     borderRadius: BorderRadius.circular(10),
                                                                //                   ),
                                                                //                   child: ElevatedButton(
                                                                //                       style: ButtonStyle(
                                                                //                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                //                           RoundedRectangleBorder(
                                                                //                             borderRadius: BorderRadius.circular(10.0),
                                                                //                           ),
                                                                //                         ),
                                                                //                         minimumSize:
                                                                //                         MaterialStateProperty.all(Size(size.width, 50)),
                                                                //                         backgroundColor:
                                                                //                         MaterialStateProperty.all(Colors.transparent),
                                                                //                         // elevation: MaterialStateProperty.all(3),
                                                                //                         shadowColor:
                                                                //                         MaterialStateProperty.all(Colors.transparent),
                                                                //                       ),
                                                                //                       onPressed: () {
                                                                //
                                                                //                         if(quantity <= 0) {
                                                                //                           var snackBar = SnackBar(content: Text('Add Quantity'
                                                                //                             ,style: TextStyle(color: Colors.white),),
                                                                //                             backgroundColor: Colors.green,
                                                                //                           );
                                                                //                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                //
                                                                //                         } else {
                                                                //                           setState(() {
                                                                //                             isLoadingAddCart = true;
                                                                //                           });
                                                                //                           addToCart(
                                                                //                               categoriesProductsList[index]
                                                                //                                   .id
                                                                //                                   .toString()
                                                                //                           , quantity.toString());
                                                                //                         }
                                                                //
                                                                //
                                                                //                       },
                                                                //                       child: Text('Add to Cart', style: buttonStyle)),
                                                                //                 ),
                                                                //               ),
                                                                //               SizedBox(
                                                                //                 height: size.height * 0.02,
                                                                //               ),
                                                                //
                                                                //             ],
                                                                //           ),
                                                                //         );
                                                                //       });
                                                                //     });
                                                              },
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/add.png',
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                                height: 20,
                                                                width: 20,
                                                                // height: 80,
                                                                // width: 80,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.height * 0.005,
                                                      ),
                                                      Container(
                                                        width: size.width * 0.4,
                                                        child: Text(
                                                          categoriesProductsList[
                                                                          index]
                                                                      .description
                                                                      .toString() ==
                                                                  'null'
                                                              ? categoriesProductsList[
                                                                      index]
                                                                  .name
                                                                  .toString()
                                                              : categoriesProductsList[
                                                                      index]
                                                                  .description
                                                                  .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  darkGreyTextColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.height * 0.01,
                                                      ),

                                                      Container(
                                                        width: size.width * 0.4,
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left:
                                                                  0,
                                                                  top: 0,
                                                                  right:
                                                                  0,
                                                              ),
                                                              child: Text(
                                                                'Flavour',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                    10,
                                                                    fontWeight:
                                                                    FontWeight.bold),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left:
                                                                  16,
                                                                  top: 0,
                                                                  right:
                                                                  0,
                                                                  ),
                                                              child: Container(
                                                                width: size.width * 0.23,
                                                                child: Text(
                                                                  categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.MILD' ?  'Mild' :
                                                                  categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.COLD' ?  'Cold' :
                                                                  categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.HOT' ?  'Hot' :
                                                                  categoriesProductsList[index].flavourIds![0].flavours!.name.toString() ==  'FlavoursName.ROASTED_CHILLI_HOT_BUT_YUMMY' ?  'Roasted Chilli, (Hot But Yummy)' :

                                                                  categoriesProductsList[index].flavourIds![0].flavours!.name.toString()
                                                                 // categoriesProductsList[index].flavourIds![0].
                                                                  ,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      fontSize:
                                                                      10,
                                                                      fontWeight:
                                                                      FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ) ,

                                                      SizedBox(
                                                        height:
                                                            size.height * 0.01,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        // : index == 0
                                        //     ? Container(
                                        //         width: size.width,
                                        //         // color: Colors.red,
                                        //         child: Row(
                                        //           mainAxisAlignment:
                                        //               MainAxisAlignment.center,
                                        //           children: [
                                        //             Center(
                                        //               child: Text(
                                        //                 'No products found',
                                        //                 style: TextStyle(
                                        //                     color: Colors.black,
                                        //                     fontSize: 12),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        : SizedBox();
                                  }),
                            ),
                          ),
              ],
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            isLoaded == 'yes' && categoriesProductsList.isEmpty ? SizedBox() :
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 5.0)
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
                      minimumSize:
                          MaterialStateProperty.all(Size(size.width, 50)),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      // elevation: MaterialStateProperty.all(3),
                      shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      cartController.fetchCartItems();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashBoardScreen(index: 1)));
                      //
                    },
                    child: Text('Go to Cart', style: buttonStyle)),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductBottomSheet extends StatefulWidget {
  //final Product product;
  final bool isCampaign;
  //final CartModel cart;
  final int cartIndex;
  final bool inRestaurantPage;
  ProductBottomSheet(
      {
      //@required this.product,
      this.isCampaign = false,
      required this.cartIndex,
      this.inRestaurantPage = false});

  @override
  State<ProductBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  @override
  void initState() {
    super.initState();

    //Get.find<ProductController>().initData(widget.product, widget.cart);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: 550,
      // margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      // padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_DEFAULT, bottom: Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // borderRadius: ResponsiveHelper.isMobile(context) ? BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE))
        //     : BorderRadius.all(Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
      ),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: darkGreyTextColor,
                    ),
                    width: size.width * 0.2,
                  ),
                ),
              ),
              // SizedBox(
              //   height: size.height*0.02,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => print('Popular'),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Container(
                            decoration: BoxDecoration(
                                color: lightGreenColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Popular',
                                style: robotoRegular.copyWith(
                                    fontSize: 12, color: Colors.black),
                              ),
                            )),
                      )),

                  // InkWell(onTap: () => Get.back(), child: Padding(
                  //   padding:  EdgeInsets.all(8),
                  //   child: Container(
                  //       decoration: BoxDecoration(
                  //         color: lightGreenColor,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(2.0),
                  //         child: Icon(Icons.close,color: darkGreenColor,),
                  //       )),
                  // )),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(
                  right: 8,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 10, bottom: 10),
                        child: Text(
                          'name',
                          style: robotoMedium.copyWith(fontSize: 20),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      ///Product
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: lightButtonGreyColor,
                      //     borderRadius: BorderRadius.circular(10)
                      //   ),
                      //
                      //   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      //
                      //     (widget.product.image != null && widget.product.image.isNotEmpty) ? Padding(
                      //       padding: const EdgeInsets.only(right: 10.0),
                      //       child: InkWell(
                      //         onTap: widget.isCampaign ? null : () {
                      //           if(!widget.isCampaign) {
                      //             Get.toNamed(RouteHelper.getItemImagesRoute(widget.product));
                      //           }
                      //         },
                      //         child: Stack(children: [
                      //           ClipRRect(
                      //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      //             child: CustomImage(
                      //               image: '${widget.isCampaign ? Get.find<SplashController>().configModel.baseUrls.campaignImageUrl
                      //                   : Get.find<SplashController>().configModel.baseUrls.productImageUrl}/${widget.product.image}',
                      //               width: ResponsiveHelper.isMobile(context) ? 100 : 140,
                      //               height: ResponsiveHelper.isMobile(context) ? 100 : 140,
                      //               fit: BoxFit.cover,
                      //             ),
                      //           ),
                      //           DiscountTag(discount: _discount, discountType: _discountType, fromTop: 20),
                      //         ]),
                      //       ),
                      //     ) : SizedBox.shrink(),
                      //
                      //     Expanded(
                      //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      //         Text(
                      //           widget.product.name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      //           maxLines: 2, overflow: TextOverflow.ellipsis,
                      //         ),
                      //         InkWell(
                      //           onTap: () {
                      //             if(widget.inRestaurantPage) {
                      //               Get.back();
                      //             }else {
                      //               Get.offNamed(RouteHelper.getRestaurantRoute(widget.product.restaurantId));
                      //             }
                      //           },
                      //           child: Padding(
                      //             padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      //             child: Text(
                      //               widget.product.restaurantName,
                      //               style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: darkGreenColor,//Theme.of(context).primaryColor
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         RatingBar(rating: widget.product.avgRating, size: 15, ratingCount: widget.product.ratingCount),
                      //         SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      //
                      //         Text(
                      //           '${PriceConverter.convertPrice(_price, discount: _discount, discountType: _discountType)}',
                      //           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      //         ),
                      //
                      //         Row(children: [
                      //           _price > priceWithDiscount ? Text(
                      //             '${PriceConverter.convertPrice(_price)}',
                      //             style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                      //           ) : SizedBox(),
                      //           SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      //
                      //           (widget.product.image != null && widget.product.image.isNotEmpty)? SizedBox.shrink()
                      //               : DiscountTagWithoutImage(discount: _discount, discountType: _discountType),
                      //         ]),
                      //
                      //       ]),
                      //     ),
                      //
                      //     Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      //       Get.find<SplashController>().configModel.toggleVegNonVeg ? Padding(
                      //         padding: const EdgeInsets.only(right: 5,top: 2),
                      //         child: Container(
                      //           padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      //             color: Theme.of(context).primaryColor,
                      //           ),
                      //           child: Text(
                      //             widget.product.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                      //             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color:darkGreenColor,//Colors.white
                      //             ),
                      //           ),
                      //         ),
                      //       ) : SizedBox(),
                      //       SizedBox(height: Get.find<SplashController>().configModel.toggleVegNonVeg ? 50 : 0),
                      //       widget.isCampaign ? SizedBox(height: 25) : GetBuilder<WishListController>(builder: (wishList) {
                      //         return Padding(
                      //           padding: const EdgeInsets.only(bottom: 2),
                      //           child: InkWell(
                      //             onTap: () {
                      //               if(Get.find<AuthController>().isLoggedIn()) {
                      //                 wishList.wishProductIdList.contains(widget.product.id) ? wishList.removeFromWishList(widget.product.id, false)
                      //                     : wishList.addToWishList(widget.product, null, false);
                      //               }else {
                      //                 showCustomSnackBar('you_are_not_logged_in'.tr);
                      //               }
                      //             },
                      //             child: Icon(
                      //               wishList.wishProductIdList.contains(widget.product.id) ? Icons.favorite : Icons.favorite,
                      //               color: wishList.wishProductIdList.contains(widget.product.id) ? Colors.red//Theme.of(context).primaryColor
                      //                   : darkGreyTextColor,
                      //             ),
                      //           ),
                      //         );
                      //       }),
                      //     ]),
                      //
                      //   ]),
                      // ),

                      // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('description', style: robotoMedium),
                          SizedBox(height: 4),
                          Text('description', style: robotoRegular),
                          SizedBox(height: 20),
                        ],
                      ),

                      /// Variation

                      Expanded(
                          child: Container(
                        width: MediaQuery.of(context).size.width / 2.0,
                        child: Text('add_to_cart'),
                      )),
                    ]),
              ),
            ]),
      ),

      // GetBuilder<ProductController>(builder: (productController) {
      //   double _price = widget.product.price;
      //   double _variationPrice = 0;
      //   if(widget.product.variations != null){
      //     for(int index = 0; index< widget.product.variations.length; index++) {
      //       for(int i=0; i<widget.product.variations[index].variationValues.length; i++) {
      //         if(productController.selectedVariations[index][i]) {
      //           _variationPrice += widget.product.variations[index].variationValues[i].optionPrice;
      //         }
      //       }
      //     }
      //   }
      //   double _discount = (widget.isCampaign || widget.product.restaurantDiscount == 0) ? widget.product.discount : widget.product.restaurantDiscount;
      //   String _discountType = (widget.isCampaign || widget.product.restaurantDiscount == 0) ? widget.product.discountType : 'percent';
      //   double priceWithDiscount = PriceConverter.convertWithDiscount(_price, _discount, _discountType);
      //   // double priceWithQuantity = priceWithDiscount * productController.quantity;
      //   double addonsCost = 0;
      //   List<AddOn> _addOnIdList = [];
      //   List<AddOns> _addOnsList = [];
      //   for (int index = 0; index < widget.product.addOns.length; index++) {
      //     if (productController.addOnActiveList[index]) {
      //       addonsCost = addonsCost + (widget.product.addOns[index].price * productController.addOnQtyList[index]);
      //       _addOnIdList.add(AddOn(id: widget.product.addOns[index].id, quantity: productController.addOnQtyList[index]));
      //       _addOnsList.add(widget.product.addOns[index]);
      //     }
      //   }
      //   double priceWithAddonsVariation = addonsCost + (PriceConverter.convertWithDiscount(_variationPrice + _price , _discount, _discountType) * productController.quantity);
      //   double priceWithAddonsVariationWithoutDiscount = ((_price + _variationPrice) * productController.quantity) + addonsCost;
      //   double priceWithVariation = _price + _variationPrice;
      //   bool _isAvailable = DateConverter.isAvailable(widget.product.availableTimeStarts, widget.product.availableTimeEnds);
      //   final size = MediaQuery.of(context).size;
      //   return
      // }),
    );
  }

  void _showCartSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      dismissDirection: DismissDirection.horizontal,
      margin: EdgeInsets.all(8),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
      action: SnackBarAction(
          label: 'view_cart',
          textColor: Colors.white,
          onPressed: () {
            // Get.toNamed(RouteHelper.getCartRoute());
          }),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(
        'item_added_to_cart',
        style: robotoMedium.copyWith(color: Colors.white),
      ),
    ));
    // Get.showSnackbar(GetSnackBar(
    //   backgroundColor: Colors.green,
    //   message: 'item_added_to_cart'.tr,
    //   mainButton: TextButton(
    //     onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
    //     child: Text('view_cart'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
    //   ),
    //   onTap: (_) => Get.toNamed(RouteHelper.getCartRoute()),
    //   duration: Duration(seconds: 3),
    //   maxWidth: Dimensions.WEB_MAX_WIDTH,
    //   snackStyle: SnackStyle.FLOATING,
    //   margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
    //   borderRadius: 10,
    //   isDismissible: true,
    //   dismissDirection: DismissDirection.horizontal,
    // ));
  }

//  void _showUpperCartSnackBar(String message) {
  //   Get.showSnackbar(
  //       GetSnackBar(
  //     backgroundColor: Colors.red,
  //     message: message,
  //     duration: Duration(seconds: 3),
  //     maxWidth: double.infinity,
  //    // snackStyle: SnackStyle.FLOATING,
  //     margin: EdgeInsets.all(8),
  //     borderRadius: 10,
  //     isDismissible: true,
  //     dismissDirection: DismissDirection.horizontal,
  //   ));
  // }
}

final robotoRegular = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

final robotoMedium = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: 12,
);
