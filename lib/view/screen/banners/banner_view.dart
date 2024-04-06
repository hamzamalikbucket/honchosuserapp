import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/model/bannerModel.dart';
import 'package:figma_new_project/model/restaurant_category_product_model.dart';
import 'package:figma_new_project/view/screen/productDetail/product_detail_screen.dart';
import 'package:flutter/material.dart';

class BannerView extends StatefulWidget {
  final List<CategoriesProductsModel> productList;
  final String restaurantId;
  final BannerModel model;
  const BannerView({super.key, required this.productList, required this.model, required this.restaurantId});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
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
          widget.model.category!.name.toString(),
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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

      body: Column(
        children: [
          Container(
            height: categoryHeight,
            alignment: Alignment.centerLeft,
            // padding: const EdgeInsets.symmetric(horizontal: 10),
            color: darkRedColor,
            child: Column(
              children: [
                Container(
                  // decoration: BoxDecoration(
                  color: lightButtonGreyColor,
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  child: ClipRRect(
                    //  borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: 170,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl:  imageConstUrl + widget.model.category!
                          .image
                          .toString(),
                      //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: Text(widget.model.category!.name.toString(),style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                ),
              ],
            ),
          ),

          Container(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.productList.length,
              itemBuilder: (_, index) =>
              widget.restaurantId == widget.productList[index].restaurantId.toString()
                  && widget.productList[index].category!.id.toString() == widget.model.category!.id.toString()

                  ?
              Container(
                height: 40,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: widget.productList[index])));
                  },
                  title:  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.productList[index].name.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w600),
                        ),

                        Text('R '+widget.productList[index].price.toString(),
                          style: TextStyle(color: Colors.red, fontSize: 13,fontWeight: FontWeight.bold),),

                      ],),
                  ),
                ),
              ) : Container(),
            ),
          ),
        ],
      ),

    );
  }
}
