// lib/screens/product_cart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';
import '../config/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "product-image-${product.id}",
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl.startsWith("assets/")
                    ? Image.asset(
                        product.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        product.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(product.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "IDR ${product.price.toInt()}",
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          // PERBAIKAN: Menyediakan calculatedPrice
                          cart.add(
                            product, 
                            size: "M",
                            calculatedPrice: product.price // Menggunakan harga dasar untuk ukuran 'M'
                          );

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("${product.name} added to cart"),
                            duration: const Duration(seconds: 1),
                          ));
                        },
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}