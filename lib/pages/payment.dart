import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'payment_success.dart'; // Import the PaymentSuccess page

class PaymentPage extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;

  const PaymentPage({Key? key, required this.cartItems, required this.totalPrice}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পেমেন্ট', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
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
            buildPaymentOption(context, 'বিকাশ', Icons.account_balance),
            buildPaymentOption(context, 'রকেট', Icons.account_balance),
            buildPaymentOption(context, 'ক্রেডিট কার্ড', Icons.credit_card),
            buildPaymentOption(context, 'ক্যাশ অন ডেলিভারি', Icons.money),
            const SizedBox(height: 30),
            MaterialButton(
              onPressed: () {
                if (selectedPaymentMethod != null) {
                  processPayment().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentSuccess()),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a payment method')),
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

  Widget buildPaymentOption(BuildContext context, String title, IconData icon) {
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
            Icon(icon, color: isSelected ? Colors.lightGreen[800] : Colors.grey),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 18, color: isSelected ? Colors.lightGreen[800] : Colors.black)),
          ],
        ),
      ),
    );
  }

  Future<void> processPayment() async {
    // Implement the payment processing logic here.
    // For example, you could call a payment API hezre.
    
    // After payment is successful, clear the cart
    await clearCart();
  }

  Future<void> clearCart() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var batch = FirebaseFirestore.instance.batch();
    for (var item in widget.cartItems) {
      var cartItemRef = FirebaseFirestore.instance
          .collection("user")
          .doc(user.uid)
          .collection("cart_item")
          .doc(item.uid);
      batch.delete(cartItemRef);
    }
    await batch.commit();
  }
}
