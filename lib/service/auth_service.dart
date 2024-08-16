import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/helpers/di.dart';
import 'package:flutter_e_commerce_app/storage/app_pref.dart';

import '../main.dart';
import 'firestore_service.dart';

class AuthServices {
  static signupUser(String email, String password, String fullName,String address,String phone_nubmer,String type, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseAuth.instance.currentUser!.updateDisplayName(fullName);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await FirestoreServices.saveUser(fullName, email,password, userCredential.user!.uid, address,phone_nubmer,type);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful')));
      await instance<AppPreferences>().storeUserId(userCredential.user!.uid);
      await instance<AppPreferences>().saveCredentials(email, password);


      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
      const HomePage()), (Route<dynamic> route) => false);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Password Provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email Provided already Exists')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  static signinUser(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You are Logged in')));

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          const HomePage()), (Route<dynamic> route) => false);


    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password did not match')));
      }
    }
  }
}