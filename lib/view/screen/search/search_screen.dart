import 'package:figma_new_project/constants.dart';
import 'package:figma_new_project/dashBoard/dashboard_screen.dart';
import 'package:figma_new_project/view/screen/detail/detail_screen.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String russian = '';
  List<String> pages = [
    'assets/images/home_1.png',
    'assets/images/burger.png',
    'assets/images/burger1.png',
  ];

  List<FoodItem> items = [
    FoodItem(
      image:'assets/images/food1.png',
      title:'Famil Meal',
      description:'Single burger with beef',
    ),
    FoodItem(
      image:'assets/images/food2.png',
      title:'Double Up',
      description:'Single burger with beef',
    ),
    FoodItem(
      image:'assets/images/food3.png',
      title:'Famil Meal',
      description:'Single burger with beef',
    ),
    FoodItem(
      image:'assets/images/locationOne.png',
      title:'Double Up',
      description:'Single burger with beef',
    ),


  ];

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      russian = '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double widthSize = MediaQuery.of(context).size.width;
    return
      russian == 'detail' ? DetailScreen(
        categoryId:  '',//restaurantCategoriesList[index].id.toString(),
        categoryImage: '',//restaurantCategoriesList[index].name.toString(),
        categoryName:  '',//restaurantCategoriesList[index].name.toString(),
        restaurantId:  '',//restaurantCategoriesList[index].restaurantId.toString(),
      ) :
      Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.07,
            ),
            Container(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
                      //  Scaffold.of(context).openDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.asset(
                          'assets/images/arrow_back.png',
                          height: 35,
                          width: 35,
                          fit: BoxFit.scaleDown,
                        ),
                      )),
                  Container(
                    width: size.width * 0.65,
                    margin: EdgeInsets.only(left: 0, right: 8, bottom: 0),
                    child: TextFormField(
                      controller: _searchController,
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
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        focusColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: darkGreyTextColor1, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.grey,
                        hintText: "Search Food",

                        //make hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        russian = 'detail';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: [0.1, 0.9],
                            colors: [lightRedColor, darkRedColor],
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      width: size.width * 0.15,
                      height: widthSize > 700 ?
                      size.height*0.05 : size.height*0.06,
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.035,
            ),
            russian == 'russian'
                ? Column(
                    children: [
                      Container(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  '04 Results Found ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Icon(Icons.filter_alt_outlined,size: 25,color: Colors.black,),
                                    ),
                                    Text(
                                      'Filter',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      // SizedBox(
                      //   height: size.height * 0.02,
                      // ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(

                         // height: size.height*0.66,
                          child: GridView.builder(
                              padding: EdgeInsets.only(top: 8),
                              shrinkWrap: true,
                              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: size.height * 0.235,
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10),
                              itemCount:items.length,

                              itemBuilder: (BuildContext ctx, index) {

                                // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses!.length);
                                // print(studentClasseModelUpdated!.chapList![widget.chapterIndex].content!.
                                // surahs![widget.partIndex].part1![surahIndex].verses!.surahVerses![index].verseRecording.toString() + " surah record");

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      russian = 'detail';
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4,right: 4),
                                    child: Container(
                                     // height: size.height*0.25,
                                      width: size.width*0.4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: lightButtonGreyColor,
                                              spreadRadius: 2,
                                              blurRadius: 3
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              height: size.height*0.13,
                                              width: size.width*0.4,
                                              child: Stack(
                                                alignment: Alignment.topLeft,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Image.asset(items[index].image, fit: BoxFit.cover,
                                                      height: size.height*0.13,
                                                      width: size.width*0.4,
                                                      // height: 80,
                                                      // width: 80,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      width: size.width*0.23,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(6.0),
                                                        child: Row(children: [
                                                          Icon(Icons.star,size: 12,color: Colors.amber,),
                                                          Text(' (5.0) 34',
                                                            style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.bold),),
                                                        ],),
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),

                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.4,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(items[index].title,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.bold),),
                                                  Image.asset('assets/images/add.png', fit: BoxFit.scaleDown,
                                                    height: 20,
                                                    width: 20,
                                                    // height: 80,
                                                    // width: 80,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Container(
                                              width: size.width*0.4,
                                              child: Text(items[index].description,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: darkGreyTextColor, fontSize: 12,fontWeight: FontWeight.w400),),
                                            ),

                                            SizedBox(
                                              height: size.height*0.01,
                                            ),


                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),


                    ],
                  )
                : Column(
                    children: [
                      Container(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'History ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: size.height * 0.025,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            russian = 'russian';
                          });
                        },
                        child: Container(
                            width: size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(
                                      Icons.update,
                                      color: Colors.grey,
                                      size: 20,
                                    )),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10, left: 10),
                                  child: Text(
                                    'Russian',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: size.height * 0.025,
                      ),
                      Container(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.update,
                                    color: Colors.grey,
                                    size: 20,
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: Text(
                                  'Fast Food',
                                  style: TextStyle(
                                      color: darkGreyTextColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: size.height * 0.025,
                      ),
                      Container(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Recently Viewed ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(right: 10),
                              //   child: Text('Clear All', style: TextStyle(color: Colors.grey, fontSize: 15,fontWeight: FontWeight.w400),),
                              // ),
                            ],
                          )),
                      SizedBox(
                        height: size.height * 0.025,
                      ),
                      SizedBox(
                        height: size.height * 0.29,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetailScreen(

                                      categoryId:  '',//restaurantCategoriesList[index].id.toString(),
                                      categoryImage: '',//restaurantCategoriesList[index].name.toString(),
                                      categoryName:  '',//restaurantCategoriesList[index].name.toString(),
                                      restaurantId:  '',//restaurantCategoriesList[index].restaurantId.toString(),

                                    )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                //  height: size.height * 0.25,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                      ],
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                      //    height: size.height * 0.16,
                                          width: size.width * 0.7,
                                          child: Stack(
                                            alignment: Alignment.topLeft,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  pages[index], fit: BoxFit.cover,
                                                  height: size.height * 0.16,
                                                  width: size.width * 0.7,
                                                  // height: 80,
                                                  // width: 80,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: size.width * 0.24,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 15,
                                                          color: Colors.amber,
                                                        ),
                                                        Text(
                                                          ' (5.0) 34',
                                                          style: TextStyle(
                                                              color:
                                                                  Color(0xFF585858),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Container(
                                          width: size.width * 0.7,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Family Meal',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Color(0xFF585858),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'R-109',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Container(
                                          width: size.width * 0.7,
                                          child: Text(
                                            '1 chicken, large chips, pepsi',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: darkGreyTextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: pages.length,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}


class FoodItem {

  final String image;
  final String title;
  final String description;

  FoodItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
