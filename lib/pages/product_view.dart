
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductViewPage extends StatefulWidget {
  final Product product;
  const ProductViewPage({ Key? key, required this.product }) : super(key: key);

  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            elevation: 0,
            snap: true,
            floating: true,
            stretch: true,
            backgroundColor: Colors.grey.shade50,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [
                StretchMode.zoomBackground,
              ],
              background: Image.network(widget.product.imageURL, fit: BoxFit.cover,)
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(45),
              child: Transform.translate(
                offset: Offset(0, 1),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
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
                    )
                  ),
                ),
              )
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                height: MediaQuery.of(context).size.height * 0.55,
                color: Colors.white,
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
                            Text(widget.product.name,
                              style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold,),
                            ),
                            SizedBox(height: 5,),
                            Text(widget.product.brand, style: TextStyle(color: Colors.orange.shade400, fontSize: 14,),),
                          ],
                        ),
                        Text("\৳ " +widget.product.price.toString() + '.00',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Text("উন্নত মানের নাজির সাইল চাল .",
                      style: TextStyle(height: 1.5, color: Colors.grey.shade800, fontSize: 15,),
                    ),
                    SizedBox(height: 30,),
                    Text('পরিমান', style: TextStyle(color: Colors.grey.shade400, fontSize: 18),),
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
                    SizedBox(height: 20,),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      height: 50,
                      elevation: 0,
                      splashColor: Colors.lightGreen[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      color: Colors.lightGreen[800],
                      child: Center(
                        child: Text("কার্টে যোগ করুন", style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),
                    )
                  ],
                )
              )
            ])
          ),
        ]
      ),
    );
  }
}