import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/view/screen/contactUs/detail_view.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
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
          'Contact us',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              ListTile(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => ProductDetailScreen(product: scrollDataModel[t].productList[index])));
                },
                leading:  Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: 60,
                      width: 60,
                      fit: BoxFit.scaleDown,
                      imageUrl: 'https://cdn.iconscout.com/icon/free/png-256/free-gmail-2981844-2476484.png?f=webp',
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text('Gmail',
                  style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w600),
                ),
                subtitle: Text('customercare@honchos.co.za',
                  style: TextStyle(color: Colors.blue, fontSize: 11,fontWeight: FontWeight.w300),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  height: 5,
                  color: Colors.grey,
                ),
              ),
              ListTile( // https://www.facebook.com/profile.php?id=100064653553842

              onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WebViewDetail(url:'https://www.facebook.com/profile.php?id=100064653553842')));
                },
                leading:  Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: 60,
                      width: 60,
                      fit: BoxFit.scaleDown,
                      imageUrl: 'https://cdn-icons-png.flaticon.com/512/5968/5968764.png',
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text('Facebook',
                  style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w600),
                ),

              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  height: 5,
                  color: Colors.grey,
                ),
              ),

              ListTile(
                onTap: () {

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WebViewDetail(url:'https://www.instagram.com/honchos_za/')));

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => ProductDetailScreen(product: scrollDataModel[t].productList[index])));
                },
                leading:  Container(
                  decoration: BoxDecoration(
                    color: lightButtonGreyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: 60,
                      width: 60,
                      fit: BoxFit.scaleDown,
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/2048px-Instagram_icon.png',
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text('Instagram',
                  style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w600),
                ),
              ),


            ],),
        ),
      ),
    );
  }
}
