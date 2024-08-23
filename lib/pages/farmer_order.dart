import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_e_commerce_app/models/order_model.dart';

class FarmerOrdersPage extends StatefulWidget {
  const FarmerOrdersPage({Key? key}) : super(key: key);

  @override
  _FarmerOrdersPageState createState() => _FarmerOrdersPageState();
}

class _FarmerOrdersPageState extends State<FarmerOrdersPage> {
  String selectedStatus = 'All';
  String userFullName = "";

  @override
  void initState() {
    super.initState();
    getFarmerName();
  }

  Future<void> getFarmerName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'user').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          userFullName = userData['fullName'] as String;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          items: <String>['All', 'Pending', 'Order Taken', 'On the way', 'Delivered']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userFullName.isNotEmpty
            ? FirebaseFirestore.instance
            .collection('Order')
            .where('sellerName', isEqualTo: userFullName)
            .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          List<OrderModel> orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          List<OrderModel> filteredOrders = selectedStatus == 'All'
              ? orders
              : orders.where((order) => order.orderStatus == selectedStatus).toList();

          return ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              return FarmerOrderItem(orderModel: filteredOrders[index]);
            },
          );
        },
      ),
    );
  }
}

class FarmerOrderItem extends StatefulWidget {
  final OrderModel orderModel;

  const FarmerOrderItem({super.key, required this.orderModel});

  @override
  _FarmerOrderItemState createState() => _FarmerOrderItemState();
}

class _FarmerOrderItemState extends State<FarmerOrderItem> {
  bool _isLoading = false;

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Order')
          .doc(widget.orderModel.orderId)
          .update({'orderStatus': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            Text(
              widget.orderModel.productName,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Order ID: ${widget.orderModel.orderId}'),
            const SizedBox(height: 8.0),
            Text('Customer: ${widget.orderModel.customerName}'),
            const SizedBox(height: 8.0),
            Text('Delivery Address: ${widget.orderModel.shippingAddress}'),
            const SizedBox(height: 8.0),
            Text('Total Price: \$${widget.orderModel.total_price}'),
            const SizedBox(height: 8.0),
            Text('Status: ${widget.orderModel.orderStatus}'),
            const SizedBox(height: 8.0),
            if (widget.orderModel.orderStatus == 'Pending')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('Order Taken'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Order'),
              ),
            if (widget.orderModel.orderStatus == 'Order Taken')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('On the way'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Dispatch Order'),
              ),
            if (widget.orderModel.orderStatus == 'On the way')
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateOrderStatus('Delivered'),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Mark as Delivered'),
              ),
          ],
        ),
      ),
    );
  }
}
