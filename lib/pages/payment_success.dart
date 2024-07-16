
import 'package:flutter/material.dart';

import '../animation/FadeAnimation.dart';
import '../main.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({Key? key}) : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(40.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeAnimation(1, Image.network('https://ouch-cdn2.icons8.com/7fkWk5J2YcodnqGn62xOYYfkl6qhmsCfT2033W-FjaA/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMjU5/LzRkM2MyNzJlLWFh/MmQtNDA3Ni04YzU0/LTY0YjNiMzQ4NzQw/OS5zdmc.png',
              width: 250,)),
            SizedBox(height: 50.0,),
            FadeAnimation(1.2, Text('পেমেন্ট সফল হয়েছে! 🥳', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),)),
            SizedBox(height: 20.0,),
            FadeAnimation(1.3, Text('আপনার পেমেন্ট \n সফলভাবে সম্পন্ন হয়েছে..', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Colors.grey.shade700),)),
            SizedBox(height: 140.0,),
            FadeAnimation(1.4,
              MaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                height: 50,
                elevation: 0,
                splashColor: Colors.lightGreen[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                color: Colors.lightGreen[800],
                child: Center(
                  child: Text("হোমে ফিরে যান", style: TextStyle(color: Colors.white, fontSize: 16),),
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            FadeAnimation(1.4, Text('ধন্যবাদ আমাদের সাথে থাকার জন্য', style: TextStyle(fontSize: 14.0, color: Colors.grey),)),
          ],
        ),
      ),
    );
  }
}
