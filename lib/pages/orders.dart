import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String brand;
  final String details;
  final String id;
  final String imageURL;
  final String owner;
  final int price;

  Product({
    required this.name,
    required this.brand,
    required this.details,
    required this.id,
    required this.imageURL,
    required this.owner,
    required this.price,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Product(
      name: data['product_name'] ?? '',
      brand: data['brand'] ?? '',
      details: data['product_details'] ?? '',
      id: data['product_id'] ?? '',
      imageURL: data['product_img'] ?? '',
      owner: data['product_owner'][0] ?? '',
      price: data['product_price'] ?? 0,
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('All Product').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text("No products found"));
          }

          final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductItem(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Quantity: ${product.id}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${product.details}'), // Assuming product details represent status
                      SizedBox(height: 4.0),
                      LinearProgressIndicator(
                        value: getStatusProgress(product.details), // Change this to actual status field if available
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Text(
                  'Total Price: \$${product.price}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double getStatusProgress(String status) {
    switch (status) {
      case 'Delivered':
        return 1.0;
      case 'On the way':
        return 0.5;
      case 'Order taken':
        return 0.2;
      default:
        return 0.0;
    }
  }
}
