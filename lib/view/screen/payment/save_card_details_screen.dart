import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_validator/card_number.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/view/screen/payment/payment_method_screen.dart';
import 'package:figma_new_project/view/screen/payment/simple_webview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SaveCardDetailsScreen extends StatefulWidget {
  const SaveCardDetailsScreen({Key? key}) : super(key: key);

  @override
  _SaveCardDetailsScreenState createState() => _SaveCardDetailsScreenState();
}

class _SaveCardDetailsScreenState extends State<SaveCardDetailsScreen> {

  var darkRedColor =  Color(0xff000000);
  bool isLoading = false;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardCVCController = TextEditingController();
  final TextEditingController _cardEdateController = TextEditingController();

  String total = '0';

  String isAvailable = '';
  String restaurantName = '';
  String restaurantImage = '';
  String Address = '';


  getPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null) {
      FirebaseFirestore.instance.collection('UserCardDetais').doc(prefs.getString('userId')).get().then((value) {

        if(value.exists) {

          setState(() {
            isAvailable = 'yes';
            _cardHolderNameController.text = value['name'];
            _cardNumberController.text = value['number'];
            _cardCVCController.text = value['cvc'];
            _cardEdateController.text = value['date'];
          });
        } else {
          setState(() {
            isAvailable = 'no';
          });
        }


      });
    }
  }





  // makePayment() async {
  //
  //   print('we are in makepayment');
  //   var headers = {
  //     'Cookie': 'pf_bid=1.9b70085110adfe5c.1687245602'
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse('https://sandbox.payfast.co.za/eng/process'));
  //   request.fields.addAll({
  //     'merchant_id': '10029889',
  //     'merchant_key': 'w2vjpg42fc7a6',
  //     'amount': '12',
  //     'item_name': 'test'
  //   });
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   }
  //   else {
  //     print(response.reasonPhrase);
  //   }
  // }


  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isAvailable = '';
    });
    getPaymentData();
    super.initState();
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
          'Payment Method',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoardScreen(index:2)));
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
        child: Column(children: [

          SizedBox(
            height: size.height*0.015,
          ),



          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: lightButtonGreyColor,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  SizedBox(
                    height: size.height*0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardHolderNameController,
                      keyboardType: TextInputType.name,
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

                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Image.asset('assets/images/credit.png', fit: BoxFit.scaleDown,
                            height: 30,
                            width: 50,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "Card Holder Name",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Holder Name',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
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
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "Card Number",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Number',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                    child: TextFormField(
                      controller: _cardCVCController,
                      keyboardType: TextInputType.number,
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
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "CVC",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'CVC',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: _cardEdateController,
                      keyboardType: TextInputType.datetime,
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
                        //add prefix icon

                        // errorText: "Error",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.white,
                        hintText: "DD/MM/YY",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),

                        //create lable
                        labelText: 'Card Expiry Date',
                        //lable style
                        labelStyle: TextStyle(
                          color: darkRedColor,
                          fontSize: 16,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height*0.02,
                  ),

                ],),
              )

              ,),
          ),




          SizedBox(
            height: size.height*0.05,
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
                    Color(0xffBB1B20),
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

                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();



                    CreditCardValidator _ccValidator = CreditCardValidator();
                    if(_ccValidator.validateCCNum(_cardNumberController.text) == false) {
                      var snackBar = SnackBar(content: Text('Invalid Card Number'
                        ,style: TextStyle(color: Colors.white),),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else if(_ccValidator.validateCVV(_cardCVCController.text,CreditCardValidator.unknownCardType) == false) {
                      var snackBar = SnackBar(content: Text('Invalid CVV'
                        ,style: TextStyle(color: Colors.white),),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else if(_ccValidator.validateExpDate(_cardEdateController.text) == false) {
                      var snackBar = SnackBar(content: Text('Invalid Expiry Date'
                        ,style: TextStyle(color: Colors.white),),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    else {
                      if(_cardHolderNameController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card holder name is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      }
                      else if(_cardNumberController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card number is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);


                      }
                      else if(_cardCVCController.text.isEmpty) {

                        var snackBar = SnackBar(content: Text('Card cvc is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      }
                      else if(_cardEdateController.text.isEmpty) {
                        var snackBar = SnackBar(content: Text('Card expire date is required'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else {


                        setState(() {
                          isLoading = true;
                        });
                        if(prefs.getString('userId') != null) {
                          FirebaseFirestore.instance.collection('UserCardDetais').doc(prefs.getString('userId')).set({
                            'name':_cardHolderNameController.text,
                            'number':_cardNumberController.text,
                            'cvc':_cardCVCController.text,
                            'date':_cardEdateController.text,
                            'uid':prefs.getString('userId'),
                          }).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context).pop();
                          });
                        }













                      }
                    }



                  }, child: Text(
                  isAvailable == 'yes' ?
                  'Update' : 'Save', style: buttonStyle)),
            ),
          ),
          SizedBox(
            height: size.height*0.02,
          ),


        ],),
      ),

    );
  }
}
