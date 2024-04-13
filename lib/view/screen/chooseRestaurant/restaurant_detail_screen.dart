import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RestaurantDetailScreen extends StatefulWidget {
  final String name;
  final String image;
  final String address;
  final String phone;
  final String latitude;
  final String longitude;
  final List<WeekId> weekId;

  const RestaurantDetailScreen({super.key,
    required this.name,
    required this.image,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.weekId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {

  String distance = '';
  String resturantStatus = '';
  bool isLoading = true;

  getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      distance = (Geolocator.distanceBetween(
          prefs.getDouble('lat')!,
          prefs.getDouble('long')!,
          double.parse(widget.latitude.toString()), double.parse(widget.longitude.toString()))/1000).toStringAsFixed(0);
    });



  }


  getRestaurantTime() async {
    print('we are in getRestaurantTime');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("today");
    prefs.remove("closingTime");
    prefs.remove("openingTime");
    var now = DateTime.now();


    if(widget.weekId.isNotEmpty) {

      print(widget.weekId[0].toJson());

      for(int weekIds = 0 ; weekIds < widget.weekId.length ; weekIds++) {

        print(widget.weekId[weekIds].restaurantTimings?.name);

        if(widget.weekId[weekIds].restaurantTimings?.name == "Mon - Sun") {
          print( ' yes Mon - Sun ' );
          print( ' openingTime ${widget.weekId[weekIds].restaurantTimings!.openingTime.toString()} ' );
          print( ' closingTime ${widget.weekId[weekIds].restaurantTimings!.closingTime.toString()} ' );

          prefs.setString('openingTime',widget.weekId[weekIds].restaurantTimings!.openingTime.toString() );
          prefs.setString('today',"Mon - Sun" );
          prefs.setString('closingTime',widget.weekId[weekIds].restaurantTimings!.closingTime.toString() );

        }
        else if(widget.weekId[weekIds].restaurantTimings?.name == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase()) {
          print( ' yes ${DateFormat('EEEE').format(DateTime.now()).toString()} ' );
          print( ' openingTime ${widget.weekId[weekIds].restaurantTimings!.openingTime.toString()} ' );
          print( ' closingTime ${widget.weekId[weekIds].restaurantTimings!.closingTime.toString()} ' );
          prefs.setString('today',widget.weekId[weekIds].restaurantTimings!.name.toString() );
          prefs.setString('openingTime',widget.weekId[weekIds].restaurantTimings!.openingTime.toString() );
          prefs.setString('closingTime',widget.weekId[weekIds].restaurantTimings!.closingTime.toString() );
        }

        if(weekIds == widget.weekId.length-1) {


          if(

          prefs.getString("today") != null &&
              (
                  prefs.getString("today").toString() == "Mon - Sun" || prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString().toLowerCase() || prefs.getString("today").toString() == DateFormat('EEEE').format(DateTime.now()).toString()
              )


          ) {

            if(

            now.isAfter(DateTime(now.year, now.month, now.day,
              int.parse(prefs.getString("openingTime").toString().split(":")[0]),
              int.parse(prefs.getString("openingTime").toString().split(":")[1]),
            ))
                && now.isBefore(
                DateTime(now.year, now.month, now.day,
                  int.parse(prefs.getString("closingTime").toString().split(":")[0]),
                  int.parse(prefs.getString("closingTime").toString().split(":")[1]),

                )

            )

            ) {

              setState(() {
               resturantStatus = "Open Now";
               isLoading = false;
              });






            }
            else {

              setState(() {
                resturantStatus = "Closed";
                isLoading = false;
              });

            }

          }
          else {
            setState(() {
              resturantStatus = "Closed";
              isLoading = false;
            });
          }


        }
      }






    }



  }



  @override
  void initState() {
    // TODO: implement initState
    getRestaurantTime();
    getAddress();
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
          widget.name.toString(),
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
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

      body:
      isLoading ? Center(child: CircularProgressIndicator(
        color: darkRedColor,
        strokeWidth: 1,
      )) :
      SingleChildScrollView(
        //  height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children:  <Widget>[

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
                  height: size.height*0.3,
                  width: size.width,
                  fit: BoxFit.cover,
                  imageUrl:  '${baseUrlMain}image/restaurants/'+widget.image
                      .toString(),
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),

              ),
            ),
            Container(
              width: size.width*0.95,
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: size.width*0.65,
                              child: Text(widget.name.toString(), style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                              , overflow: TextOverflow.ellipsis
                              ),)),

                          SizedBox(
                            width: size.width*0.01,
                          ),

                          Container(
                            width: size.width*0.25,
                            child: Text(resturantStatus.toString(), style: TextStyle(color:
                            resturantStatus == 'Closed' ? Colors.red : Colors.green
                            ,fontSize: 13,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),


                    ],),
                ),
              ],
              ),
            ),
            Container(
              width: size.width,
              child: Padding(
                padding:  EdgeInsets.only(left: 10,top: 10),
                child: Row(
                  children: [

                    Icon(Icons.account_balance_sharp, color: Colors.black,size: 16,),
                    SizedBox(
                      width: 10,
                    ),

                    Container(
                      padding:  EdgeInsets.only(right: 10),
                      width: size.width*0.9,
                      child: Text(
                        widget.address.toString(), style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis),),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Container(



              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets
                        .only(
                        left:
                        10,
                        top: 0,
                        right:
                        8,
                        bottom:
                        20),
                    child: Text(
                      'Distance ',
                      style: TextStyle(
                          color: Colors
                              .black,
                          fontSize:
                          13,
                          fontWeight:
                          FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets
                        .only(
                        left:
                        0,
                        top: 0,
                        right:
                        8,
                        bottom:
                        20),
                    child: Text(
                      '$distance'+ ' Km',
                      style: TextStyle(
                          color: Colors
                              .red,
                          fontSize:
                          13,
                          fontWeight:
                          FontWeight.bold),
                    ),
                  ),

                ],
              ),
            ),
            // SizedBox(
            //   height: size.height*0.02,
            // ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.phone, color: Colors.black,size: 16,),

                  SizedBox(
                    width: 0,
                  ),

                  Padding(
                    padding: const EdgeInsets
                        .only(
                        left:
                        10,
                        top: 0,
                        right:
                        8,
                        bottom:
                        20),
                    child: Text(
                      'Phone : ${widget.phone} ',
                      style: TextStyle(
                          color: Colors
                              .black,
                          fontSize:
                          13,
                          fontWeight:
                          FontWeight.bold),
                    ),
                  ),

                ],
              ),
            ),
            // SizedBox(
            //   height: size.height*0.02,
            // ),
            Container(
              height: size.height*0.2,
              width: size.width*0.9,
              child: ListView.builder(
                  itemCount: widget.weekId.length,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, index ) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Icon(Icons.access_time_filled_outlined, color: Colors.black,size: 16,) ,

                            SizedBox(
                              width: 10,
                            ),

                            Text(
                              widget.weekId[index].restaurantTimings==null ? 'No Timings' :
                              widget.weekId[index].restaurantTimings?.name.toString() == 'tuesday' ? 'Tuesday' :
                              widget.weekId[index].restaurantTimings?.name.toString() == 'monday' ? 'Monday' :
                              widget.weekId[index].restaurantTimings?.name.toString() == 'wednesday' ? 'Wednesday' :
                              widget.weekId[index].restaurantTimings?.name.toString() == 'friday' ? 'Friday' :
                              widget.weekId[index].restaurantTimings?.name.toString() == 'saturday' ? 'Saturday' :
                              widget.weekId[index].restaurantTimings!.name.toString() == 'sunday' ? 'Sunday' :
                              widget.weekId[index].restaurantTimings!.name.toString()

                            , style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: Colors.black,overflow: TextOverflow.ellipsis),),
                            widget.weekId[index].restaurantTimings==null ? SizedBox() : Text(

                              ' : ' + widget.weekId[index].restaurantTimings!.openingTime.toString()
                              + ' - ' + widget.weekId[index].restaurantTimings!.closingTime.toString()

                              , style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,color: Colors.black,overflow: TextOverflow.ellipsis),),
                          ],
                        ),
                      ),
                    );

              }),
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
