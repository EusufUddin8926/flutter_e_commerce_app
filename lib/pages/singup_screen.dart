import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/signin_screen.dart';

import '../Utils/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                backgroundColor2,
                backgroundColor2,
                backgroundColor4,
              ],
            ),
          ),
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                    Text(
                      "Registration Screen",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: textColor1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Wellcome back vou've\nbeen missed!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: textColor2, height: 1.2),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
                    // for username and password
                    myTextField("Enter Email", Colors.white),
                    myTextField("Password", Colors.black26),
                    myTextField("Enter Full Name", Colors.white),
                    myTextField("Enter Address", Colors.white),
                    myTextField("Enter Phone Number", Colors.white),
                    SizedBox(height: MediaQuery.sizeOf(context).height*0.03,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          // for sign in button
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                "Registration",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                          /*SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                          *//*Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 2,
                                width: MediaQuery.sizeOf(context).width * 0.2,
                                color: Colors.black12,
                              ),
                              Text(
                                "  Or continue with   ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor2,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.sizeOf(context).width * 0.2,
                                color: Colors.black12,
                              ),
                            ],
                          ),*//*
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              socialIcon("images/google.png"),
                              socialIcon("images/apple.png"),
                              socialIcon("images/facebook.png"),
                            ],
                          ),*/
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.07),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
                            },
                            child: Text.rich(
                              TextSpan(
                                  text: "Already have account? ",
                                  style: TextStyle(
                                    color: textColor2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  children:  const [
                                    TextSpan(
                                      text: "login",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),)]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Container myTextField(String hint, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontSize: 19,
            ),
            suffixIcon: Icon(
              Icons.visibility_off_outlined,
              color: color,
            )),
      ),
    );
  }
}
