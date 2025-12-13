import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../config/theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        // Tambahkan tombol hapus keranjang
        actions: [
          if (cart.items.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: () {
              // Dialog konfirmasi sebelum membersihkan
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
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
                      child: const Text("Bersihkan", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("Keranjang Anda kosong", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                          child: const Text("Mulai Memesan", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
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
                            BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              // Catatan: Asumsi image_url adalah network URL dari Supabase
                              child: Image.network(
                                item.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // NAME + SUBTITLE
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
                                  // PERBAIKAN: Menggunakan item.price (harga unit yang disesuaikan)
                                  Text("IDR ${(item.price * item.qty).toInt()}", 
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary)),
                                ],
                              ),
                            ),

                            // QTY CONTROL
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => cart.changeQty(item, -1),
                                  child: _qtyBtn(Icons.remove),
                                ),
                                const SizedBox(width: 12),
                                Text("${item.qty}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => cart.changeQty(item, 1),
                                  child: _qtyBtn(Icons.add),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // -------- TOTAL & CHECKOUT ----------
          if (cart.items.isNotEmpty)
          Container(
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // PERBAIKAN: cart.total kini sudah menghitung dari harga yang disesuaikan
                    Text("IDR ${cart.total.toInt()}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
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
                    onPressed: () {
                      // Navigasi ke OrderScreen
                      Navigator.pushNamed(context, "/order"); 
                    },
                    child: const Text(
                      "Lanjutkan Pemesanan",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: Colors.grey.shade200, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}