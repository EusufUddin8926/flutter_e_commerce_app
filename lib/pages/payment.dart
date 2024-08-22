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
              onPressed: () async {
                if (selectedPaymentMethod != null) {
                  await _handlePayment(); // Call _handlePayment here
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

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    // Generate a unique order ID
    var orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Save orders to Firestore
    for (Product product in widget.cartItems) {
      FirestoreServices.saveOrders(OrderModel(
        orderId,
        "123455666",
        FirebaseAuth.instance.currentUser!.uid,
        FirebaseAuth.instance.currentUser!.displayName!,
        product.productName,
        product.sellerName,
        product.product_amount,
        product.product_price,
        product.total_price,
        "Pending",
        selectedPaymentMethod.toString(),
        "",
        0,
      ));
    }

    // Call the payNow function from PaymentService
    await PaymentService.payNow(context, widget.totalPrice + 100, orderId);

    // Clear cart items from Firestore after confirming the order
    FirestoreServices.removeAllCartItemsFromFirestore();

    setState(() {
      _isLoading = false;
    });

    // Navigate to the PaymentSuccess page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaymentSuccess()),
    );
  }
}
