// lib/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart'; // IMPORT WAJIB

import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import 'package:toko_kopi_sembilan/screens/payment_succes_screen.dart';
import '../controllers/notification_controller.dart'; // IMPORT WAJIB

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Redirect jika keranjang kosong
    if (cart.items.isEmpty) {
      if (mounted) {
        Future.microtask(() => Navigator.pop(context));
      }
      return const Scaffold(body: Center(child: Text("Keranjang kosong. Mengarahkan...")));
    }
    
    // Perhitungan Ringkasan
    final totalHarga = cart.total;
    final tax = totalHarga * 0.1;
    const discount = 5000.0;
    final totalBayar = totalHarga + tax - discount;


    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Konfirmasi Pesanan", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ---------- CASHIER INFO BOX ----------
            _cashierInfoBox(context),

            const SizedBox(height: 20),

            // ---------- TOP BUTTONS ----------
            Row(
              children: [
                _topButton(icon: Icons.edit, label: "Edit Order", onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                _topButton(icon: Icons.note_add_outlined, label: "Add Note", onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Tambah Catatan belum diimplementasikan")));
                }),
              ],
            ),

            const SizedBox(height: 20),

            // ---------- ITEM LIST ----------
            const Text(
              "Daftar Pesanan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...cart.items.map((item) {
              return _orderItem(item);
            }).toList(),

            const SizedBox(height: 20),

            // ---------- DISCOUNT CARD ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  const Text("1 Diskon Diterapkan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------- PAYMENT SUMMARY ----------
            const Text(
              "Ringkasan Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            _summaryRow("Total Harga Barang", totalHarga.toInt()),
            _summaryRow("Pajak (10%)", tax.toInt()),
            _summaryRow("Diskon", -discount.toInt(), isDiscount: true),

            const Divider(height: 20),
            
            _summaryRow("Total Pembayaran", totalBayar.toInt(), isTotal: true),

            const SizedBox(height: 20),

            // ---------- PAYMENT METHOD ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Metode Pembayaran",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        "Bayar di Kasir (Tunai / Dompet Digital)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------- PLACE ORDER BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // Tombol selalu aktif
                onPressed: () async {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Memproses pesanan (Test Mode)...")),
                  );
                  
                  // --- BYPASS SUPABASE UNTUK TESTING NOTIFIKASI ---
                  
                  // 1. Pura-pura loading selama 2 detik
                  await Future.delayed(const Duration(seconds: 2));

                  // 2. Anggap selalu sukses
                  /* final success = await OrderService.sendOrder(
                    tableId: "CASHIER-ORDER",
                    items: cart.items,
                  );
                  */
                  const success = true; // Kita paksa true

                  if (success) {
                    
                    // [PENTING] PANGGIL SIMULASI NOTIFIKASI
                    // Ini akan memicu notifikasi "Diterima" -> "Diracik" -> "Siap"
                    // Pastikan Controller sudah di-put di main.dart
                    try {
                       Get.find<NotificationController>().simulateOrderProgress();
                    } catch (e) {
                      print("Gagal memanggil notifikasi: $e");
                    }

                    // TAMPILKAN POP-UP NOTIFIKASI SUKSES
                    await showDialog(
                      context: context,
                      barrierDismissible: false, 
                      builder: (context) => AlertDialog(
                        title: const Text("Pesanan Terkirim!"),
                        content: const Text("Pesanan (Test) berhasil. Notifikasi status akan muncul bertahap."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text("OK", style: TextStyle(color: AppTheme.primary)),
                          ),
                        ],
                      ),
                    );
                    
                    // Navigasi ke layar sukses
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentSuccessScreen(),
                      ),
                    );
                    cart.clear();
                  } 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Pesan & Bayar (Test Notif)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================
  
  Widget _cashierInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: const [
          Icon(Icons.point_of_sale, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mode Pemesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  "Pesanan dicatat di Kasir. ID Pesanan: CASHIER-ORDER",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _topButton({required IconData icon, required String label, required Function() onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 6),
              Text(label,
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderItem(item) {
    final isLocalAsset = item.product.imageUrl.startsWith("assets/");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isLocalAsset
                ? Image.asset(
                    item.product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Image.network(
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
                Text("${item.qty}x ${item.product.name}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Size: ${item.size} - IDR ${item.price.toInt()}", 
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(
            "IDR ${(item.price * item.qty).toInt()}", 
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 15),
          ),
        ],
      ),
    );
  }


  Widget _summaryRow(String label, int value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 15, 
                color: isTotal ? Colors.black : Colors.black54,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
              )),
          Text(
            "IDR $value",
            style: TextStyle(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? AppTheme.primary : (isDiscount ? Colors.green.shade600 : Colors.black87)),
          ),
        ],
      ),
    );
  }
}