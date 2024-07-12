import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static saveUser(String name, email, password,  uid, String address, phoneNumber) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .set({'uId': uid,'email': email, 'password': password,'fullName': name,  'address': address, 'phone_number': phoneNumber });
  }
}