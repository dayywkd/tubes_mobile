import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../config/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = "M";

  // FUNGSI UNTUK MENGHITUNG HARGA BERDASARKAN UKURAN
  double _calculatePrice(String size, double basePrice) {
    switch (size) {
      case "S":
        return basePrice - 1000.0;
      case "L":
        return basePrice + 2000.0;
      case "M":
      default:
        return basePrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    // Hitung harga yang ditampilkan berdasarkan state ukuran
    final currentPrice = _calculatePrice(selectedSize, product.price);

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: _buildBottomBuyBar(product, cart, currentPrice),

      // SCROLLABLE BODY
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO IMAGE
              Hero(
                tag: "product-image-${product.id}",
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: Image.network(
                    product.imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(product.subtitle,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 6),
                        Text("4.8 (230)", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Description",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      "Freshly brewed ${product.name} with premium ingredients. Crafted for a rich and bold flavor.",
                      style:
                          const TextStyle(color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Text("Size",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _sizeItem("S"),
                        const SizedBox(width: 10),
                        _sizeItem("M"),
                        const SizedBox(width: 10),
                        _sizeItem("L"),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeItem(String size) {
    final active = selectedSize == size;

    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 55,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade200),
        ),
        child: Text(
          size,
          style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // FIXED BOTTOM BUTTON
  // Menerima harga yang dihitung
  Widget _buildBottomBuyBar(Product product, CartProvider cart, double finalPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      height: 120,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Price", style: TextStyle(color: Colors.grey)),
              Text(
                "IDR ${finalPrice.toInt()}", // TAMPILKAN HARGA YANG DIHITUNG
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              // KIRIM HARGA YANG DIHITUNG KE CART
              cart.add(
                product, 
                size: selectedSize, 
                calculatedPrice: finalPrice
              ); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "${product.name} added to cart (Size $selectedSize)")),
              );
            },
            child: const Text("Buy Now",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}