import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/add_Ons_Model.dart';
import 'package:figma_new_project/model/cart_body_model.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum FullChickenOptions { noCut, Cut2, Cut4, Cut8 }

enum ProductFlavour { mexicnChili, roastedChili, Legend, LemonAndHerb }

enum Drinks { pepsi, sprite }

enum Sauces { basting, sprinkle }

enum ChickenPieceOptions { leg, breast }

enum Chips { small, medium, large }

class AddOnModel {
  final int id;
  final String name;
  final String categoryName;
  final String price;
  final int restaurantId;
  bool selected;

  AddOnModel(this.id, this.name, this.categoryName, this.price,
      this.restaurantId, this.selected);
}

class ProductDetailScreen extends StatefulWidget {
  final CategoriesProductsModel product;
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  FullChickenOptions fullChickenOptions = FullChickenOptions.noCut;
  ChickenPieceOptions chickenPieceOptions = ChickenPieceOptions.leg;
  Drinks drinks = Drinks.pepsi;
  Sauces sauces = Sauces.basting;
  List<AddOnsDataModel> addOnsModelList = [];
  List<AddOnModel> addOnsModelListChooseCut = [];
  List<AddOnModel> selectedAddOns = [];
  List<AddOnModel> addOnsModelListDrinks = [];
  List<AddOnModel> addOnsModelListSauces = [];
  List<AddOnModel> addOnsModelListChips = [];
  List<AddOnModel> addOnsModelListAddASide = [];
  List<AddOnModel> addOnsModelListFlavour = [];
  List<int> addOns = [];
  final TextEditingController _specialInstructionController =
      TextEditingController();
  int selectedModelIdChooseCut = 0;
  int selectedModelIdChips = 0;
  int selectedModelIdDrinks = 0;
  int? selectedModelIdASide;
  int selectedModelIdSauces = 0;
  int selectedModelIdFlavour = 0;
  Chips chips = Chips.small;
  ProductFlavour flavours = ProductFlavour.mexicnChili;
  int quantity = 0;
  String restaurantName = '';

  // bool noCut = false;
  // bool noCut2 = false;
  // bool noCut4 = false;
  // bool noCut8 = false;
  // bool legPieace = false;
  // bool breastPieace = false;
  bool isLoadingData = false;
  bool roll = false;
  bool showFullChicken = false;
  bool showChickenPiece = false;
  bool spicyRice = false;
  bool pap = false;
  bool coleslaw = false;
  // bool chipsSmall = false;
  // bool chipsMedium = false;
  // bool chipsLarge = false;
  bool drinkPepsi = false;
  bool drinkSprite = false;
  bool saucesBasting = false;
  bool saucesSprinkle = false;
  bool flavourExtraHot = false;
  bool flavourHotButYummy = false;
  bool flavourMildWithKick = false;
  bool flavourMildTasty = false;
  CartBody? cartBody;

  bool isLoadingAddCart = false;
  final cartController = Get.put(AddToCartController());

