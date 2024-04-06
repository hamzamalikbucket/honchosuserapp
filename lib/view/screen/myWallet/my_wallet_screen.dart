import 'dart:convert';

import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/flames_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  String flames = '0';
  List<FlamesModel> flamesList = [];
  bool isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = false;
    });
    getFlames();
    super.initState();
  }
  getFlames() async {
    print('get flames');
    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.MultipartRequest('GET', Uri.parse('${apiBaseUrl}api/flames'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    // final data = json.decode(responseData);
    if (response.statusCode == 200) {

      setState(() {
        flamesList = List<FlamesModel>.from(json.decode(responseData).map((x) => FlamesModel.fromJson(x)));

      });

      if (flamesList.isNotEmpty) {

        for(int i=0; i<flamesList.length; i++) {
          if (flamesList[i].status == 'Active') {
            setState(() {
              flames = flamesList[i].flames!;
              // flameId = flamesList[i].id!.toString();
              isLoading = false;
            });
          }
        }



        // else {
        //   setState(() {
        //     flames = '0';
        //     flameLoading = false;
        //   });
        // }
        // print(await response.stream.bytesToString());
      } else {
        setState(() {
          flames = '0';
          isLoading = false;
        });
      }



      // print(await response.stream.bytesToString());
    }
    else if (response.statusCode == 302) {
      setState(() {
        isLoading = false;
        flames = '0';
      });
      print('get flames 302');
      print('get flames else');

      // print(await response.stream.bytesToString());
    }
    else {
      setState(() {
        isLoading = false;
        flames = '0';
      });
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
          'My Wallet',
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

      body:
      isLoading ? Center(child: CircularProgressIndicator(
        color: darkRedColor,
        strokeWidth: 1,
      )) :

      flames == '0'  ? SingleChildScrollView(
        child: Column(children: [

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // height: size.height*0.3,
              width: size.width*0.95,
              decoration: BoxDecoration(
                border: Border.all(color: darkRedColor,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(children: [
                SizedBox(
                  height: size.height*0.02,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0,),
                  child: Container(
                    width: size.width*0.9,

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        //  height: size.height*0.1,
                        width: size.width*0.6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: size.height*0.02,
                              ),
                              Container(
                                width: size.width*0.9,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Container(
                                        width: size.width*0.4,
                                        child: Row(children: [
                                          Container(

                                            child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                              height: 35,
                                              width: 35,
                                            ),
                                          ),

                                          Container(

                                            child: Text('   0 Flames',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Color(0xFF585858), fontSize: 15,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                          ),
                                        ],),
                                      ),




                                    ],),
                                ),
                              ),
                              SizedBox(
                                height: size.height*0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height*0.02,
                ),

              ],),
            ),
          ),

        ],),
      ) :
      SingleChildScrollView(
        child: Column(children: [

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // height: size.height*0.3,
              width: size.width*0.95,
              decoration: BoxDecoration(
                // boxShadow: [
                //   BoxShadow(
                //       color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                // ],
                border: Border.all(color: darkRedColor,width: 1),
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   stops: [0.0, 1.0],
                //   colors: [
                //     darkRedColor,
                //     lightRedColor,
                //   ],
                // ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(children: [
                SizedBox(
                  height: size.height*0.02,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0,),
                  child: Container(
                    width: size.width*0.9,

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        //  height: size.height*0.1,
                        width: size.width*0.6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: size.height*0.02,
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(left: 0,right: 0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text('My Wallet',
                              //         style: TextStyle(
                              //             fontFamily: 'Montserrat',
                              //             color: Colors.black,
                              //             fontSize: 18,fontWeight: FontWeight.w600),),
                              //
                              //     ],),
                              // ),



                              Container(
                                width: size.width*0.9,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Container(
                                        width: size.width*0.4,
                                        child: Row(children: [
                                          Container(

                                            child: Image.asset('assets/images/flame.png', fit: BoxFit.scaleDown,
                                              height: 35,
                                              width: 35,
                                            ),
                                          ),

                                          Container(

                                            child: Text('   $flames Flames',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Color(0xFF585858), fontSize: 15,fontWeight: FontWeight.w600),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                          ),
                                        ],),
                                      ),




                                    ],),
                                ),
                              ),
                              SizedBox(
                                height: size.height*0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height*0.02,
                ),

              ],),
            ),
          ),

        ],),
      ),

    );
  }
}
