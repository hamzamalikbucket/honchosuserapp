import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/previous_address_model.dart';
import 'package:figma_new_project/view/screen/chooseRestaurant/choose_restaurant_screen.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/presentation/getx/uber_map_controller.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/presentation/widgets/map_confirmation_bottomsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:figma_new_project/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

class MapWithSourceDestinationField extends StatefulWidget {
  // final CameraPosition defaultCameraPosition;
  // final CameraPosition newCameraPosition;
  // final String currentAddress;

  const MapWithSourceDestinationField(
      {
        // required this.newCameraPosition,
        // required this.defaultCameraPosition,
        // required this.currentAddress,
        Key? key})
      : super(key: key);

  @override
  _MapWithSourceDestinationFieldState createState() =>
      _MapWithSourceDestinationFieldState();
}

class _MapWithSourceDestinationFieldState
    extends State<MapWithSourceDestinationField> {
  //final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController sourcePlaceController = TextEditingController();
  final destinationController = TextEditingController();
  String addressType = '', address = '', selected = '',changeLocation = '', selectedIndex = '',selectedIndex2 = '';
  double lat = -26.202045;
  double long = 28.048702;
  double lat1 = 0.0, long1 = 0.0;
  List<PreviousAddressModel> _previousAddress = [];


  final UberMapController _uberMapController =
  Get.put(di.sl<UberMapController>());

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sourcePlaceController.dispose();
    destinationController.dispose();
    super.dispose();
  }



  getPreviousAddress() async {
    setState(() {
      _previousAddress.clear();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore.instance.collection('UserAddress').where('uid',isEqualTo: prefs.getString('userId')).get().then((value) {

      for(int i=0; i<value.docs.length ;i++) {

        if(_previousAddress.any((element) => element.address == value.docs[i]['address'])) {

          print('already their');

        } else {
          setState(() {
            _previousAddress.add(PreviousAddressModel(
                lat: value.docs[i]['lat'],
                long: value.docs[i]['long'],
                address: value.docs[i]['address']));
            changeLocation = 'yes';
          });
        }





      }

      print(_previousAddress.length.toString() + ' Reve length');

    });

  }


  @override
  void initState() {
    // TODO: implement initState
    getPreviousAddress();
    //getAddress();
    setState(() {
      selectedIndex = '';
      selectedIndex2 = '';
      selected = '';
      changeLocation = '';
      // _uberMapController.sourcePlaceName.value = "";
      // sourcePlaceController.clear();
    });

    super.initState();
  }

  // getAddress() async {
  //   Future.delayed(Duration.zero, () async {
  //     WidgetsBinding.instance.addPostFrameCallback((_) async {
  //       await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //           .then((Position position) async {
  //
  //         await geocoding.placemarkFromCoordinates(
  //             position.latitude, position.longitude)
  //             .then((List<geocoding.Placemark> placemarks) {
  //           geocoding.Placemark place = placemarks[0];
  //           setState(() {
  //             address = '${place.street}, ${place.subLocality},${place.subAdministrativeArea} ${place.postalCode}';
  //           });
  //
  //
  //           setState(() {
  //             addressType = '';
  //             sourcePlaceController.text = address;
  //             sourcePlaceController..text = address;
  //             _uberMapController.sourceLatitude.value = position.latitude;
  //             _uberMapController.sourceLongitude.value = position.longitude;
  //             _uberMapController.sourcePlaceName.value = address;
  //             destinationController.clear();
  //             // _uberMapController.
  //             _uberMapController.polylineCoordinates.clear();
  //             _uberMapController.destinationPlaceName.value = "";
  //             _uberMapController.destinationLatitude.value = 0.0;
  //             _uberMapController.destinationLongitude.value = 0.0;
  //             _uberMapController.polylineCoordinatesforacptDriver.clear();
  //             _uberMapController.markers.clear();
  //           });
  //
  //           _uberMapController
  //               .setPlaceAndGetLocationDeatailsAndDirection(
  //               sourcePlace: address,
  //               destinationPlace: "");
  //
  //
  //
  //         }).catchError((e) {
  //           debugPrint(e);
  //         });
  //
  //
  //       });
  //     });
  //
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(_uberMapController.sourceLatitude.value.toString() + ' Lat address');
    print(_uberMapController.sourceLongitude.value.toString() + ' Long address');
    return Scaffold(
      backgroundColor: Colors.white ,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [


                Obx(
                      () => Visibility(
                    visible: !_uberMapController.isPoliLineDraw.value,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8,top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration:  BoxDecoration(
                                  shape: BoxShape.circle, color: Color(0xffDDDDDF).withOpacity(0.5),),
                              child: GestureDetector(
                                onTap: () {
                                  // _uberMapController.subscription.cancel();



                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));

                                },
                                child: const FaIcon(
                                  FontAwesomeIcons.arrowLeft,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0,top: 8),
                            child: Container(
                              width: size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: size.width*0.9,
                                    // margin: const EdgeInsets.symmetric(horizontal: 15),
                                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration:  BoxDecoration(
                                       // border: Border.all(color: Colors.black,width: 0.5),
                                        color: Color(0xffDDDDDF).withOpacity(0.5),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(0))),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      textAlign: TextAlign.left,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(fontSize: 12),
                                      onChanged: (val) {

                                        _uberMapController.getPredictions(
                                            val, 'source');

                                        if(sourcePlaceController.text.isEmpty) {
                                          setState(() {
                                            selected = '';
                                            changeLocation = 'yes';
                                           // _uberMapController.sourcePlaceName.value = "";
                                           // sourcePlaceController.clear();
                                          });
                                        }
                                        else {
                                          if( changeLocation == 'yes') {
                                            setState(() {
                                              changeLocation = '';
                                            });
                                          }
                                        }

                                      },
                                      decoration:  InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 8),
                                          border: InputBorder.none,
                                          suffixIcon: IconButton(onPressed: () {
                                            setState(() {
                                              changeLocation = 'yes';
                                              sourcePlaceController.clear();
                                              _uberMapController.sourcePlaceName.value = "";
                                              selected = "";

                                            });
                                          }, icon: Icon(Icons.clear,color: Colors.black,)),
                                          hintText: "Where to?"),
                                      controller: sourcePlaceController..text =
                                            _uberMapController.sourcePlaceName.value,
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 8),
                                  //   child: GestureDetector(
                                  //     onTap: () {
                                  //       setState(() {
                                  //         addressType = "source";
                                  //         sourcePlaceController.clear();
                                  //       });
                                  //     },
                                  //     child: Container(
                                  //       width: size.width*0.25,
                                  //       child: Text("Choose current location on map", style: TextStyle(
                                  //
                                  //           color:
                                  //           addressType == "source" ? Colors.green :
                                  //           Colors.black, fontSize: 9, fontWeight: FontWeight.w600),),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),


                          const SizedBox(
                            height: 10,
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 10),
                          //   child: Container(
                          //     width: size.width,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //
                          //       children: [
                          //         Container(
                          //           width: size.width*0.65,
                          //           // margin:
                          //           // const EdgeInsets.symmetric(horizontal: 15),
                          //           // padding:
                          //           // const EdgeInsets.symmetric(horizontal: 10),
                          //           decoration:  BoxDecoration(
                          //               color: Color(0xffDDDDDF).withOpacity(0.5),
                          //               border: Border.all(color: Colors.black,width: 0.5),
                          //               borderRadius:
                          //               BorderRadius.all(Radius.circular(12))),
                          //           child: TextField(
                          //             style: TextStyle(fontSize: 12),
                          //             onChanged: (val) {
                          //               _uberMapController.getPredictions(
                          //                   val, 'destination');
                          //             },
                          //
                          //             decoration: const InputDecoration(
                          //               hintText: "Where to?",
                          //               contentPadding: EdgeInsets.only(left: 8),
                          //
                          //               border: InputBorder.none,
                          //             ),
                          //             controller: destinationController
                          //               ..text = _uberMapController
                          //                   .destinationPlaceName.value,
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(left: 8),
                          //           child: GestureDetector(
                          //             onTap: () {
                          //               setState(() {
                          //                 addressType = "destination";
                          //                 destinationController.clear();
                          //               });
                          //             },
                          //             child: Container(
                          //               width: size.width*0.25,
                          //               child: Text(
                          //
                          //                 "Choose destination on map", style: TextStyle(
                          //
                          //                   color:
                          //                   addressType == "destination" ? Colors.green :
                          //                   Colors.black, fontSize: 9, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),


                Container(
                  //color: Color(0xffDDDDDF).withOpacity(0.5),
                  child:Column(children: [
                    Container(
                      height: 10,
                      color: Color(0xffDDDDDF).withOpacity(0.5),
                      width: size.width,
                    ),

                   ListTile(

                     tileColor: Colors.white,
                     leading: Icon(Icons.star, color: Colors.black,size: 20,),
                     horizontalTitleGap: 0,
                     title: Text('Saved places', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600,fontSize: 15),),
                   ),

                    Container(
                      height: 10,
                      color: Color(0xffDDDDDF).withOpacity(0.5),
                      width: size.width,
                    ),

                ],)
                  ,),

                //if (_uberMapController.uberMapPredictionData.isNotEmpty)
                changeLocation == 'yes' && _previousAddress.isEmpty ? Center(child: Text('Sorry no previous selected addresses found')) :
                changeLocation == 'yes' && _previousAddress.isNotEmpty ? Expanded(
                  child: Container(
                    // color: Colors.white,
                    child:


                    ListView.builder(
                      //shrinkWrap: true,
                        itemCount: _previousAddress.length,
                        itemBuilder: (context, index) {
                          // print('index $index and ${_uberMapController
                          //     .uberMapPredictionData[index]
                          //     .secondaryText
                          //     .toString()}');
                          return Container(
                            // width: size.width*0.9,
                            child: Column(

                              children: [
                                Container(
                                  // width: size.width*0.9,
                                  child: ListTile(
                                    splashColor: Colors.grey,
                                    //titleAlignment: ListTileTitleAlignment.center,
                                    hoverColor: Colors.grey,
                                    tileColor: selectedIndex == index.toString() ? lightGreenColor : Colors.white ,
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      setState(() {
                                        selectedIndex = index.toString();
                                        address = _previousAddress[index].address.toString();
                                        lat1 = _previousAddress[index].lat;
                                        long1 = _previousAddress[index].long;
                                        _uberMapController.sourceLongitude.value = _previousAddress[index].long;
                                        _uberMapController.sourceLatitude.value = _previousAddress[index].lat;
                                        _uberMapController.sourcePlaceName.value = _previousAddress[index].address.toString();
                                        selected = 'done';
                                      });

                                      print(address.toString() + 'userAddress');


                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(
                                      //       status: 'delete',
                                      //       long: result.latLng!.longitude,lat: result.latLng!.latitude,)));

                                      _uberMapController
                                          .setPlaceAndGetLocationDeatailsAndDirection(
                                          sourcePlace: address.toString(),
                                          destinationPlace: "");
                                    },
                                    horizontalTitleGap: 0,


                                    leading:  Icon(
                                      Icons.location_on,color: Colors.black,size: 20,),
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(_previousAddress[index].address.toString(), style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 14),),
                                    ),
                                    subtitle: Text(''),
                                    // trailing: const Icon(Icons.check),
                                  ),
                                ),
                                Container(
                                  color: Colors.grey,
                                  height: 0.5,
                                  width: size.width*0.9,
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ) : Container(),

                changeLocation == '' ? Expanded(
                  child: Obx(
                        () => Visibility(
                      visible:
                      _uberMapController.uberMapPredictionData.isNotEmpty,
                      child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                          //shrinkWrap: true,
                            itemCount: _uberMapController
                                .uberMapPredictionData.length,
                            itemBuilder: (context, index) {
                              // print('index $index and ${_uberMapController
                              //     .uberMapPredictionData[index]
                              //     .secondaryText
                              //     .toString()}');
                              return
                                _uberMapController
                                    .uberMapPredictionData[index]
                                    .secondaryText
                                    .toString() == 'null' ? SizedBox() :
                                Column(
                                  children: [
                                    ListTile(
                                      tileColor:   selectedIndex2 == index.toString() ? lightGreenColor : Colors.transparent ,
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();


                                      FocusScope.of(context).unfocus();
                                      if (_uberMapController
                                          .predictionListType.value ==
                                          'source') {
                                        setState(() {
                                          address = _uberMapController.uberMapPredictionData[index].mainText.toString() + ' ' + _uberMapController.uberMapPredictionData[index].secondaryText.toString();
                                        });
                                        print('we are here');
                                        print('$address we are here');
                                        print(_uberMapController
                                            .uberMapPredictionData[index]
                                            .mainText
                                            .toString() + ' lat long');
                                        _uberMapController
                                            .setPlaceAndGetLocationDeatailsAndDirection(
                                            sourcePlace:
                                            _uberMapController.uberMapPredictionData[index].mainText.toString() + ' ' + _uberMapController.uberMapPredictionData[index].secondaryText.toString(),
                                            destinationPlace: "");
                                        // print(_uberMapController.uberMapPredictionData[index].mainText.toString());
                                        // print(_uberMapController.uberMapPredictionData[index].secondaryText.toString());
                                        // print(_uberMapController.uberMapPredictionData[index].secondaryText.toString());
                                        // print(_uberMapController.sourceLatitude.toString());
                                        // print(_uberMapController.sourceLongitude.toString());
                                        // print(_uberMapController.sourcePlaceName.toString());
                                        setState(() {
                                          selectedIndex2 = index.toString();
                                         // address = _uberMapController.uberMapPredictionData[index].mainText.toString() + ' ' + _uberMapController.uberMapPredictionData[index].secondaryText.toString();
                                         //  lat1 = _uberMapController.sourceLatitude.value;
                                         //  long1 = _uberMapController.sourceLongitude.value;
                                          selected = 'done';
                                        });
                                        //
                                        // print(address.toString() + 'userAddress');
                                        // print(_uberMapController.sourceLatitude.value.toString() + ' Lat');
                                        // print(_uberMapController.sourceLongitude.value.toString() + ' Long');
                                        //
                                        // prefs.setString('userAddress', address.toString());
                                        // prefs.setDouble('lat', _uberMapController.sourceLatitude.value);
                                        // prefs.setDouble('long',_uberMapController.sourceLongitude.value);
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(
                                        //       status: 'delete',
                                        //       long: result.latLng!.longitude,lat: result.latLng!.latitude,)));


                                      }
                                      else {
                                        _uberMapController
                                            .setPlaceAndGetLocationDeatailsAndDirection(
                                            sourcePlace: "",
                                            destinationPlace:
                                            _uberMapController
                                                .uberMapPredictionData[
                                            index]
                                                .mainText
                                                .toString());
                                      }
                                      // print('index $index and ${_uberMapController
                                      //     .uberMapPredictionData[index]
                                      //     .secondaryText
                                      //     .toString()}');

                                    },
                                    horizontalTitleGap: 0,

                                    leading:  Icon(
                                      Icons.location_on,color: Colors.black,size: 20,),
                                    title: Text(_uberMapController
                                        .uberMapPredictionData[index].mainText
                                        .toString()


                                      , style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                                    subtitle: Text(_uberMapController
                                        .uberMapPredictionData[index]
                                        .secondaryText
                                        .toString()),
                                    // trailing: const Icon(Icons.check),
                              ),
                                    Container(
                                      color: Colors.grey,
                                      height: 0.5,
                                      width: size.width*0.8,
                                    ),
                                  ],
                                );
                            }),
                      ),
                    ),
                  ),
                ) : Container(),

                selected == 'done' ?
                Container(
                  width: size.width*0.9,
                  // height: size.height*0.06,
                  decoration: BoxDecoration(
                    color: lightButtonGreyColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              width: size.width*0.9,
                              child: Text('Address', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 16),)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: size.width*0.9,
                            child: Text(address.toString()
                              , style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500, fontSize: 16),),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              print(address.toString() + 'userAddress');
                              prefs.setString('userAddress', address.toString());
                              // prefs.setDouble('lat', lat1);
                              // prefs.setDouble('long',long1);
                              // prefs.setDouble('lat', _uberMapController.sourceLatitude.value);
                              // prefs.setDouble('long',_uberMapController.sourceLongitude.value);

                              if (prefs.getDouble('long') != null && prefs.getDouble('lat') != null) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(
                                      status: 'delete',
                                      long:  prefs.getDouble('long')! ,lat: prefs.getDouble('lat')!,)));
                              }




                            },
                            child: Container(
                                width: size.width*0.9,
                                height: size.height*0.06,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),

                                ),
                                child: Center(child: Text('Confirm Address', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16),))),
                          ),
                        ),
                      ],
                    ),
                  ),) : Container(),

              ],
            ),


            Visibility(
              visible: _uberMapController.isDriverLoading.value,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 15),
                child: Positioned(
                  //bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          color: Colors.black,
                        ),
                        Text(
                          "  Loading Rides....",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