  void addToCart(String productId, String quantity1) async {
    try {
       var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie'
      };
      var request = http.Request('POST', Uri.parse('${apiBaseUrl}add_to_cart'));
      request.body = json.encode(
        cartBody!.toJson()
      );
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        print(jsonEncode(addOns));
        print('we are in 200');
        setState(() {
          _specialInstructionController.clear();
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
      }
      else {
        setState(() {
          _specialInstructionController.clear();
          isLoadingAddCart = false;
          quantity = 1;
        });
       // print(await response.stream.bytesToString());
        print(response.reasonPhrase);
        print(response.statusCode);
      }
    } catch (e) {
      setState(() {
        _specialInstructionController.clear();
        isLoadingAddCart = false;
      });
      print('response after Hello getProducts' + e.toString());

      if (e.toString() ==
          'Bad state: Response has no Location header for redirect') {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var snackBar = SnackBar(
          content: Text(
            'Network connection problem. Try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // await preferences.clear().then((value){
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => LoginScreen()),
        //   );
        // });
      } else if (e.toString() == 'Connection timed out') {
        setState(() {
          _specialInstructionController.clear();
          isLoadingAddCart = false;
        });
        var snackBar = SnackBar(
          content: Text(
            'Network connection problem. Try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void getAddOns() async {
    print('we are in getCategories');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAddOns.clear();
      isLoadingData = true;
      // loadData =1;
      // isLoadingC = true;
      addOnsModelListChooseCut.clear();
      addOnsModelListChips.clear();
      addOnsModelListAddASide.clear();
      addOnsModelListDrinks.clear();
      addOnsModelListSauces.clear();
    });

    try {
      var headers = {
        // 'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie',
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var request = http.Request(
          'GET', Uri.parse('${apiBaseUrl}addons'));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseData = await response.stream.bytesToString();
      // final data = json.decode(responseData);
      // print(data['message'].toString()+ ' Data is here');

      if (response.statusCode == 200) {
        setState(() {
          addOnsModelList = List<AddOnsDataModel>.from(json
              .decode(responseData)
              .map((x) => AddOnsDataModel.fromJson(x)));
        });

        if (addOnsModelList.isNotEmpty) {
          print('we are here in isNotEmpty restaurantCategoriesList1');

          for (int i = 0; i < addOnsModelList.length; i++) {
            // AddOnsDataModel.fromJson(json)
print(addOnsModelList[i].category!.name.toString());
            if (addOnsModelList[i].category!.name.toString() ==
                'Choose Cut') {
              if (widget.product.name!.contains('Full chicken') ||
                  widget.product.name!.contains('Full Chicken')) {
                if (addOnsModelList[i].name.toString() == 'Leg Piece' ||
                    addOnsModelList[i].name.toString() == 'Breast Piece') {
                  print('Its for half');
                } else {
                  setState(() {
                    addOnsModelListChooseCut.add(AddOnModel(
                        addOnsModelList[i].id!,
                        addOnsModelList[i].name.toString(),
                        addOnsModelList[i].category!.name.toString(),
                        addOnsModelList[i].price.toString(),
                        0,
                        false));
                  });
                }
              } else if (widget.product.name!.contains('Chicken piece') ||
                  widget.product.name!.contains('1/2 chicken')) {
                if (addOnsModelList[i].name.toString() == 'Leg Piece' ||
                    addOnsModelList[i].name.toString() == 'Breast Piece') {
                  setState(() {
                    addOnsModelListChooseCut.add(AddOnModel(
                        addOnsModelList[i].id!,
                        addOnsModelList[i].name.toString(),
                        addOnsModelList[i].category!.name.toString(),
                        addOnsModelList[i].price.toString(),
                        0,                        false));
                  });
                } else {
                  print('Its for full');
                }
              }
            }
            else if (addOnsModelList[i].category!.name.toString() ==
                'Drinks' ||
                addOnsModelList[i].category!.name.toString() == 'Drink') {
              setState(() {
                addOnsModelListDrinks.add(AddOnModel(
                    addOnsModelList[i].id!,
                    addOnsModelList[i].name.toString(),
                    addOnsModelList[i].category!.name.toString(),
                    addOnsModelList[i].price.toString(),
                    0,
                    false));
              });
            }
            else if (addOnsModelList[i].category!.name.toString() ==
                'Sauces') {
              setState(() {
                addOnsModelListSauces.add(AddOnModel(
                    addOnsModelList[i].id!,
                    addOnsModelList[i].name.toString(),
                    addOnsModelList[i].category!.name.toString(),
                    addOnsModelList[i].price.toString(),
                    0,
                    false));
              });
            }
            else if (addOnsModelList[i].category!.name.toString() ==
                'Add a side') {
              setState(() {
                addOnsModelListAddASide.add(AddOnModel(
                    addOnsModelList[i].id!,
                    addOnsModelList[i].name.toString(),
                    addOnsModelList[i].category!.name.toString(),
                    addOnsModelList[i].price.toString(),
                    0,
                    false));
              });
            }
            else if (addOnsModelList[i].category!.name.toString() ==
                'Chips') {
              setState(() {
                addOnsModelListChips.add(AddOnModel(
                    addOnsModelList[i].id!,
                    addOnsModelList[i].name.toString(),
                    addOnsModelList[i].category!.name.toString(),
                    addOnsModelList[i].price.toString(),
                    0,
                    false));
              });
            }
            else if (addOnsModelList[i].category!.name.toString() ==
                'Flavours') {
              setState(() {
                addOnsModelListFlavour.add(AddOnModel(
                    addOnsModelList[i].id!,
                    addOnsModelList[i].name.toString(),
                    addOnsModelList[i].category!.name.toString(),
                    addOnsModelList[i].price.toString(),
                    0,
                    false));
              });
            }

            if (addOnsModelList.length - 1 == i) {
              setState(() {
                isLoadingData = false;
              });
            }
          }
        } else if (addOnsModelList.isEmpty) {
          print('we are here in empty addOnsModelList');
          setState(() {
            isLoadingData = false;
            // isLoadingC = false;
            // emptyCategory = 'yes';
            // category = 'yes';
          });
        }
      } else if (response.statusCode == 302) {
        print('we are in getCategories 302');
        setState(() {
          isLoadingData = false;
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
          isLoadingData = false;
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
        print('we are in getCategories else');
        setState(() {
          isLoadingData = false;
        });
        print(response.reasonPhrase.toString() + ' Hello error');
      }
    } catch (e) {
      print('we are in getCategories catch $e');
      print(e.toString());

      if (e.toString() ==
          'Bad state: Response has no Location header for redirect') {}
    }
  }

  void getRestaurantDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.product.name!.contains('Full chicken') ||
        widget.product.name!.contains('Full Chicken')) {
      setState(() {
        showFullChicken = true;
      });
    } else if (widget.product.name!.contains('Chicken piece') ||
        widget.product.name!.contains('1/2 chicken')) {
      setState(() {
        showChickenPiece = true;
      });
    }

    if (prefs.getString('selectedRestaurant') != null) {
      setState(() {
        restaurantName = prefs.getString('restaurantName').toString();
      });

      print(prefs.getString('selectedRestaurant').toString() +
          ' selectedRestaurant 123');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    print(widget.product.id.toString() + ' Product Id');
    setState(() {
      _specialInstructionController.clear();
      addOns.clear();
      isLoadingAddCart = false;
      restaurantName = '';
      quantity = 1;
    });
    getAddOns();
    getRestaurantDetail();
    super.initState();
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
          widget.product.name.toString(),
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
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
        //  height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              //      height: size.height*0.3,
              width: size.width,
              decoration: BoxDecoration(
                color: lightButtonGreyColor,
                //  borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                //borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  height: size.height * 0.3,
                  width: size.width,
                  fit: BoxFit.cover,
                  imageUrl:
                      imageConstUrlProduct + widget.product.image.toString(),
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Container(
              width: size.width * 0.9,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: size.width * 0.8,
                          child: Text(
                            widget.product.description.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Container(
                        //   width: size.width *
                        //       0.8,
                        //   child: Text(
                        //     restaurantName.toString(), style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w600),),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            // Container(
            //   child: Row(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets
            //             .only(
            //             left:
            //             10,
            //             top: 0,
            //             right:
            //             8,
            //             bottom:
            //             20),
            //         child: Text(
            //           'Flavour',
            //           style: TextStyle(
            //               color: Colors
            //                   .black,
            //               fontSize:
            //               13,
            //               fontWeight:
            //               FontWeight.bold),
            //         ),
            //       ),
            //       widget.product.flavourIds != null ?
            //       Padding(
            //         padding: const EdgeInsets
            //             .only(
            //             left:
            //             16,
            //             top: 0,
            //             right:
            //             8,
            //             bottom:
            //             20),
            //         child: Text(
            //           // widget.product.flavourIds![0].flavours!.name.toString() ==  'FlavoursName.MILD' ?  'Mild' :
            //           // widget.product.flavourIds![0].flavours!.name.toString() ==  'FlavoursName.COLD' ?  'Cold' :
            //           // widget.product.flavourIds![0].flavours!.name.toString() ==  'FlavoursName.HOT' ?  'Hot' :
            //           // widget.product.flavourIds![0].flavours!.name.toString() ==  'FlavoursName.ROASTED_CHILLI_HOT_BUT_YUMMY' ?  'Roasted Chilli, (Hot But Yummy)' :
            //           widget.product.flavourIds![0].flavours!.name.toString()
            //           ,
            //           style: TextStyle(
            //               color: Colors
            //                   .red,
            //               fontSize:
            //               13,
            //               fontWeight:
            //               FontWeight.bold),
            //         ),
            //       ) : Container(),
            //     ],
            //   ),
            // ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    'Price',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    // height: size.height*0.055,
                    // width: size.width*0.5,
                    child: Text(
                      'R ' + widget.product.price.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, top: 16, right: 8, bottom: 20),
                  child: Text(
                    'Add Quantity',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Color(0xFF585858),
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
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
              height: size.height * 0.02,
            ),

            isLoadingData
                ? Center(
                    child: CircularProgressIndicator(
                      color: darkRedColor,
                      strokeWidth: 1,
                    ),
                  )
                : isLoadingData == false && addOnsModelList.isEmpty
                    ? Container(
                        child: Center(
                          child: Text(
                            'No add ons found in this restaurant.',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      )
                    : isLoadingData == false && addOnsModelList.isNotEmpty
                        ?
            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              addOnsModelListChooseCut.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Choose cut',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: lightButtonGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Column(
                                                children:
                                                    addOnsModelListChooseCut
                                                        .map((model) {
                                                  return Container(
                                                    height: tileHeight,
                                                    child: RadioListTile(
                                                      activeColor: darkRedColor,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        model.name,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                addOnTextSize),
                                                      ),
                                                      value: model.id,
                                                      groupValue:
                                                          selectedModelIdChooseCut,
                                                      onChanged: (int? value) {
                                                        setState(() {
                                                          selectedModelIdChooseCut = value!;
                                                        });
                                                        if (selectedAddOns.any(
                                                            (model1) =>
                                                                model1
                                                                    .categoryName ==
                                                                model
                                                                    .categoryName)) {
                                                          print(
                                                              'exists we are here');
                                                          setState(() {
                                                            selectedAddOns.removeWhere(
                                                                (element) =>
                                                                    element
                                                                        .categoryName ==
                                                                    model
                                                                        .categoryName);
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        } else {
                                                          print(
                                                              ' not exists we are here');
                                                          setState(() {
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              addOnsModelListChips.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Chips',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: lightButtonGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Column(
                                                children: addOnsModelListChips
                                                    .map((model) {
                                                  return Container(
                                                    height: tileHeight,
                                                    child: RadioListTile(
                                                      activeColor: darkRedColor,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      secondary: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Text(
                                                          'R ' + model.price,
                                                          style: TextStyle(
                                                              color:
                                                                  darkRedColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize:
                                                                  addOnTextSize),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        model.name,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                addOnTextSize),
                                                      ),
                                                      value: model.id,
                                                      groupValue:
                                                          selectedModelIdChips,
                                                      onChanged: (int? value) {
                                                        setState(() {
                                                          selectedModelIdChips =
                                                              value!;
                                                        });

                                                        if (selectedAddOns.any(
                                                            (model1) =>
                                                                model1
                                                                    .categoryName ==
                                                                model
                                                                    .categoryName)) {
                                                          print(
                                                              'exists we are here');
                                                          setState(() {
                                                            selectedAddOns.removeWhere(
                                                                (element) =>
                                                                    element
                                                                        .categoryName ==
                                                                    model
                                                                        .categoryName);
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        } else {
                                                          print(
                                                              ' not exists we are here');
                                                          setState(() {
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              addOnsModelListDrinks.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Drinks',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: lightButtonGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Column(
                                                children: addOnsModelListDrinks
                                                    .map((model) {
                                                  return Container(
                                                    height: tileHeight,
                                                    child: RadioListTile(
                                                      activeColor: darkRedColor,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      secondary: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Text(
                                                          'R ' + model.price,
                                                          style: TextStyle(
                                                              color:
                                                                  darkRedColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize:
                                                                  addOnTextSize),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        model.name,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                addOnTextSize),
                                                      ),
                                                      value: model.id,
                                                      groupValue:
                                                          selectedModelIdDrinks,
                                                      onChanged: (int? value) {
                                                        setState(() {
                                                          selectedModelIdDrinks =
                                                              value!;
                                                        });

                                                        if (selectedAddOns.any(
                                                            (model1) =>
                                                                model1
                                                                    .categoryName ==
                                                                model
                                                                    .categoryName)) {
                                                          print(
                                                              'exists we are here');
                                                          setState(() {
                                                            selectedAddOns.removeWhere(
                                                                (element) =>
                                                                    element
                                                                        .categoryName ==
                                                                    model
                                                                        .categoryName);
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        } else {
                                                          print(
                                                              ' not exists we are here');
                                                          setState(() {
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              addOnsModelListSauces.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Sauces',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: lightButtonGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Column(
                                                children: addOnsModelListSauces
                                                    .map((model) {
                                                  return Container(
                                                    height: tileHeight,
                                                    child: RadioListTile(
                                                      activeColor: darkRedColor,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      secondary: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Text(
                                                          'R ' +model.price,
                                                          style: TextStyle(
                                                              color:
                                                                  darkRedColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize:
                                                                  addOnTextSize),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        model.name,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                addOnTextSize),
                                                      ),
                                                      value: model.id,
                                                      groupValue:
                                                          selectedModelIdSauces,
                                                      onChanged: (int? value) {
                                                        setState(() {
                                                          selectedModelIdSauces =
                                                              value!;
                                                        });

                                                        if (selectedAddOns.any(
                                                            (model1) =>
                                                                model1
                                                                    .categoryName ==
                                                                model
                                                                    .categoryName)) {
                                                          print(
                                                              'exists we are here');
                                                          setState(() {
                                                            selectedAddOns
                                                                .removeWhere(
                                                                    (element) =>
                                                                        element
                                                                            .categoryName ==
                                                                        'Sauces');
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        } else {
                                                          print(
                                                              ' not exists we are here');
                                                          setState(() {
                                                            selectedAddOns.add(
                                                                AddOnModel(
                                                                    model.id,
                                                                    model.name,
                                                                    model
                                                                        .categoryName,
                                                                    model.price,
                                                                    model
                                                                        .restaurantId,
                                                                    false));
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),

                              addOnsModelListFlavour.isNotEmpty
                                  ? Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Flavours',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: lightButtonGreyColor,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20),
                                        child: Column(
                                          children: addOnsModelListFlavour
                                              .map((model) {
                                            return Container(
                                              height: tileHeight,
                                              child: RadioListTile(
                                                activeColor: darkRedColor,
                                                contentPadding:
                                                EdgeInsets.zero,

                                                title: Text(
                                                  model.name,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      fontSize:
                                                      addOnTextSize),
                                                ),
                                                value: model.id,
                                                groupValue:
                                                selectedModelIdFlavour,
                                                onChanged: (int? value) {
                                                  setState(() {
                                                    selectedModelIdFlavour =
                                                        value!;
                                                    print(value);
                                                  });

                                                  if (selectedAddOns.any(
                                                          (model1) =>
                                                      model1
                                                          .categoryName ==
                                                          model
                                                              .categoryName)) {
                                                    print(
                                                        'exists we are here');
                                                    setState(() {
                                                      selectedAddOns.removeWhere(
                                                              (element) =>
                                                          element
                                                              .categoryName ==
                                                              model
                                                                  .categoryName);
                                                      selectedAddOns.add(
                                                          AddOnModel(
                                                              model.id,
                                                              model.name,
                                                              model
                                                                  .categoryName,
                                                              model.price,
                                                              model
                                                                  .restaurantId,
                                                              false));
                                                    });
                                                  } else {
                                                    print(
                                                        ' not exists we are here');
                                                    setState(() {
                                                      selectedAddOns.add(
                                                          AddOnModel(
                                                              model.id,
                                                              model.name,
                                                              model
                                                                  .categoryName,
                                                              model.price,
                                                              model
                                                                  .restaurantId,
                                                              false));
                                                    });
                                                  }
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),

                              addOnsModelListAddASide.isNotEmpty
                                  ? Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Add a side',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: lightButtonGreyColor,
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: addOnsModelListAddASide.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              height: tileHeight,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                horizontalTitleGap: 10,
                                                minVerticalPadding: 0,
                                                leading:  Checkbox(value: addOnsModelListAddASide[index].selected,
                                                  activeColor: darkRedColor
                                                  ,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      addOnsModelListAddASide[index].selected = value!;
                                                    });

                                                    if (selectedAddOns.any(
                                                            (model1) =>
                                                        model1.name ==
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .name)) {
                                                      print(
                                                          'exists we are here');
                                                      setState(() {
                                                        selectedAddOns.removeWhere(
                                                                (element) =>
                                                            element
                                                                .name ==
                                                                addOnsModelListAddASide[
                                                                index]
                                                                    .name);
                                                        selectedAddOns.add(AddOnModel(
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .id,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .name,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .categoryName,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .price,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .restaurantId,
                                                            false));
                                                      });
                                                    } else {
                                                      print(
                                                          ' not exists we are here');
                                                      setState(() {
                                                        selectedAddOns.add(AddOnModel(
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .id,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .name,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .categoryName,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .price,
                                                            addOnsModelListAddASide[
                                                            index]
                                                                .restaurantId,
                                                            false));
                                                      });
                                                    }

                                                  },),
                                                title: Text( addOnsModelListAddASide[
                                                index]
                                                    .name, style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
                                                trailing: Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: Text('R '+ addOnsModelListAddASide[
                                                  index]
                                                      .price, style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
                                                ),
                                              ),
                                            );


                                            //   Container(
                                            //   height: tileHeight,
                                            //   child: CheckboxListTile(
                                            //     activeColor: darkRedColor,
                                            //     contentPadding:
                                            //         EdgeInsets.zero,
                                            //     secondary: Padding(
                                            //       padding:
                                            //           const EdgeInsets
                                            //               .only(right: 8),
                                            //       child: Text(
                                            //         'R ' +
                                            //             addOnsModelListAddASide[
                                            //                     index]
                                            //                 .price,
                                            //         style: TextStyle(
                                            //             color:
                                            //                 darkRedColor,
                                            //             fontWeight:
                                            //                 FontWeight
                                            //                     .w500,
                                            //             fontSize:
                                            //                 addOnTextSize),
                                            //       ),
                                            //     ),
                                            //     title: Text(
                                            //         addOnsModelListAddASide[
                                            //                 index]
                                            //             .name),
                                            //     value:
                                            //         addOnsModelListAddASide[
                                            //                 index]
                                            //             .selected,
                                            //     onChanged:
                                            //         (bool? newValue) {
                                            //       setState(() {
                                            //         addOnsModelListAddASide[
                                            //                     index]
                                            //                 .selected =
                                            //             newValue!;
                                            //       });
                                            //
                                            //       if (selectedAddOns.any(
                                            //           (model1) =>
                                            //               model1.name ==
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .name)) {
                                            //         print(
                                            //             'exists we are here');
                                            //         setState(() {
                                            //           selectedAddOns.removeWhere(
                                            //               (element) =>
                                            //                   element
                                            //                       .name ==
                                            //                   addOnsModelListAddASide[
                                            //                           index]
                                            //                       .name);
                                            //           selectedAddOns.add(AddOnModel(
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .id,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .name,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .categoryName,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .price,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .restaurantId,
                                            //               false));
                                            //         });
                                            //       } else {
                                            //         print(
                                            //             ' not exists we are here');
                                            //         setState(() {
                                            //           selectedAddOns.add(AddOnModel(
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .id,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .name,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .categoryName,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .price,
                                            //               addOnsModelListAddASide[
                                            //                       index]
                                            //                   .restaurantId,
                                            //               false));
                                            //         });
                                            //       }
                                            //     },
                                            //   ),
                                            // );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),


                            ],
                          )
                        : Container(),
            SizedBox(
              height: 10,
            ),
            // Column(children: [
            //   showFullChicken || showChickenPiece ?
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Choose cut', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
            //   ) : Container(),
            //   // SizedBox(
            //   //   height: 10,
            //   // ),
            //   showFullChicken ?
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10,),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: FullChickenOptions.noCut,
            //               groupValue: fullChickenOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (FullChickenOptions? value) {
            //                 setState(() {
            //                   fullChickenOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('No cut', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500, fontSize: addOnTextSize),),
            //             //trailing:
            //
            //             // Checkbox(value: noCut,
            //             //   activeColor: darkRedColor
            //             //     ,
            //             //   onChanged: (bool? value) {
            //             //   setState(() {
            //             //     noCut = value!;
            //             //   });
            //             //
            //             // },),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: FullChickenOptions.Cut2,
            //               groupValue: fullChickenOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (FullChickenOptions? value) {
            //                 setState(() {
            //                   fullChickenOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Cut into 2', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Checkbox(value: noCut2, onChanged: (bool? value) {
            //             //   setState(() {
            //             //     noCut2 = value!;
            //             //   });
            //             // },),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: FullChickenOptions.Cut4,
            //               groupValue: fullChickenOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (FullChickenOptions? value) {
            //                 setState(() {
            //                   fullChickenOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Cut into 4', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Checkbox(value: noCut4, onChanged: (bool? value) {
            //             //   setState(() {
            //             //     noCut4 = value!;
            //             //   });
            //             // },
            //             // ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: FullChickenOptions.Cut8,
            //               groupValue: fullChickenOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (FullChickenOptions? value) {
            //                 setState(() {
            //                   fullChickenOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Cut into 8', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Checkbox(value: noCut8, onChanged: (bool? value) {
            //             //   setState(() {
            //             //     noCut8 = value!;
            //             //   });
            //             // },),
            //           ),
            //         ),
            //         SizedBox(height: 20,)
            //       ],),
            //     ),
            //   ) : Container(),
            //   showChickenPiece ?
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: ChickenPieceOptions.leg,
            //               groupValue: chickenPieceOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ChickenPieceOptions? value) {
            //                 setState(() {
            //                   chickenPieceOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Leg Piece', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: ChickenPieceOptions.breast,
            //               groupValue: chickenPieceOptions,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ChickenPieceOptions? value) {
            //                 setState(() {
            //                   chickenPieceOptions = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Breast piece', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Checkbox(value: breastPieace,
            //             //     activeColor: darkRedColor,
            //             //   onChanged: (bool? value) {
            //             //   setState(() {
            //             //     breastPieace = value!;
            //             //   });
            //             // },),
            //           ),
            //         ),
            //         SizedBox(height: 20,),
            //       ],),
            //     ),
            //   ) : Container(),
            //   SizedBox(
            //     height: 10,
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Chips', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: Chips.small,
            //               groupValue: chips,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Chips? value) {
            //                 setState(() {
            //                   chips = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Small', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 11', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: Chips.medium,
            //               groupValue: chips,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Chips? value) {
            //                 setState(() {
            //                   chips = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Medium', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 20', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //
            //
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: Chips.large,
            //               groupValue: chips,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Chips? value) {
            //                 setState(() {
            //                   chips = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Large', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 27', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //
            //
            //           ),
            //         ),
            //         SizedBox(height: 20,)
            //       ],),
            //     ),
            //   ),
            //   SizedBox(
            //     height: 10,
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Drinks', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold,),),
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: Drinks.pepsi,
            //               groupValue: drinks,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Drinks? value) {
            //                 setState(() {
            //                   drinks = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Pepsi 300ml', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing:Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: Drinks.sprite,
            //               groupValue: drinks,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Drinks? value) {
            //                 setState(() {
            //                   drinks = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Sprite 300ml', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         SizedBox(height: 20,)
            //
            //       ],),
            //     ),
            //   ),
            //   SizedBox(
            //     height: 10,
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Sauces', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: Sauces.basting,
            //               groupValue: sauces,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Sauces? value) {
            //                 setState(() {
            //                   sauces = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Basting', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing:Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: Sauces.sprinkle,
            //               groupValue: sauces,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (Sauces? value) {
            //                 setState(() {
            //                   sauces = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Sprinkle Spice', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         SizedBox(height: 20,)
            //
            //       ],),
            //     ),
            //   ),
            //   SizedBox(
            //     height: 10,
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Flavours', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: ProductFlavour.mexicnChili,
            //               groupValue: flavours,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ProductFlavour? value) {
            //                 setState(() {
            //                   flavours = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Mexican Chilli', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing:Text('ZAR 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500),),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:   Radio(
            //               value: ProductFlavour.roastedChili,
            //               groupValue: flavours,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ProductFlavour? value) {
            //                 setState(() {
            //                   flavours = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Roasted Chilli', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Text('ZAR 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500),),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Radio(
            //               value: ProductFlavour.Legend,
            //               groupValue: flavours,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ProductFlavour? value) {
            //                 setState(() {
            //                   flavours = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Legend (Mild with a kick)', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Text('ZAR 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500),),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Radio(
            //               value: ProductFlavour.LemonAndHerb,
            //               groupValue: flavours,
            //               activeColor: darkRedColor,
            //
            //               onChanged: (ProductFlavour? value) {
            //                 setState(() {
            //                   flavours = value!;
            //                   //paymentMethod = 'COD';
            //
            //                 });
            //               },
            //             ),
            //             title: Text('Lemon & herb(Mild but tasty)', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             // trailing: Text('ZAR 5', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500),),
            //           ),
            //         ),
            //         SizedBox(height: 20,)
            //
            //       ],),
            //     ),
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Text(
            //       'Add a side', style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
            //   ),
            //
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           color: lightButtonGreyColor,
            //           borderRadius: BorderRadius.circular(10)
            //       ),
            //       child: Column(children: [
            //
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading: Checkbox(value: roll,
            //               activeColor: darkRedColor
            //               ,
            //               onChanged: (bool? value) {
            //                 setState(() {
            //                   roll = value!;
            //                 });
            //
            //               },),
            //             title: Text('Roll', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing:Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 10', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Checkbox(value: spicyRice,
            //               activeColor: darkRedColor
            //               ,
            //               onChanged: (bool? value) {
            //                 setState(() {
            //                   spicyRice = value!;
            //                 });
            //
            //               },),
            //             title: Text('Spicy rice', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 10', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Checkbox(value: pap,
            //               activeColor: darkRedColor
            //               ,
            //               onChanged: (bool? value) {
            //                 setState(() {
            //                   pap = value!;
            //                 });
            //
            //               },),
            //             title: Text('Pap', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 10', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //         Container(
            //           height: tileHeight,
            //           child: ListTile(
            //             contentPadding: EdgeInsets.zero,
            //             horizontalTitleGap: 0,
            //             minVerticalPadding: 0,
            //             leading:  Checkbox(value: coleslaw,
            //               activeColor: darkRedColor
            //               ,
            //               onChanged: (bool? value) {
            //                 setState(() {
            //                   coleslaw = value!;
            //                 });
            //
            //               },),
            //             title: Text('Coleslaw', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             trailing: Padding(
            //               padding: const EdgeInsets.only(right: 8),
            //               child: Text('R 10', style: TextStyle(color: darkRedColor,fontWeight: FontWeight.w500,fontSize: addOnTextSize),),
            //             ),
            //           ),
            //         ),
            //
            //         SizedBox(height: 20,),
            //       ],),
            //     ),
            //   ),
            //   SizedBox(
            //     height: 10,
            //   ),
            // ],),

            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Special Instructions',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 0),
              child: TextFormField(
                controller: _specialInstructionController,
                maxLines: 5,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: darkGreyTextColor1, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.grey,
                  hintText: "Special Instructions",

                  //make hint text
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),
                  //create lable
                  // labelText: 'Full Name',
                  //lable style
                  // labelStyle: TextStyle(
                  //   color: darkRedColor,
                  //   fontSize: 16,
                  //   fontFamily: "verdana_regular",
                  //   fontWeight: FontWeight.w400,
                  // ),
                ),
              ),
            ),

            SizedBox(
              height: 10,
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
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                            if (quantity <= 0) {
                              var snackBar = SnackBar(
                                content: Text(
                                  'Add Quantity',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                               print(["10","14","16","21"].runtimeType);
                               print(["10","14","16","21"].runtimeType);
                               print(["10","14","16","21"].runtimeType);
                              setState(() {
                                addOns.clear();
                              });

                              if(selectedAddOns.isNotEmpty) {
                                for (int i = 0; i < selectedAddOns.length; i++) {
                                  // print(jsonEncode(selectedAddOns[i].id.toString()));
                                  setState(() {
                                    // addOns.add(jsonEncode(selectedAddOns[i].id.toString()).toString());
                                    addOns.add(int.parse(selectedAddOns[i].id.toString()));
                                  });
                                  // print('Id : ' +
                                  //     selectedAddOns[i].id.toString() +
                                  //     ' Name : ' +
                                  //     selectedAddOns[i].name.toString() +
                                  //     ' Category : ' +
                                  //     selectedAddOns[i].categoryName.toString() +
                                  //     ' Price : ' +
                                  //     selectedAddOns[i].price.toString());

                                  if(selectedAddOns.length-1 == i) {
                                    // for(int i = 0; i < addOns.length; i++) {
                                    //   print('Id addOns : ' + addOns[i].toString());
                                    //   print(addOns.toString());
                                    //   print(addOns.runtimeType);
                                    //   print(addOns.runtimeType);
                                    //   print(addOns.runtimeType);
                                    // }

                                    setState(() {
                                      isLoadingAddCart = true;
                                      cartBody = CartBody(
                                          productId: widget.product.id.toString(),
                                          quantity: quantity.toString(),
                                          addonIds: addOns,
                                        specialInstructions: _specialInstructionController.text.isEmpty ? '' : _specialInstructionController.text.toString()
                                      );
                                    });

                                    addToCart(widget.product.id.toString(), quantity.toString());

                                  }

                                }
                              } else {

                                setState(() {
                                  isLoadingAddCart = true;
                                  cartBody = CartBody(
                                      productId: widget.product.id.toString(),
                                      quantity: quantity.toString(),
                                      addonIds: [],
                                    specialInstructions: _specialInstructionController.text.isEmpty ? '' : _specialInstructionController.text.toString()
                                  );
                                });

                                addToCart(widget.product.id.toString(), quantity.toString());

                              }


                              print(widget.product.id.toString());
                              print(quantity.toString());



                              // if(selectedAddOns.length == addOns.length) {
                              //   setState(() {
                              //     isLoadingAddCart = true;
                              //   });
                              //   addToCart(widget.product.id.toString(), quantity.toString());
                              // }
                              // ["8","13","16","22","17","18"]

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
      ),
    );
  }
}
