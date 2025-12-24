import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartController {
  final BuildContext context;

  CartController(this.context);

  CartProvider get cart => Provider.of<CartProvider>(context, listen: false);

  // Confirm clear cart
  void confirmClearCart() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear Cart"),
        content: const Text("Anda yakin ingin membersihkan keranjang?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text(
              "Bersihkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Quantity Change
  void changeQty(item, int value) {
    cart.changeQty(item, value);
  }

  // Go back to shop
  void goBack() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Continue Order
  void goToOrder() {
    Navigator.pushNamed(context, "/order");
  }
}
