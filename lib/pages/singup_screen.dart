import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/signin_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../Utils/colors.dart';
import '../helpers/network_info.dart';
import '../service/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  late NetworkInfo _networkInfo;
  String? _selectedRole; // Variable to hold the selected role
  final List<String> _roles = ['consumer', 'farmer']; // Dropdown options

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
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
                            child: Column(
                              children: [
                                // Add logo here
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 200, // Adjust the height as needed
                                  width: 200, // Adjust the width as needed
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
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
                                  "কৃষিতে আপনাকে স্বাগতম",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: textColor2,
                                      height: 1.2),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.08),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedRole,
                                    hint: const Text('Select Role'),
                                    items: _roles.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03),
                                myTextField("Enter Email", Colors.white,emailController),
                                myTextField("Password", Colors.black26,passwordController),
                                myTextField("Enter Full Name", Colors.white,fullNameController),
                                myTextField("Enter Address", Colors.white,addressController),
                                myTextField("Enter Phone Number", Colors.white,phoneNumberController),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.03,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Column(
                                    children: [
                                      // for sign in button
                                      GestureDetector(
                                        onTap: () async {
                                          if (_selectedRole == null ||
                                              _selectedRole!.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'First select Role!')));
                                            return;
                                          }

                                          if (emailController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Email is Required!')));
                                            return;
                                          }
                                          if (passwordController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Password is Required!')));
                                            return;
                                          }
                                          if (fullNameController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Name is Required!')));
                                            return;
                                          }
                                          if (addressController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Address is Required!')));
                                            return;
                                          }
                                          if (phoneNumberController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Phone number is Required!')));
                                            return;
                                          }
                                          if (!await _networkInfo.isConnected) {
                                            const snackbar = SnackBar(
                                              content: Text(
                                                  "No internet available!"),
                                              duration:
                                              Duration(seconds: 5),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                            return;
                                          }

                                          AuthServices.signupUser(
                                              emailController.text.toString(),
                                              passwordController.text.toString(),
                                              fullNameController.text.toString(),
                                              addressController.text.toString(),
                                              phoneNumberController.text.toString(),
                                              _selectedRole!,
                                              "https://cdn-icons-png.flaticon.com/512/21/21104.png",
                                              context
                                          );
                                        },
                                        child: Container(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          decoration: BoxDecoration(
                                            color: buttonColor,
                                            borderRadius:
                                            BorderRadius.circular(15),
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
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.07),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const SignInScreen()));
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                              text:
                                              "Already have account? ",
                                              style: TextStyle(
                                                color: textColor2,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              children: const [
                                                TextSpan(
                                                  text: "login",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }

  Container myTextField(
      String hint, Color color, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: TextField(
        controller: controller,
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
