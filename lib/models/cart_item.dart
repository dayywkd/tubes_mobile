import 'product.dart';

class CartItem {
  final Product product;
  int qty;
  String size;
  final double price; 

  CartItem({
    required this.product,
    this.qty = 1,
    this.size = 'M',
    required this.price, 
  });
}