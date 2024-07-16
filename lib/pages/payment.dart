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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentSuccess()));
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
        title: const Text('পেমেন্ট', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              activeCard == 0
                  ? FadeAnimation(
                      1.2,
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: activeCard == 0 ? 1 : 0,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          padding: const EdgeInsets.all(20.0),
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
                              const Text(
                                "ক্রেডিট/ডেবিট কার্ড",
                                style: TextStyle(color: Colors.white),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "**** **** **** 7890",
                                    style: TextStyle(color: Colors.white, fontSize: 30),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
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
                            duration: const Duration(milliseconds: 500),
                            opacity: activeCard == 1 ? 1 : 0,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              padding: const EdgeInsets.all(30.0),
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
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
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
                            duration: const Duration(milliseconds: 500),
                            opacity: activeCard == 2 ? 1 : 0,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              padding: const EdgeInsets.all(30.0),
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
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
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
              const SizedBox(height: 50),
              FadeAnimation(
                1.2,
                const Text(
                  "পেমেন্ট পদ্ধতি",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
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
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: activeCard == 1
                              ? Border.all(color: Colors.grey.shade300, width: 1)
                              : Border.all(color: Colors.grey.shade300.withOpacity(0), width: 1),
                        ),
                        child: const Text("COD"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCard = 2;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: activeCard == 2
                              ? Border.all(color: Colors.grey.shade300, width: 1)
                              : Border.all(color: Colors.grey.shade300.withOpacity(0), width: 1),
                        ),
                        child: const Text("Bkash"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              FadeAnimation(
                1.4,
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     const Text(
                        "অফার",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("কোড দিন"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeAnimation(
                1.5,
                Column(
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "শিপিং ঠিকানা",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
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
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
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
              const SizedBox(height: 100,),
              FadeAnimation(1.5, const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("মোট পেমেন্ট", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                  Text("\৳526.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ],
              )),
              const SizedBox(height: 20),
              FadeAnimation(
                1.6,
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : pay,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'পেমেন্ট করুন',
                            style: TextStyle(fontSize: 18),
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
