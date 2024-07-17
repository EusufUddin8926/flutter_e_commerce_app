import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Product {
  final String status;
  final String name;
  final String brand;
  final String details;
  final String id;
  final String imageURL;
  final String owner;
  final int price;

  Product({
    required this.status,
    required this.name,
    required this.brand,
    required this.details,
    required this.id,
    required this.imageURL,
    required this.owner,
    required this.price,
  });
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final List<Product> products = [
    Product(
      status: 'On the way',
      name: 'মসুর ডাল',
      brand: 'Dal',
      details:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae nulla erat. Nullam et velit nec neque luctus dapibus ac at velit.',
      id: '1720730211',
      imageURL:
          'https://images.othoba.com/images/thumbs/0106868_mushur-dal-loose-1kg.jpeg',
      owner: 'Md Siyamul islam',
      price: 139,
    ),
    Product(
      status: 'Delivered',
      name: 'কাটারী ভোগ',
      brand: 'Chal',
      details:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae nulla erat. Nullam et velit nec neque luctus dapibus ac at velit.',
      id: '1720730212',
      imageURL:
          'https://chefcart.com.bd/wp-content/uploads/2019/05/Najirshail-Rice-1.jpg',
      owner: 'Md Eusuf Uddin',
      price: 60,
    ),
    Product(
      status: 'Order taken',
      name: 'কাটারী ভোগ',
      brand: 'Chal',
      details:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae nulla erat. Nullam et velit nec neque luctus dapibus ac at velit.',
      id: '1720730213',
      imageURL:
          'https://chefcart.com.bd/wp-content/uploads/2019/05/Najirshail-Rice-1.jpg',
      owner: 'Md Eusuf Uddin',
      price: 60,
    ),
  ];

  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = selectedStatus == 'All'
        ? products
        : products.where((product) => product.status == selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: DropdownButton<String>(
          value: selectedStatus,
          onChanged: (String? newValue) {
            setState(() {
              selectedStatus = newValue!;
            });
          },
          items: <String>['All', 'On the way', 'Delivered', 'Order taken']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return ProductItem(product: filteredProducts[index]);
        },
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  double _rating = 0;
  bool _ratingSubmitted = false;

  void _submitRating() {
    setState(() {
      _ratingSubmitted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating submitted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'orderID: ${widget.product.id}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Owner: ${widget.product.owner}'), // Assuming product details represent status
                      // SizedBox(height: 4.0),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Text(
                  'Total Price: \$${widget.product.price}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${widget.product.status}'),
                       // Assuming product details represent status
                      const SizedBox(height: 4.0),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: getStatusProgress(widget.product.status),
                        ),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.product.status == 'Delivered' && !_ratingSubmitted) ...[
              const SizedBox(height: 8.0),
              const Text('Rate this product:'),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _submitRating,
                child: const Text('Submit'),
              ),
            ] else if (_ratingSubmitted) ...[
              const SizedBox(height: 8.0),
              RatingBarIndicator(
                rating: _rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 24.0,
              ),
            ],
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
        return 0.66;
      case 'Order taken':
        return 0.33;
      default:
        return 0.0;
    }
  }
}
