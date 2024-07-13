import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_e_commerce_app/pages/product_view.dart';
import '../animation/FadeAnimation.dart';
import '../models/product.dart';

class ExplorePage extends StatefulWidget {  
  const ExplorePage({ Key? key }) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolled = false;
  List<dynamic> productList = [];
  List<int> size = [
    25,
    50,
    75,
    100,
  ];

  List<Color> colors = [
    Colors.black,
    Colors.purple,
    Colors.lightGreen.shade200,
    Colors.blueGrey,
    Color(0xFFFFC1D9),
  ];

  // int _selectedColor = 0;
  int _selectedSize = 1;

  var selectedRange = RangeValues(150.00, 1500.00);
  
  CollectionReference mostPopularRef = FirebaseFirestore.instance.collection("Most Popular");
  CollectionReference forYouRef = FirebaseFirestore.instance.collection("for yourself");
  CollectionReference allProductRef = FirebaseFirestore.instance.collection("All Product");

  @override
  void initState() { 
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    //products();

    super.initState();
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          elevation: 0,
          pinned: true,
          floating: true,
          stretch: true,
          backgroundColor: Colors.grey.shade50,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            titlePadding: const EdgeInsets.only(left: 20, right: 30, bottom: 100),
            stretchModes: const [
              StretchMode.zoomBackground,
              // StretchMode.fadeTitle
            ],
            title: AnimatedOpacity(
              opacity: _isScrolled ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              child: FadeAnimation(1, const Text("কৃষিতে আপনাকে স্বাগতম",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                ))),
            ),
            background: Image.asset("assets/images/background.png", fit: BoxFit.cover,)
          ),
          bottom: AppBar(
            toolbarHeight: 70,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Expanded(
                  child: FadeAnimation(1.4, Container(
                    height: 50,
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none
                        ),
                        hintText: "আপনার পছন্দের পণ্যটি বাছাই করুন",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  )),
                ),
                SizedBox(width: 10),
                FadeAnimation(1.5, Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: IconButton(
                    onPressed: () {
                      showFilterModal();
                    },
                    icon: Icon(Icons.filter_list, color: Colors.black, size: 30,),
                  ),
                ))
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.only(top: 20, left: 20),
              color: Colors.white,
              height: 330,
              child: Column(
                children: [
                  FadeAnimation(1.4, const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('বহুল প্রচলিত পণ্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text('সব দেখুন  ', style: TextStyle(color: Colors.black, fontSize: 14),),
                      ),
                    ],
                  )),
                  SizedBox(height: 10,),
                  Expanded(
                    child: StreamBuilder(
                      stream: mostPopularRef.snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> stramSnapShot){
                        if(stramSnapShot.hasData){
                          return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: stramSnapShot.data!.docs.length,
                        itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot = stramSnapShot.data!.docs[index];
                        return productCart(documentSnapshot);
                        });
                        };
                        return const Center(child: CircularProgressIndicator(),);
                      },
                    )
                  )
                ]
              )
            ),
            Container(
                color: Colors.white,
              padding: EdgeInsets.only(top: 20, left: 20),
              height: 180,
              child: Column(
                children: [
                  FadeAnimation(1.4, const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('আপনার জন্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text('সব দেখুন  ', style: TextStyle(color: Colors.black, fontSize: 14),),
                      ),
                    ],
                  )),
                  SizedBox(height: 10,),
                  Expanded(
                    child: StreamBuilder(
                      stream: forYouRef.snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> stramSnapShot){
                        if(stramSnapShot.hasData){
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: stramSnapShot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot forYoudocumentSnapshot = stramSnapShot.data!.docs[index];
                                return forYou(forYoudocumentSnapshot);
                              }
                          );
                        }
                        return Center(child: CircularProgressIndicator(),);
                      },
                    )
                  )
                ]
              )
            ),
            Container(
                color: Colors.white,
              padding: EdgeInsets.only(top: 20, left: 20),
              height: 330,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('নতুন পণ্য', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text('সব দেখুন  ', style: TextStyle(color: Colors.black, fontSize: 14),),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: StreamBuilder(
                      stream: allProductRef.snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> stramSnapShot){
                        if(stramSnapShot.hasData){
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: stramSnapShot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot = stramSnapShot.data!.docs[index];
                                return productCart(documentSnapshot);
                              });
                        };
                        return Center(child: CircularProgressIndicator(),);
                      },
                    )
                  )
                ]
              )
            ),
          ]),
        )
      ]
    );
  }

  /*Future<void> products() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);

    setState(() {
      productList = data['products']
        .map((data) => Product.fromJson(data)).toList();
    });
  }*/

  productCart(DocumentSnapshot<Object?> documentSnapshot) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: FadeAnimation(
        1.5,
        GestureDetector(
          onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(documentSnapshot: documentSnapshot,)));
          },
          child: Container(
            margin: EdgeInsets.only(right: 20, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                )
              ],
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            documentSnapshot['product_img'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      // Add to cart button
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: MaterialButton(
                          color: Colors.black,
                          minWidth: 45,
                          height: 45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onPressed: () {
                            addToCartModal();
                          },
                          padding: const EdgeInsets.all(5),
                          child: const Center(
                            child: Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  documentSnapshot['product_name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Adjust this based on your needs
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        documentSnapshot['brand'],
                        style: TextStyle(
                          color: Colors.lightGreen.shade400,
                          fontSize: 14,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Adjust this based on your needs
                      ),
                    ),
                    Text(
                      "\৳ " + documentSnapshot['product_price'].toString() + '.00',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Adjust this based on your needs
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  forYou(DocumentSnapshot<Object?> forYoudocumentSnapshot) {
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: FadeAnimation(
        1.5,
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(documentSnapshot: forYoudocumentSnapshot,)));
          },
          child: Container(
            margin: EdgeInsets.only(right: 20, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      forYoudocumentSnapshot['product_img'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          forYoudocumentSnapshot['product_name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          forYoudocumentSnapshot['brand'],
                          style: TextStyle(
                            color: Colors.lightGreen.shade400,
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          "\৳ " + forYoudocumentSnapshot['product_price'].toString() + '.00',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        minWidth: 40,
                        height: 40,
                        color: Colors.grey.shade300,
                        elevation: 0,
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Icon(Icons.close, color: Colors.black,),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Text('পরিমান', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: size.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _selectedSize == index ? Colors.lightGreen[800] : Colors.grey.shade200,
                              shape: BoxShape.circle
                            ),
                            width: 40,
                            height: 40,
                            child: Center(
                              child: Text(size[index].toString(), style: TextStyle(color: _selectedSize == index ? Colors.white : Colors.black, fontSize: 15),),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Slider Price Renge filter
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price Range', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('\৳ ${selectedRange.start.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12),),
                          Text(" - ", style: TextStyle(color: Colors.grey.shade500)),
                          Text('\৳ ${selectedRange.end.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12),),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  RangeSlider(
                    values: selectedRange, 
                    min: 0.00,
                    max: 2000.00,
                    divisions: 100,
                    inactiveColor: Colors.grey.shade300,
                    activeColor: Colors.lightGreen[800],
                    labels: RangeLabels('\৳ ${selectedRange.start.toStringAsFixed(2)}', '\৳ ${selectedRange.end.toStringAsFixed(2)}',),
                    onChanged: (RangeValues values) {
                      setState(() => selectedRange = values);
                    }
                  ),
                  const SizedBox(height: 20,),
                  button('Filter', () {})
                ],
              ),
            );
          }
        );
      },
    );
  }

  addToCartModal() {
    return showModalBottomSheet(
      context: context, 
      transitionAnimationController: AnimationController(duration: Duration(milliseconds: 400), vsync: this),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 350,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("পরিমান", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(height: 10,),
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: size.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: _selectedSize == index ? Colors.lightGreen[800] : Colors.grey.shade200,
                            shape: BoxShape.circle
                          ),
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Text(size[index].toString(), style: TextStyle(color: _selectedSize == index ? Colors.white : Colors.black, fontSize: 15),),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                button('কার্টে যোগ করুন', () {
                  Navigator.pop(context);

                  //show a snackbar when an item is added to the cart
                  final snackbar = SnackBar(
                    content: const Text("পণ্যটি কার্টে যোগ করা হয়েছে"),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {},
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                })
              ],
            ),
          );
        },
      )
    );
  }

  button(String text, Function onPressed) {
    return MaterialButton(
      onPressed: () => onPressed(),
      height: 50,
      elevation: 0,
      splashColor: Colors.lightGreen[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      color: Colors.lightGreen[800],
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18),),
      ),
    );
  }
}
