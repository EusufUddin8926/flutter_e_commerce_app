import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/Utils/constant.dart';
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
  final List<String> _roles = ['consumer', 'farmer'];
  String? dropdownValue;
  String? selectedValue;
  String _selectedAddress = "";
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(InternetConnectionChecker());
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: MediaQuery.of(context).size.height,
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
                // Add logo here
                Image.asset(
                  'assets/images/logo.png',
                  height: 200, // Adjust the height as needed
                  width: 200, // Adjust the width as needed
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  "রেজিস্ট্রেশন পেজ",
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
                  style:
                      TextStyle(fontSize: 18, color: textColor2, height: 1.2),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('রোল সিলেক্ট করুন'),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Autocomplete Text Field
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            } else {
                              return Constant.districtList.where((word) => word
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase()));
                            }
                          },
                          onSelected: (selectedString) {
                            setState(() {
                              _selectedAddress = selectedString; // Always set the selected address
                              addressController.clear();
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                            controller.text = "";

                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                hintText: "ঠিকানা খুঁজুন",
                                prefixIcon: const Icon(Icons.search),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        // Chips Display
                        Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _selectedAddress != ""
                                ? [
                              Chip(
                                label: Text(_selectedAddress),
                                onDeleted: () {
                                  setState(() {
                                    _selectedAddress = ""; // Clear the selected address
                                  });
                                },
                              ),
                            ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                // for username and password
                myTextField("ইমেইল দিন", Colors.white, emailController, false),
                myTextField("পাসওয়ার্ড", Colors.black26, passwordController, true),
                myTextField(
                    "পুরো নাম দিন", Colors.white, fullNameController, false),
                myTextField(
                    "ফোন নাম্বার দিন", Colors.white, phoneNumberController, false),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // for sign in button
                      GestureDetector(
                        onTap: () async{
                          if(_selectedRole == null || _selectedRole!.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রোল সিলেক্ট করুন!')));
                            return;
                          }

                          if(emailController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ইমেইল প্রয়োজন!')));
                            return;
                          }
                          if(passwordController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড প্রয়োজন!')));
                            return;
                          }
                          if(fullNameController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নাম প্রয়োজন!')));
                            return;
                          }
                          if(_selectedAddress.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ঠিকানা প্রয়োজন। অনুগ্রহ করে ঠিকানা দিন!')));
                            return;
                          }
                          if(phoneNumberController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ফোন নাম্বার প্রয়োজন!')));
                            return;
                          }

                          if(!await _networkInfo.isConnected){
                            const snackbar = SnackBar(
                              content: Text("ইন্টারনেট পাওয়া যাচ্ছে না!"),
                              duration: Duration(seconds: 5),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                            return;
                          }

                          AuthServices.signupUser(
                              emailController.text.toString(),
                              passwordController.text.toString(),
                              fullNameController.text.toString(),
                              _selectedAddress,
                              phoneNumberController.text.toString(),
                              _selectedRole!,
                              "https://cdn-icons-png.flaticon.com/512/21/21104.png",
                              context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "রেজিস্ট্রেশন",
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
                          height: MediaQuery.of(context).size.height * 0.07),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        },
                        child: Text.rich(
                          TextSpan(
                              text: "আগের একাউন্ট আছে? ",
                              style: TextStyle(
                                color: textColor2,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              children: const [
                                TextSpan(
                                  text: "লগইন করুন",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ]),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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

  Container myTextField(String hint, Color color, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
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
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
              color: color,
            ),
            onPressed: _togglePasswordVisibility,
          )
              : null,
        ),
      ),
    );
  }
}