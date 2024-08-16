class Product {
  final String uid;
  final String product_name;
  final String brand;
  final String product_img;
  final String sellerName;
  String product_amount;
  final int price;
  double total_price;

  Product({
    required this.uid,
    required this.product_name,
    required this.brand,
    required this.product_img,
    required this.sellerName,
    required this.product_amount,
    required this.price,
    required this.total_price
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      uid: json["uid"] as String,
      product_name: json["product_name"] as String,
      brand: json["brand"] as String,
      product_img: json["product_img"] as String,
      sellerName: json["sellerName"] as String,
      product_amount: json["product_amount"] as String,
      price: json["price"] as int,
      total_price: (json["total_price"] as num).toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "product_name": product_name,
      "brand": brand,
      "product_img": product_img,
      "sellerName": sellerName,
      "product_amount": product_amount,
      "price": price,
      "total_price": total_price
    };
  }

  @override
  String toString() {
    return 'Product{uid: $uid, product_name: $product_name, brand: $brand, product_img: $product_img, sellerName: $sellerName, product_amount: $product_amount, price: $price, total_price: $total_price}';
  }
}