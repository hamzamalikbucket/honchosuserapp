import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../model/category_and_products_list.dart';
import '../../testing_file.dart';
import '../../utils/colors.dart';
import '../../utils/helper.dart';
import '../../view_model/example_data.dart';
import '../screen/productDetail/product_detail_screen.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    Key? key,
    required this.category,
    required this.index,
  }) : super(key: key);

  final ScrollDataModel category;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (category.productList.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        margin: const EdgeInsets.only(bottom: 16),
        color: scheme.surface,
        child: Column(
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
                        imageUrl: imageConstUrl + category.category!.image.toString(),
                        //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    height: 40,
                    child: Text(
                      category.category!.name.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                return Container(
                  height: 40,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: category.productList[index])));
                    },
                    title: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.productList[index].name.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'R ' + category.productList[index].price.toString(),
                            style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context,index){
                return SizedBox(
                  height: 10,
                );
              },
              itemCount: category.productList.length,
            )
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        margin: const EdgeInsets.only(bottom: 16),
        color: scheme.surface,
        child: Container(
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
                    imageUrl: imageConstUrl + category.category!.image.toString(),
                    //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                height: 40,
                child: Text(
                  category.category!.name.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //   margin: const EdgeInsets.only(bottom: 16),
    //   color: scheme.surface,
    //   child: index == 0
    //       ? Container(
    //           height: categoryHeight,
    //           alignment: Alignment.centerLeft,
    //           // padding: const EdgeInsets.symmetric(horizontal: 10),
    //           color: darkRedColor,
    //           child: Column(
    //             children: [
    //               Container(
    //                 // decoration: BoxDecoration(
    //                 color: lightButtonGreyColor,
    //                 //   borderRadius: BorderRadius.circular(10),
    //                 // ),
    //                 child: ClipRRect(
    //                   //  borderRadius: BorderRadius.circular(10),
    //                   child: CachedNetworkImage(
    //                     height: 170,
    //                     width: MediaQuery.of(context).size.width,
    //                     fit: BoxFit.cover,
    //                     imageUrl: imageConstUrl + category.category!.image.toString(),
    //                     //   placeholder: (context, url) => CircularProgressIndicator(color: darkRedColor,),
    //                     errorWidget: (context, url, error) => Icon(Icons.error),
    //                   ),
    //                 ),
    //               ),
    //               Container(
    //                 padding: const EdgeInsets.symmetric(horizontal: 10),
    //                 alignment: Alignment.centerLeft,
    //                 height: 40,
    //                 child: Text(
    //                   category.category!.name.toString(),
    //                   style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )
    //       : category.category!.name.toString() == category.productList[index].category!.name.toString()
    //           ? Container(
    //               height: 40,
    //               child: ListTile(
    //                 onTap: () {
    //                   Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: category.productList[index])));
    //                 },
    //                 title: Container(
    //                   width: MediaQuery.of(context).size.width * 0.9,
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         category.productList[index].name.toString(),
    //                         style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
    //                       ),
    //                       Text(
    //                         'R ' + category.productList[index].price.toString(),
    //                         style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             )
    //           : Container(
    //     height: 200,
    //     color: Colors.red,
    //   ),
    // );
  }

  // Widget _buildFoodTileList(BuildContext context) {
  //   return Column(
  //     children: List.generate(
  //       category.foods.length,
  //       (index) {
  //         final food = category.foods[index];
  //         bool isLastIndex = index == category.foods.length - 1;
  //         return _buildFoodTile(
  //           food: food,
  //           context: context,
  //           isLastIndex: isLastIndex,
  //         );
  //       },
  //     ),
  //   );
  // }
  //
  // Widget _buildSectionTileHeader(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 16),
  //       _sectionTitle(context),
  //       const SizedBox(height: 8.0),
  //       category.subtitle != null ? _sectionSubtitle(context) : const SizedBox(),
  //       const SizedBox(height: 16),
  //     ],
  //   );
  // }
  //
  // Widget _sectionTitle(BuildContext context) {
  //   return Row(
  //     children: [
  //       if (category.isHotSale) _buildSectionHoteSaleIcon(),
  //       Text(
  //         category.title,
  //         style: _textTheme(context).headline6,
  //         strutStyle: Helper.buildStrutStyle(_textTheme(context).headline6),
  //       )
  //     ],
  //   );
  // }
  //
  // Widget _sectionSubtitle(BuildContext context) {
  //   return Text(
  //     category.subtitle!,
  //     style: _textTheme(context).subtitle2,
  //     strutStyle: Helper.buildStrutStyle(_textTheme(context).subtitle2),
  //   );
  // }

  Widget _buildFoodTile({
    required BuildContext context,
    required bool isLastIndex,
    required Food food,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFoodDetail(food: food, context: context),
            _buildFoodImage(food.imageUrl),
          ],
        ),
        !isLastIndex ? const Divider(height: 16.0) : const SizedBox(height: 8.0)
      ],
    );
  }

  Widget _buildFoodImage(String url) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/cash.png',
      image: url,
      width: 64,
    );
  }

  Widget _buildFoodDetail({
    required BuildContext context,
    required Food food,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(food.name, style: _textTheme(context).subtitle1),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              "មកពី" + food.price + " ",
              style: _textTheme(context).caption,
              strutStyle: Helper.buildStrutStyle(_textTheme(context).caption),
            ),
            Text(
              food.comparePrice,
              strutStyle: Helper.buildStrutStyle(_textTheme(context).caption),
              style: _textTheme(context).caption?.copyWith(decoration: TextDecoration.lineThrough),
            ),
            const SizedBox(width: 8.0),
            if (food.isHotSale) _buildFoodHotSaleIcon(),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHoteSaleIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      child: Icon(
        Icons.whatshot,
        color: scheme.primary,
        size: 20.0,
      ),
    );
  }

  Widget _buildFoodHotSaleIcon() {
    return Container(
      child: Icon(Icons.whatshot, color: scheme.primary, size: 16.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  TextTheme _textTheme(context) => Theme.of(context).textTheme;
}
