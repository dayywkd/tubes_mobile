import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../config/theme.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final controller = CartController(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),

      appBar: AppBar(
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black87),
              onPressed: controller.confirmClearCart,
            )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Your Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? _emptyCart(context, controller)
                : _cartList(cart, controller),
          ),

          if (cart.items.isNotEmpty)
            _totalSection(cart, controller)
        ],
      ),
    );
  }

  // ===============================
  // UI PARTS
  // ===============================

  Widget _emptyCart(BuildContext context, CartController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Keranjang Anda kosong",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.goBack,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child:
                const Text("Mulai Memesan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _cartList(CartProvider cart, CartController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (context, i) {
        final item = cart.items[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Size: ${item.size}",
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("IDR ${(item.price * item.qty).toInt()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
                  ],
                ),
              ),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.changeQty(item, -1),
                    child: _qtyBtn(Icons.remove),
                  ),
                  const SizedBox(width: 12),
                  Text("${item.qty}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => controller.changeQty(item, 1),
                    child: _qtyBtn(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _totalSection(CartProvider cart, CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "IDR ${cart.total.toInt()}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: controller.goToOrder,
              child: const Text(
                "Lanjutkan Pemesanan",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration:
          BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}
