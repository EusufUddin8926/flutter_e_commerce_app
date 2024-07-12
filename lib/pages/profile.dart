import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/signin_screen.dart';
import 'package:flutter_e_commerce_app/pages/user_profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.yellow.withOpacity(0.1),
        title: Text('Profile Page', style: TextStyle(color: Colors.black)),
      ),*/
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return UserProfileScreen();
          }else{
            return SignInScreen();
          }
        },
      )
    );
  }
}
