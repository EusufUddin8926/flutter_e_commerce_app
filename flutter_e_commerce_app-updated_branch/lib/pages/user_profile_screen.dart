import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/pages/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? userProfile;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    fullNameController.addListener(_updateSaveButtonState);
    emailController.addListener(_updateSaveButtonState);
    phoneNumberController.addListener(_updateSaveButtonState);
    addressController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    fullNameController.removeListener(_updateSaveButtonState);
    emailController.removeListener(_updateSaveButtonState);
    phoneNumberController.removeListener(_updateSaveButtonState);
    addressController.removeListener(_updateSaveButtonState);
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _updateSaveButtonState() {
    if (mounted) {
      setState(() {
        // This empty setState will trigger a rebuild,
        // which will re-evaluate _canSaveProfile()
      });
    }
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            userProfile = UserProfile(
              fullName: data['fullName'] ?? '',
              email: data['email'] ?? '',
              phoneNumber: data['phone_number'] ?? '',
              address: data['address'] ?? '',
              profilePhotoUrl: data['profilePhotoUrl'] ?? '',
              type: data['type'] ?? '',
            );
            fullNameController.text = userProfile!.fullName;
            emailController.text = userProfile!.email;
            phoneNumberController.text = userProfile!.phoneNumber;
            addressController.text = userProfile!.address;
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && userProfile != null) {
      try {
        String photoUrl = userProfile!.profilePhotoUrl;
        if (_image != null) {
          photoUrl = await _uploadProfilePhoto(user.uid);
        }

        await FirebaseFirestore.instance.collection('user').doc(user.uid).update({
          'fullName': fullNameController.text,
          'email': emailController.text,
          'phone_number': phoneNumberController.text,
          'address': addressController.text,
          'profilePhotoUrl': photoUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        _loadUserProfile();
        if (mounted) {
          setState(() {
            _isEditing = false;
          });
        }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  Future<String> _uploadProfilePhoto(String uid) async {
    final Reference storageRef = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');
    final UploadTask uploadTask = storageRef.putFile(_image!);
    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  bool _canSaveProfile() {
    return fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        addressController.text.isNotEmpty;
  }

  void _cancelEditing() {
    if (mounted) {
      setState(() {
        _isEditing = false;
        if (userProfile != null) {
          fullNameController.text = userProfile!.fullName;
          emailController.text = userProfile!.email;
          phoneNumberController.text = userProfile!.phoneNumber;
          addressController.text = userProfile!.address;
          _image = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Page'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _cancelEditing,
              ),
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isEditing
                  ? () {
                      if (_canSaveProfile()) {
                        _updateProfile();
                      }
                    }
                  : () {
                      if (mounted) {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(userProfile!.profilePhotoUrl) as ImageProvider<Object>,
                    ),
                    if (_isEditing)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              _buildTextField(fullNameController, 'Full Name'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(phoneNumberController, 'Phone Number'),
              _buildTextField(addressController, 'Address'),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Full Name'),
                subtitle: Text(userProfile!.fullName),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(userProfile!.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone Number'),
                subtitle: Text(userProfile!.phoneNumber),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Address'),
                subtitle: Text(userProfile!.address),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_box_outlined),
                title: const Text('Type'),
                subtitle: Text(userProfile!.type),
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

