import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          'Privacy Policy',
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

            Center(
              child: Container(
                width: size.width*0.9,
                child: Text(
                  'Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a '
                      'document or a typeface without relying on meaningful content. Lorem ipsum may be'
                      ' used as a placeholder before final copy is available.'
                      ' It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.'
                      ' The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using'
                      ' \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web '
                      'page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web '
                      'sites still in their infancy.\n\n'
                      'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour,'
                      ' or randomised words which don\'t look even slightly believable.'
                      ' If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t anything embarrassing hidden in the middle of text.'
                      ' All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet.'
                      ' It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable.'
                ' The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.'
                      '\n\nThe standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.',
                  style: TextStyle(color: Colors.black, fontSize: 15,wordSpacing: 1),textAlign: TextAlign.justify,),

              ),
            )

          ],),
        ),
      ),

    );
  }
}
