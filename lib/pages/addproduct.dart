import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddFarmerProductPage extends StatefulWidget {
  @override
  _AddFarmerProductPageState createState() => _AddFarmerProductPageState();
}

class _AddFarmerProductPageState extends State<AddFarmerProductPage> {
  String? selectedProductId;
  Map<String, dynamic>? selectedProductData;
  List<DocumentSnapshot> ownedProducts = [];
  List<DocumentSnapshot> allProducts = [];
  String? userFullName;

  @override
  void initState() {
    super.initState();
    _checkIfFarmer();
  }

  void _checkIfFarmer() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData['type'] != 'farmer') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access denied: Farmers only')));
        Navigator.pop(context);
      } else {
        setState(() {
          userFullName = userData['fullName'] as String;
        });
        _loadProducts();
      }
    }
  }

  void _loadProducts() async {
    try {
      // Fetch the products from Firestore
      QuerySnapshot mostPopularSnapshot = await FirebaseFirestore.instance.collection('Most Popular').get();
      QuerySnapshot forYourselfSnapshot = await FirebaseFirestore.instance.collection('for yourself').get();
      QuerySnapshot allProductSnapshot = await FirebaseFirestore.instance.collection('All Product').get();

      // Create empty lists to store filtered and all products
      List<DocumentSnapshot> filteredOwnedProducts = [];
      List<DocumentSnapshot> allProductList = [];

      // Combine all snapshots into a list
      List<QuerySnapshot> snapshots = [mostPopularSnapshot, forYourselfSnapshot, allProductSnapshot];

      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch the current user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Extract the current user's UID
      String userUid = currentUser.uid;

      // Iterate over all snapshots and filter products owned by the current user
      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Check if product_owner is a list of dynamic objects
          if (data['product_owner'] is List<dynamic>) {
            List<dynamic> productOwners = data['product_owner'] as List<dynamic>;

            // Iterate over each owner and check if the current user is one of them
            for (var owner in productOwners) {
              if (owner is Map<String, dynamic> && owner['uId'] == userUid) {
                filteredOwnedProducts.add(doc);
                break;
              }
            }
          }

          // Add the product to the complete list of products
          allProductList.add(doc);
        }
      }

      // Ensure the widget is still mounted before updating the state
      if (!mounted) return;

      // Update the state with the filtered and all products
      setState(() {
        ownedProducts = filteredOwnedProducts;
        allProducts = allProductList;
      });
    } catch (e) {
      // Show an error message if there's an exception
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য সমূহ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('আপনার পণ্যগুলো', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (ownedProducts.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ownedProducts.length,
                itemBuilder: (context, index) {
                  final document = ownedProducts[index];
                  final data = document.data() as Map<String, dynamic>;
                  final categoryName = document.reference.parent.id;

                  return Dismissible(
                    key: Key(document.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        ownedProducts.removeAt(index);
                      });
                      removeItem(document);
                    },
                    background: Container(
                      color: Colors.red.withOpacity(0.15),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    child: ListTile(
                      title: Text('${data['product_name']} ($categoryName)'),
                      subtitle: Text('Brand: ${data['brand']} | Price: ${data['product_price']}'),
                      leading: Image.network(data['product_img'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                  );
                },
              )
            else
              const Text('দুঃখিত এই মুহূর্তে আপনার কোন পণ্য নেই'),

            const SizedBox(height: 20),
            const Text('নতুন পণ্য যোগ করুন', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedProductId,
              hint: const Text('পণ্য যোগ করুন'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedProductId = newValue;
                  selectedProductData = allProducts
                      .firstWhere((doc) => doc.id == selectedProductId)
                      .data() as Map<String, dynamic>?;
                });
              },
              items: allProducts.map<DropdownMenuItem<String>>((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String categoryName = document.reference.parent.id;
                return DropdownMenuItem<String>(
                  value: document.id,
                  child: Text('${data['product_name']} ($categoryName)'),
                );
              }).toList(),
              validator: (value) => value == null ? 'পণ্য যোগ করুন' : null,
            ),
            const SizedBox(height: 20),
            if (selectedProductData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Name: ${selectedProductData!['product_name']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Brand: ${selectedProductData!['brand']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Price: ${selectedProductData!['product_price']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Image.network(selectedProductData!['product_img']),
                ],
              ),
            const SizedBox(height: 20),
            if (selectedProductId != null)
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('যোগ করুন'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void removeItem(DocumentSnapshot document) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final String productId = document.id;
      final String userUid = currentUser.uid;

      // Reference to the product document
      DocumentReference productRef =
      FirebaseFirestore.instance.collection(document.reference.parent.id).doc(productId);

      // Fetch product data
      DocumentSnapshot productDoc = await productRef.get();
      if (!productDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product does not exist')),
        );
        return;
      }

      Map<String, dynamic>? productData = productDoc.data() as Map<String, dynamic>?;
      if (productData == null || !productData.containsKey('product_owner')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product data is invalid')),
        );
        return;
      }

      // List of owners (ensure proper casting)
      List<dynamic> productOwners = List.from(productData['product_owner']);
      print("Product Owners: $productOwners");

      // Check if the current user is an owner
      bool isOwnerExist = productOwners.any(
            (owner) => owner is Map<String, dynamic> && owner['uId'].toString() == userUid,
      );
      print("Is Owner Exist: $isOwnerExist");

      if (isOwnerExist) {
        // Remove current user from the product owners list
        productOwners.removeWhere(
              (owner) => owner is Map<String, dynamic> && owner['uId'].toString() == userUid,
        );

        // Update the product data in Firestore
        await productRef.update({'product_owner': productOwners});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পণ্যটি আপডেট করা হয়েছে')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('আপনি এই পণ্যটির মালিক নন')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }




  void _submitForm() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    if (selectedProductId == null || selectedProductData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No product selected')));
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User profile not found')));
        return;
      }



      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userFullName = userData['fullName'] as String;
      String userUid = currentUser.uid;


      DocumentSnapshot selectedDoc = allProducts.firstWhere((doc) => doc.id == selectedProductId);
      String collectionId = selectedDoc.reference.parent.id;

      DocumentReference productRef = FirebaseFirestore.instance.collection(collectionId).doc(selectedProductId!);

      DocumentSnapshot productDoc = await productRef.get();
      if (!productDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product data not found')));
        EasyLoading.dismiss();
        return;
      }

      Map<String, dynamic>? productData = productDoc.data() as Map<String, dynamic>?;

      List<dynamic> productOwners = [];
      if (productData != null) {
        EasyLoading.show(status: "পণ্য যোগ করা হচ্ছে...");

        productOwners = productData['product_owner'] as List<dynamic>;
        bool isOwnerExist = false;
        for (var owner  in productOwners) {
          if (owner is Map<String, dynamic> && owner['uId'] == userUid) {
            isOwnerExist = true;
            break;
          }
        }
        if (isOwnerExist) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have already added this product')));
          setState(() {
            selectedProductId = null;
            selectedProductData = null;
          });
          return;
        } else {
          productOwners.add({
            'name': userFullName,
            'uId': userUid,
          });
        }

        await productRef.update({'product_owner': productOwners});
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পণ্যটি সফলভাবে আপডেট করা হয়েছে')));
        _loadProducts();

        setState(() {
          selectedProductId = null;
          selectedProductData = null;
        });

      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product data not found')));
        return;
      }


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    }
  }

}