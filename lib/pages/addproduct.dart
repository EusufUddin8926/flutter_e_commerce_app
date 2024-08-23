import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      QuerySnapshot mostPopularSnapshot = await FirebaseFirestore.instance.collection('Most Popular').get();
      QuerySnapshot forYourselfSnapshot = await FirebaseFirestore.instance.collection('for yourself').get();
      QuerySnapshot allProductSnapshot = await FirebaseFirestore.instance.collection('All Product').get();

      List<DocumentSnapshot> filteredOwnedProducts = [];
      List<DocumentSnapshot> allProductList = [];

      List<QuerySnapshot> snapshots = [mostPopularSnapshot, forYourselfSnapshot, allProductSnapshot];

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['product_owner'] is List) {
            List<dynamic> owners = List<dynamic>.from(data['product_owner'] as List);
            if (owners.contains(userFullName)) {
              filteredOwnedProducts.add(doc);
            }
          }
          allProductList.add(doc);
        }
      }

      setState(() {
        ownedProducts = filteredOwnedProducts;
        allProducts = allProductList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (ownedProducts.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ownedProducts.length,
                itemBuilder: (context, index) {
                  final document = ownedProducts[index];
                  final data = document.data() as Map<String, dynamic>;
                  final categoryName = _getCategoryName(document);

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
              const Text('You do not own any products.'),
            const SizedBox(height: 20),
            const Text('Add New Product', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedProductId,
              hint: const Text('Select a product'),
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
                String categoryName = _getCategoryName(document);
                return DropdownMenuItem<String>(
                  value: document.id,
                  child: Text('${data['product_name']} ($categoryName)'),
                );
              }).toList(),
              validator: (value) => value == null ? 'Please select a product' : null,
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
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Product'),
              ),
          ],
        ),
      ),
    );
  }

  void removeItem(DocumentSnapshot document) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      final productId = document.id;
      final categoryName = _getCategoryName(document);

      DocumentReference productRef = FirebaseFirestore.instance.collection(categoryName).doc(productId);

      DocumentSnapshot productDoc = await productRef.get();
      Map<String, dynamic>? productData = productDoc.data() as Map<String, dynamic>?;

      if (productData != null && productData['product_owner'] is List) {
        List<dynamic> productOwners = List<dynamic>.from(productData['product_owner'] as List);

        if (productOwners.contains(userFullName)) {
          productOwners.remove(userFullName);

          await productRef.update({
            'product_owner': productOwners,
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product ownership updated')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not own this product')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product owner data is invalid')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    }
  }

  String _getCategoryName(DocumentSnapshot document) {
    final parentId = document.reference.parent.id;
    switch (parentId) {
      case 'Most Popular':
        return 'Most Popular';
      case 'for yourself':
        return 'For Yourself';
      case 'All Product':
        return 'All Product';
      default:
        return 'Unknown';
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

      DocumentSnapshot selectedDoc = allProducts.firstWhere((doc) => doc.id == selectedProductId);
      String categoryName = _getCategoryName(selectedDoc);
      DocumentReference productRef = FirebaseFirestore.instance.collection(categoryName).doc(selectedProductId);

      DocumentSnapshot productDoc = await productRef.get();
      Map<String, dynamic>? productData = productDoc.data() as Map<String, dynamic>?;

      if (productData != null && productData['product_owner'] is List) {
        List<dynamic> productOwners = List<dynamic>.from(productData['product_owner'] as List);

        if (!productOwners.contains(userFullName)) {
          productOwners.add(userFullName);

          await productRef.update({
            'product_owner': productOwners,
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You already own this product')));
        }
      } else {
        await productRef.update({
          'product_owner': [userFullName],
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
    } finally {
      // Reset the selected product regardless of success or failure
      setState(() {
        selectedProductId = null;
        selectedProductData = null;
      });

      _loadProducts(); // Refresh the list of owned products
    }
  }

}