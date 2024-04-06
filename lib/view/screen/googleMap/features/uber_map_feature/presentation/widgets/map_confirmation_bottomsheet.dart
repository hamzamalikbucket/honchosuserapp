import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/presentation/getx/uber_map_controller.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'package:lottie/lottie.dart' as lottie;
import 'package:figma_new_project/injection_container.dart' as di;

class MapConfirmationBottomSheet extends StatelessWidget {
  const MapConfirmationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final UberMapController _uberMapController =
        Get.put(di.sl<UberMapController>());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => Column(
          children: [
            SizedBox(
              height: size.height*0.025,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Text(
                      _uberMapController.sourcePlaceName.value.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const FaIcon(FontAwesomeIcons.longArrowAltRight),
                  Flexible(
                    child: Text(
                      _uberMapController.destinationPlaceName.value.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      //maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Text(
            //       _uberMapController.uberMapDirectionData[0].distanceText
            //           .toString(),
            //       style: const TextStyle(
            //           fontWeight: FontWeight.w300, fontSize: 15),
            //     ),
            //     Text(
            //       _uberMapController.uberMapDirectionData[0].durationText
            //           .toString(),
            //       style: const TextStyle(
            //           fontWeight: FontWeight.w300, fontSize: 15),
            //     ),
            //   ],
            // ),
             SizedBox(
              height: size.height*0.05,
            ),

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
                      Colors.black,
                      Colors.black,
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
                    }, child: Text('Confirm', style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.bold))),
              ),
            ),

            // Expanded(
            //   child: _uberMapController.reqAccepted.value
            //       ? lottie.Lottie.network(
            //       'https://assets9.lottiefiles.com/packages/lf20_ubozqrue.json')
            //       : _uberMapController.findDriverLoading.value
            //           ? lottie.Lottie.network(
            //               'https://assets9.lottiefiles.com/packages/lf20_ubozqrue.json')
            //           : ListView.builder(
            //               //shrinkWrap: true,
            //               itemCount: _uberMapController
            //                   .availableDriversList.value.length, //2
            //               itemBuilder: (context, index) {
            //                 return Container(
            //                   margin: const EdgeInsets.all(15),
            //                   color: Colors.grey[100],
            //                   child: ListTile(
            //                     contentPadding: const EdgeInsets.symmetric(
            //                         horizontal: 20.0, vertical: 10.0),
            //                     leading: Container(
            //                         width: 85,
            //                         padding: const EdgeInsets.only(right: 12.0),
            //                         decoration: const BoxDecoration(
            //                             border: Border(
            //                                 right: BorderSide(
            //                                     width: 1.0,
            //                                     color: Colors.black38))),
            //                         child: _uberMapController
            //                                     .availableDriversList
            //                                     .value[index]
            //                                     .vehicle!
            //                                     .path
            //                                     .split('/')
            //                                     .first ==
            //                                 'cars'
            //                             ? Image.asset("assets/car.png")
            //                             : _uberMapController
            //                                         .availableDriversList
            //                                         .value[index]
            //                                         .vehicle!
            //                                         .path
            //                                         .split('/')
            //                                         .first ==
            //                                     'auto'
            //                                 ? Image.asset(
            //                                     'assets/auto.png',
            //                                   )
            //                                 : Image.asset(
            //                                     'assets/bike.png',
            //                                   )),
            //                     title: Text(
            //                       _uberMapController
            //                           .availableDriversList.value[index].name
            //                           .toString(),
            //                       // style: const TextStyle(
            //                       //     color: Colors.black, fontWeight: FontWeight.bold),
            //                     ),
            //                     subtitle: _uberMapController
            //                                 .availableDriversList
            //                                 .value[index]
            //                                 .vehicle!
            //                                 .path
            //                                 .split('/')
            //                                 .first ==
            //                             'cars'
            //                         ? Text('₹ ' +
            //                             _uberMapController.carRent.value
            //                                 .toString())
            //                         : _uberMapController.availableDriversList
            //                                     .value[index].vehicle!.path
            //                                     .split('/')
            //                                     .first ==
            //                                 'auto'
            //                             ? Text('₹ ' +
            //                                 _uberMapController.autoRent.value
            //                                     .toString())
            //                             : Text('₹ ' +
            //                                 _uberMapController.bikeRent.value
            //                                     .toString()),
            //                     trailing: Text(_uberMapController
            //                             .availableDriversList
            //                             .value[index]
            //                             .overall_rating
            //                             .toString() +
            //                         " ⭐"),
            //                     onTap: () {
            //                       _uberMapController.generateTrip(
            //                           _uberMapController
            //                               .availableDriversList.value[index],
            //                           index);
            //                     },
            //                   ),
            //                 );
            //               }),
            // ),
          ],
        ),
      ),
    );
  }
}
