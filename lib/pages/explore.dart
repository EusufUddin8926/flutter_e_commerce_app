import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/product_view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../animation/FadeAnimation.dart';
import '../components/single_farmer_item.dart';
import '../helpers/network_info.dart';
import '../models/farmer_model.dart';
import '../service/firestore_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  List<dynamic> productList = [];
  List<int> size = [
    1,
    5,
    10,
    15,
    20,
    25,
    40,
    50,
    80,
    100,
  ];

  List<Color> colors = [
    Colors.black,
    Colors.purple,
    Colors.lightGreen.shade200,
    Colors.blueGrey,
    const Color(0xFFFFC1D9),
  ];

  // int _selectedColor = 0;
  int _selectedSize = 1;
  late NetworkInfo _networkInfo;
  var selectedRange = const RangeValues(10.00, 1500.00);
  late String totalPrice, unitPrice, amount, seller_name;

  CollectionReference mostPopularRef =
      FirebaseFirestore.instance.collection("Most Popular");
  CollectionReference forYouRef =
      FirebaseFirestore.instance.collection("for yourself");
  CollectionReference allProductRef =
      FirebaseFirestore.instance.collection("All Product");

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());

    super.initState();
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      setState(() {
      });
    } else {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(controller: _scrollController, slivers: [
      SliverAppBar(
        expandedHeight: 300.0,
        elevation: 0,
        pinned: true,
        floating: true,
        stretch: true,
        backgroundColor: Colors.grey.shade50,
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double minExtent =
                MediaQuery.of(context).padding.top + kToolbarHeight;
            final double maxExtent = constraints.maxHeight;
            final double currentExtent = constraints.biggest.height;
            final double deltaExtent = maxExtent - minExtent;
            final double t = (1.0 - (currentExtent - minExtent) / deltaExtent)
                .clamp(0.0, 1.0);

            final double logoHeight = lerpDouble(120, 40, t)!;
            final double fontSize = lerpDouble(20, 18, t)!;

            return FlexibleSpaceBar(
              centerTitle: true,
              title: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: logoHeight,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Text(
                                "কৃষিতে আপনাকে স্বাগতম",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset("assets/images/background.png",
                      fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottom: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Expanded(
                child: FadeAnimation(
                    1.4,
                    Container(
                      height: 50,
                      child: TextField(
                        readOnly: true,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          hintText: "আপনার পছন্দের পণ্যটি বাছাই করুন",
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    )),
              ),
              const SizedBox(width: 10),
              FadeAnimation(
                  1.5,
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      onPressed: () {
                        showFilterModal();
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
      FutureBuilder<bool>(
          future: _networkInfo.isConnected, // Future<bool> here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child:
                    Center(child: CircularProgressIndicator()), // Loading state
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!) {
              return const SliverFillRemaining(
                child: Center(child: Text("No Internet Available!")),
              );
            } else {
              return SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      color: Colors.white,
                      height: 330,
                      child: Column(children: [
                        FadeAnimation(
                            1.4,
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'বহুল প্রচলিত পণ্য',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    'সব দেখুন  ',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: StreamBuilder(
                          stream: mostPopularRef.snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> stramSnapShot) {
                            if (stramSnapShot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stramSnapShot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final DocumentSnapshot documentSnapshot =
                                        stramSnapShot.data!.docs[index];
                                    return productCart(documentSnapshot);
                                  });
                            }
                            ;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ))
                      ])),
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      height: 180,
                      child: Column(children: [
                        FadeAnimation(
                            1.4,
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'আপনার জন্য',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    'সব দেখুন  ',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: StreamBuilder(
                          stream: forYouRef.snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> stramSnapShot) {
                            if (stramSnapShot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stramSnapShot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final DocumentSnapshot
                                        forYoudocumentSnapshot =
                                        stramSnapShot.data!.docs[index];
                                    return forYou(forYoudocumentSnapshot);
                                  });
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ))
                      ])),
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      height: 330,
                      child: Column(children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'নতুন পণ্য',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Text(
                                'সব দেখুন  ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: StreamBuilder(
                          stream: allProductRef.snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> stramSnapShot) {
                            if (stramSnapShot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stramSnapShot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final DocumentSnapshot documentSnapshot =
                                        stramSnapShot.data!.docs[index];
                                    return productCart(documentSnapshot);
                                  });
                            }
                            ;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ))
                      ])),
                ]),
              );
            }
          })
    ]);
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductViewPage(
                          documentSnapshot: documentSnapshot,
                        )));
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                )
              ],
            ),
            padding: const EdgeInsets.all(10),
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
                            addToCartModal(documentSnapshot);
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 10),
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
                      "\৳ " +
                          documentSnapshot['product_price'].toString() +
                          '.00',
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
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductViewPage(
                          documentSnapshot: forYoudocumentSnapshot,
                        )));
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(5, 10),
                  blurRadius: 15,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 10),
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
                      const SizedBox(height: 5),
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
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          "\৳ " +
                              forYoudocumentSnapshot['product_price']
                                  .toString() +
                              '.00',
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      minWidth: 40,
                      height: 40,
                      color: Colors.grey.shade300,
                      elevation: 0,
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'পরিমান',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                          duration: const Duration(milliseconds: 500),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: _selectedSize == index
                                  ? Colors.lightGreen[800]
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle),
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Text(
                              size[index].toString(),
                              style: TextStyle(
                                  color: _selectedSize == index
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Slider Price Renge filter
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Price Range',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\৳ ${selectedRange.start.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                        Text(" - ",
                            style: TextStyle(color: Colors.grey.shade500)),
                        Text(
                          '\৳ ${selectedRange.end.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                RangeSlider(
                    values: selectedRange,
                    min: 0.00,
                    max: 2000.00,
                    divisions: 100,
                    inactiveColor: Colors.grey.shade300,
                    activeColor: Colors.lightGreen[800],
                    labels: RangeLabels(
                      '\৳ ${selectedRange.start.toStringAsFixed(2)}',
                      '\৳ ${selectedRange.end.toStringAsFixed(2)}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() => selectedRange = values);
                    }),
                const SizedBox(
                  height: 20,
                ),
                button('Filter', () {})
              ],
            ),
          );
        });
      },
    );
  }

  addToCartModal(DocumentSnapshot<Object?> documentSnapshot) async {
    List<FarmerModel> farmerList = [];
    int? selectedFarmerIndex;

    List<dynamic> productOwners = documentSnapshot['product_owner'];
    farmerList =
        productOwners.map((owner) => FarmerModel(owner, false)).toList();
    setState(() {});

    return showModalBottomSheet(
      context: context,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40.0),
                  topLeft: Radius.circular(40.0)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "পরিমান",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: size.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _selectedSize == index
                                    ? Colors.lightGreen[800]
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Text(
                                  size[index].toString(),
                                  style: TextStyle(
                                    color: _selectedSize == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ফারমার লিস্ট :',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 18),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: farmerList.length * 50.0,
                      child: ListView.builder(
                        itemCount: farmerList.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        // Allows the ListView to wrap its content
                        physics: const NeverScrollableScrollPhysics(),
                        // Disables scrolling
                        itemBuilder: (context, index) {
                          return SingleFarmerItem(
                            index: index,
                            farmer: farmerList[index],
                            onSelected: (index) {
                              setState(() {
                                selectedFarmerIndex = index;
                                for (int i = 0; i < farmerList.length; i++) {
                                  farmerList[i].isFarmerSelected =
                                      (i == selectedFarmerIndex);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                button('কার্টে যোগ করুন', () async {
                  User? userCredential =
                      await FirebaseAuth.instance.currentUser;

                  if (!await _networkInfo.isConnected) {
                    const snackbar = SnackBar(
                      content: Text("No internet available!"),
                      duration: Duration(seconds: 5),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    return;
                  }

                  if (userCredential == null) {
                    const snackbar = SnackBar(
                      content: Text("No user is currently logged in."),
                      duration: Duration(seconds: 5),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    return;
                  }

                  if (selectedFarmerIndex == null) {
                    const snackbar = SnackBar(
                      content: Text("First select a farmer!"),
                      duration: Duration(seconds: 5),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    Navigator.pop(context);
                    return;
                  }

                  totalPrice = ((documentSnapshot['product_price'] as int) *
                          size[_selectedSize])
                      .toString();

                  await FirestoreServices.addItemToCart(
                      userCredential.uid,
                      DateTime.now().millisecondsSinceEpoch.toString(),
                      documentSnapshot['product_name'],
                      documentSnapshot['brand'],
                      documentSnapshot['product_price'],
                      documentSnapshot['product_img'],
                      size[_selectedSize].toString(),
                      totalPrice,
                      farmerList[selectedFarmerIndex!].farmerName,
                      context);

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
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  button(String text, Function onPressed) {
    return MaterialButton(
      onPressed: () => onPressed(),
      height: 50,
      elevation: 0,
      splashColor: Colors.lightGreen[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.lightGreen[800],
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
