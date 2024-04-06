

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/model/get_cart_model.dart';
import 'package:figma_new_project/model/product_model.dart';
import 'package:figma_new_project/view/screen/auth/login/login_screen.dart';
import 'package:figma_new_project/view/screen/orderPlaced/order_placed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
// #enddocregion platform_imports




class WebViewDetail extends StatefulWidget {
  final String url;

  const WebViewDetail({super.key,
    required this.url,

  });

  @override
  State<WebViewDetail> createState() => _WebViewDetailState();
}

class _WebViewDetailState extends State<WebViewDetail> {
  late final WebViewController _controller;
  final cartController = Get.put(AddToCartController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {

          },
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading= false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {

            if(request.url.contains('fb://profile/')) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }





  popNow() async {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.black,size: 20,), onPressed: () {
         Navigator.of(context).pop();
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashBoardScreen(index: 0)));

        },),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(''),
      ),
      body:
      Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          isLoading ? Center( child: CircularProgressIndicator(
            color: darkRedColor,
            strokeWidth: 1,
          ),)
              : Stack(),
        ],
      ),





    );
  }

}

