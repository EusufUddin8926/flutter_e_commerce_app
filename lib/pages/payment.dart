import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_e_commerce_app/pages/payment_success.dart';
import 'package:flutter_e_commerce_app/service/firestore_service.dart';
import 'package:flutter_e_commerce_app/models/product.dart';
import '../models/order_model.dart';
import '../service/payment_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;

  const PaymentPage({Key? key, required this.cartItems, required this.totalPrice}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;
  bool _isLoading = false;
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পেমেন্ট', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('মোট পরিশোধ করতে হবে', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('৳${widget.totalPrice + 100}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text('পেমেন্ট পদ্ধতি নির্বাচন করুন', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            buildPaymentOption(context, 'এসএসএল', image: const AssetImage("assets/images/ssl_logo.png")),
            buildPaymentOption(context, 'ক্যাশ অন ডেলিভারি', icon: Icons.money),
            const SizedBox(height: 30),

            // Delivery Address Field
            const Text('ডেলিভারি ঠিকানা', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'আপনার ডেলিভারি ঠিকানা লিখুন',
              ),
            ),
            const SizedBox(height: 60),

            // Payment Button
            MaterialButton(
              onPressed: () async {
                if (selectedPaymentMethod != null) {
                  await _handlePayment(); // Call _handlePayment here
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('অনুগ্রহ করে পেমেন্ট পদ্ধতি নির্বাচন করুন')),
                  );
                }
              },
              height: 45,
              elevation: 0,
              splashColor: Colors.lightGreen[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.lightGreen[800],
              child: const Center(
                child: Text(
                  "পরিশোধ করুন",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildPaymentOption(BuildContext context, String title, {IconData? icon, ImageProvider? image}) {
    final isSelected = selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.lightGreen[50] : Colors.white,
        ),
        child: Row(
          children: <Widget>[
            if (image != null)
              Image(image: image, width: 40, height: 40)  // Display image if provided
            else if (icon != null)
              Icon(icon, color: isSelected ? Colors.lightGreen[800] : Colors.grey),  // Display icon if provided
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 18, color: isSelected ? Colors.lightGreen[800] : Colors.black)),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    // Check if the address field is empty
    if (_addressController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে আপনার ঠিকানা লিখুন')),
      );
      return;
    }
    // Generate a unique order ID
    var orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Save orders to Firestore
    for (Product product in widget.cartItems) {
      FirestoreServices.saveOrders(OrderModel(
        orderId,
        "12345678",
        FirebaseAuth.instance.currentUser!.uid,
        FirebaseAuth.instance.currentUser!.displayName!,
        product.productName,
        product.sellerName,
        product.product_amount,
        product.product_price,
        product.total_price,
        "Pending",
        selectedPaymentMethod.toString(),
        _addressController.text,
        0,
      ));
    }

    // Check payment method and handle accordingly
    if (selectedPaymentMethod == 'এসএসএল') {
      // Call the payNow function from PaymentService
      await PaymentService.payNow(context, widget.totalPrice + 100, orderId);

      // Clear cart items from Firestore after confirming the order
      FirestoreServices.removeAllCartItemsFromFirestore();

      setState(() {
        _isLoading = false;
      });
    }    // Navigate to the PaymentSuccess page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OrderSuccess()),
    );
  }
}
