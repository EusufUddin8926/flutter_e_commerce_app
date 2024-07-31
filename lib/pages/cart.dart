import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../animation/FadeAnimation.dart';
import '../models/product.dart';
import 'payment.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  late List<Product> cartItems = [];
  int totalPrice = 0;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Future<void> fetchItems() async {
    var query = await FirebaseFirestore.instance
        .collection("user")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("cart_item")
        .get();
    for (var cartItem in query.docs) {
      Product product = Product.fromJson(cartItem.data() as Map<String, dynamic>);
      cartItems.add(product);
    }

    setState(() {
      totalPrice = cartItems.fold(0, (sum, item) => sum + int.parse(item.total_price));
    });
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
        title: const Text('কার্ট', style: TextStyle(color: Colors.black)),
      ),
      body: cartItems.isNotEmpty ? buildCartContent() : buildEmptyCart(),
    );
  }

  Widget buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height * 0.5, // Reduced height
            child: FadeAnimation(
              1.4,
              AnimatedList(
                key: _listKey,
                scrollDirection: Axis.vertical,
                initialItemCount: cartItems.length,
                itemBuilder: (context, index, animation) {
                  return Slidable(
                    key: Key(cartItems[index].toString()),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            removeItem(index);
                          },
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
            ),
          ),
          const SizedBox(height: 20), // Reduced height
          FadeAnimation(
            1.2,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('শিপিং চার্জ', style: TextStyle(fontSize: 18)), // Reduced font size
                  Text('\৳100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Reduced font size
                ],
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Padding(
              padding: const EdgeInsets.all(15.0), // Reduced padding
              child: DottedBorder(
                color: Colors.grey.shade400,
                dashPattern: [10, 10],
                padding: const EdgeInsets.all(0),
                child: Container(),
              ),
            ),
          ),
          FadeAnimation(
            1.3,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('মোট', style: TextStyle(fontSize: 18)), // Reduced font size
                  Text('\৳${totalPrice + 100}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Reduced font size
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeAnimation(
            1.4,
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentPage()));
                },
                height: 45, // Reduced height
                elevation: 0,
                splashColor: Colors.lightGreen[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.lightGreen[800],
                child: const Center(
                  child: Text(
                    "চেকআউট",
                    style: TextStyle(color: Colors.white, fontSize: 16), // Reduced font size
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) async {
    if (index < 0 || index >= cartItems.length) return;

    final removedProduct = cartItems[index];

    if (_listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        index,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: cartItem(cartItems[index], index, animation),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
    // Remove item from Firestore
    await removeItemFromFirestore(removedProduct);
    totalPrice -= int.parse(cartItems[index].total_price);
    cartItems.removeAt(index);
    setState(() {

    });
  }

  Future<void> removeItemFromFirestore(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection("user")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart_item")
          .doc(product.uid)
          .delete();
      if (kDebugMode) {
        print('Item removed from Firestore successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing item from Firestore: $e');
      }
    }
  }

  Widget cartItem(Product product, int index, Animation<double> animation) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductViewPage(product: product)));
      },
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15), // Reduced margin
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.product_img,
                    fit: BoxFit.cover,
                    height: 80, // Reduced height
                    width: 80, // Reduced width
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.productBrand,
                      style: TextStyle(
                        color: Colors.lightGreen.shade400,
                        fontSize: 12, // Reduced font size
                      ),
                    ),
                    const SizedBox(height: 3), // Reduced spacing
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10), // Reduced spacing
                    Text(
                      '\৳${product.product_price}',
                      style: TextStyle(
                        fontSize: 18, // Reduced font size
                        color: Colors.grey.shade800,
                      ),
                    ),
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
                        int totalAmount = int.parse(cartItems[index].product_amount);
                        if (totalAmount > 1) {
                          totalAmount--;
                          cartItems[index].product_amount = totalAmount.toString();
                          cartItems[index].total_price = (totalAmount * cartItems[index].product_price).toString();
                          totalPrice -= cartItems[index].product_price;
                        }
                      });
                    },
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey.shade400,
                      size: 25, // Reduced size
                    ),
                  ),
                  Center(
                    child: Text(
                      cartItems[index].product_amount,
                      style: TextStyle(
                        fontSize: 18, // Reduced font size
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  MaterialButton(
                    padding: const EdgeInsets.all(0),
                    minWidth: 10,
                    splashColor: Colors.lightGreen[700],
                    onPressed: () {
                      setState(() {
                        int totalAmount = int.parse(cartItems[index].product_amount);
                        totalAmount++;
                        cartItems[index].product_amount = totalAmount.toString();
                        cartItems[index].total_price = (totalAmount * cartItems[index].product_price).toString();
                        totalPrice += cartItems[index].product_price;
                      });
                    },
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add_circle,
                      size: 25, // Reduced size
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
