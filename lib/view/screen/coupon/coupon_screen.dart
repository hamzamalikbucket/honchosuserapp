import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:flutter/material.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final TextEditingController _couponController = TextEditingController();
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
          'Coupon',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
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


      body: Column(children: [

        SizedBox(
          height: size.height*0.05,
        ),


        Container(
          margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
          child: TextFormField(
            controller: _couponController,
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
                BorderSide(color: darkGreyTextColor, width: 2.0,),
                borderRadius: BorderRadius.circular(10.0),
              ),
              fillColor: Colors.grey,
              hintText: "",

              //make hint text
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: "verdana_regular",
                fontWeight: FontWeight.w400,
              ),

              //create lable
              labelText: 'Enter Code',
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
                  //
                }, child: Text('Apply', style: buttonStyle)),
          ),
        ),
        SizedBox(
          height: size.height*0.1,
        ),

      ],),

    );
  }
}
