import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/models/farmer_model.dart';

class ProductViewPage extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const ProductViewPage({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  List<int> size = [
    25,
    50,
    75,
    100,
  ];

  int _selectedSize = 1;
  List<FarmerModel> farmerList = [];


  @override
  void initState() {
    super.initState();
    _initializeFarmerList();

  }

  void _initializeFarmerList() {
    // Assuming `product_owner` is a list of farmer names
    List<dynamic> productOwners = widget.documentSnapshot['product_owner'];
    farmerList = productOwners.map((owner) => FarmerModel(owner, false)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.6,
              elevation: 0,
              snap: true,
              floating: true,
              stretch: true,
              backgroundColor: Colors.grey.shade50,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
                background: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        widget.documentSnapshot['product_img'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: Transform.translate(
                  offset: Offset(0, 1),
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.documentSnapshot['product_name'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.documentSnapshot['brand'],
                                    style: TextStyle(
                                      color: Colors.orange.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\৳ " + widget.documentSnapshot['product_price'].toString() + '.00',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.documentSnapshot['product_details'],
                            style: TextStyle(
                              height: 1.5,
                              color: Colors.grey.shade800,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'পরিমান',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
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
                                    duration: Duration(milliseconds: 500),
                                    margin: EdgeInsets.only(right: 10),
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
                          SizedBox(height: 10),
                          Text(
                            'ফারমার লিস্ট :',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                          ),
                          ListView.builder(
                           itemCount: farmerList.length,
                           scrollDirection: Axis.vertical,
                           itemBuilder: (context, index){

                          })


                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      height: 50,
                      elevation: 0,
                      splashColor: Colors.lightGreen[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.lightGreen[800],
                      child: Center(
                        child: Text(
                          "কার্টে যোগ করুন",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
