
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {



 // git commit -m "8/15/23 commit Nouman"
 static void flushBarErrorMessage(String message, BuildContext context, Color color, String title) {
   showFlushbar(context: context, flushbar: Flushbar(
     message: message.toString(),
     backgroundColor: color,
     title: title.toString(),
     titleColor: Colors.white,
     duration: Duration(seconds: 3),
   )..show(context)
   );
 }


}