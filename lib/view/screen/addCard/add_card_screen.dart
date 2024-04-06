import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();


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
          'Adding Card',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold
          , fontFamily: 'Montserrat',
          ),
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

      body: SingleChildScrollView(
        child: Column(children: [

          SizedBox(
            height: size.height*0.05,
          ),


          Container(
            margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
            child: TextFormField(
              controller: _nameController,
              style: TextStyle(
                fontFamily: 'Montserrat',
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
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                  fontSize: 16,

                  fontWeight: FontWeight.w400,
                ),

                //create lable
                labelText: 'Name on card',
                //lable style
                labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: darkRedColor,
                  fontSize: 16,

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
            child: TextFormField(
              controller: _emailAddressController,
              style: TextStyle(
                fontFamily: 'Montserrat',
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
                fillColor: Colors.grey,
                hintText: "xxxx-xxxx-xxxx-xxxx",

                //make hint text
                hintStyle: TextStyle(

                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.asset('assets/images/addCard.png',width: 50,height: 30,fit: BoxFit.scaleDown,),
                ),
                //create lable
                labelText: 'Card Number',
                //lable style
                labelStyle: TextStyle(
                  color: darkRedColor,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
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
            child: TextFormField(
              controller: _phoneController,
              style: TextStyle(
                fontFamily: 'Montserrat',
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
                fillColor: Colors.grey,
                hintText: "mm/yy",

                //make hint text
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                //create lable
                labelText: 'Expiration Date',
                //lable style
                labelStyle: TextStyle(
                  color: darkRedColor,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
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
            child: TextFormField(
              controller: _passwordController,
              style: TextStyle(
                fontFamily: 'Montserrat',
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
                fillColor: Colors.grey,
                hintText: "123",

                //make hint text
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),

                //create lable
                labelText: 'CVC',
                //lable style
                labelStyle: TextStyle(
                  color: darkRedColor,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            height: size.height*0.02,
          ),



          SizedBox(
            height: size.height*0.1,
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
                  }, child: Text('Add', style: buttonStyle)),
            ),
          ),
          SizedBox(
            height: size.height*0.1,
          ),


        ],),
      ),



    );
  }
}
