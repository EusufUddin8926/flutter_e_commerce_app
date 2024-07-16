import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirestoreServices {
  static saveUser(String name, email, password, dynamic uid, String address,
      phoneNumber) async {
    await FirebaseFirestore.instance.collection('user').doc(uid).set({
      'uId': uid,
      'email': email,
      'password': password,
      'fullName': name,
      'address': address,
      'phone_number': phoneNumber
    });
  }

  static addItemToCart(
      dynamic uid,
      String productName,
      String brand,
      dynamic price,
      String productImg,
      String productAmount,
      String totalPrice,
      String sellerName,
      BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('cart_item')
        .add({
      'uid': uid,
      'product_name': productName,
      'brand': brand,
      'price': price,
      'product_img': productImg,
      'product_amount': productAmount,
      'total_price': totalPrice,
      'sellerName': sellerName,
    });
  }
}