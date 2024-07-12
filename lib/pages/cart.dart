import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../animation/FadeAnimation.dart';
import '../models/product.dart';
import 'payment.dart';
import 'product_view.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late List<Product> cartItems = [];
  List<int> cartItemCount = [];
  int totalPrice = 0;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Future<void> fetchItems() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);

    setState(() {
      cartItems = data['products'].map<Product>((json) => Product.fromJson(json)).toList();
      cartItemCount = List<int>.generate(cartItems.length, (index) => 1);
      sumTotal();
    });
  }

  void sumTotal() {
    totalPrice = cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('কার্ট', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height * 0.53,
            child: cartItems.isNotEmpty
                ? FadeAnimation(
              1.4,
              AnimatedList(
                key: _listKey,
                scrollDirection: Axis.vertical,
                initialItemCount: cartItems.length,
                itemBuilder: (context, index, animation) {
                  return Slidable(
                    key: Key(cartItems[index].toString()),
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => removeItem(index),
                          backgroundColor: Colors.red.withOpacity(0.15),
                          foregroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: cartItem(cartItems[index], index, animation),
                  );
                },
              ),
            )
                : Container(),
          ),
          SizedBox(height: 30),
          FadeAnimation(
            1.2,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('শিপিং চার্জ', style: TextStyle(fontSize: 20)),
                  Text('\৳১০০', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Padding(
              padding: EdgeInsets.all(20.0),
              child: DottedBorder(
                color: Colors.grey.shade400,
                dashPattern: [10, 10],
                padding: EdgeInsets.all(0),
                child: Container(),
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('মোট', style: TextStyle(fontSize: 20)),
                  Text('\৳${totalPrice + 100}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          FadeAnimation(
            1.4,
            Padding(
              padding: EdgeInsets.all(20.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
                },
                height: 50,
                elevation: 0,
                splashColor: Colors.lightGreen[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.lightGreen[800],
                child: const Center(
                  child: Text(
                    "চেকআউট",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      totalPrice -= cartItems[index].price * cartItemCount[index];
      cartItems.removeAt(index);
      cartItemCount.removeAt(index);
      _listKey.currentState?.removeItem(index, (context, animation) => SizeTransition(sizeFactor: animation, child: cartItem(cartItems[index], index, animation)));
    });
  }

  Widget cartItem(Product product, int index, Animation<double> animation) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(product: product)));
      },
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageURL,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.brand,
                      style: TextStyle(
                        color: Colors.lightGreen.shade400,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '\৳${product.price}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: 10,
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        if (cartItemCount[index] > 1) {
                          cartItemCount[index]--;
                          totalPrice -= product.price;
                        }
                      });
                    },
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey.shade400,
                      size: 30,
                    ),
                  ),
                  Center(
                    child: Text(
                      cartItemCount[index].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(0),
                    minWidth: 10,
                    splashColor: Colors.lightGreen[700],
                    onPressed: () {
                      setState(() {
                        cartItemCount[index]++;
                        totalPrice += product.price;
                      });
                    },
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add_circle,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
