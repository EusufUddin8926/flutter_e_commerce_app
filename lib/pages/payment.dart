import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/payment_success.dart';

import '../animation/FadeAnimation.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int activeCard = 0;
  bool _isLoading = false;
  bool _showAddressField = false; // State variable to control the visibility of the address field
  late Timer _timer;

  pay() {
    setState(() {
      _isLoading = true;
    });

    const oneSec = Duration(seconds: 2);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          _isLoading = false;
          timer.cancel();
          Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentSuccess()));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('পেমেন্ট', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              activeCard == 0
                  ? FadeAnimation(
                      1.2,
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: activeCard == 0 ? 1 : 0,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightGreen,
                                Colors.lightGreen.shade800,
                                Colors.lightGreen.shade900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ক্রেডিট/ডেবিট কার্ড",
                                style: TextStyle(color: Colors.white),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "**** **** **** 7890",
                                    style: TextStyle(color: Colors.white, fontSize: 30),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Credit/Debit Card",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Image.network('https://img.icons8.com/color/2x/mastercard-logo.png',
                                          height: 50),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : activeCard == 1
                      ? FadeAnimation(
                          1.2,
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity: activeCard == 1 ? 1 : 0,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              padding: EdgeInsets.all(30.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                    Colors.grey.shade200,
                                    Colors.grey.shade300,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset('assets/images/cod.png', height: 50),
                                      SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Cash on delivery",
                                            style: TextStyle(color: Colors.black, fontSize: 18),
                                          ),
                                          Image.asset('assets/images/cod.png', height: 35),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : FadeAnimation(
                          1.2,
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity: activeCard == 2 ? 1 : 0,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              padding: EdgeInsets.all(30.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                    Colors.grey.shade200,
                                    Colors.grey.shade300,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset('assets/images/bkash.png', height: 50),
                                      SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Bkash",
                                            style: TextStyle(color: Colors.black, fontSize: 18),
                                          ),
                                          Image.asset('assets/images/bkash.png', height: 35),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
              SizedBox(height: 50),
              FadeAnimation(
                1.2,
                Text(
                  "পেমেন্ট পদ্ধতি",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              FadeAnimation(
                1.3,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCard = 0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: activeCard == 0
                              ? Border.all(color: Colors.grey.shade300, width: 1)
                              : Border.all(color: Colors.grey.shade300.withOpacity(0), width: 1),
                        ),
                        child: Image.network('https://img.icons8.com/color/2x/mastercard-logo.png', height: 50),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCard = 1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: activeCard == 1
                              ? Border.all(color: Colors.grey.shade300, width: 1)
                              : Border.all(color: Colors.grey.shade300.withOpacity(0), width: 1),
                        ),
                        child: Text("COD"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCard = 2;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: activeCard == 2
                              ? Border.all(color: Colors.grey.shade300, width: 1)
                              : Border.all(color: Colors.grey.shade300.withOpacity(0), width: 1),
                        ),
                        child: Text("Bkash"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              FadeAnimation(
                1.4,
                Container(
                  height: 50,
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "অফার",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("কোড দিন"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeAnimation(
                1.5,
                Column(
                  children: [
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "শিপিং ঠিকানা",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _showAddressField = !_showAddressField;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_showAddressField)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'শিপিং ঠিকানা লিখুন',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 100,),
              FadeAnimation(1.5, Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("মোট পেমেন্ট", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                  Text("\৳526.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ],
              )),
              SizedBox(height: 20),
              FadeAnimation(
                1.6,
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : pay,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'পেমেন্ট করুন',
                            style: TextStyle(fontSize: 18),
                          ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
