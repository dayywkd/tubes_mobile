// lib/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import 'package:toko_kopi_sembilan/screens/payment_succes_screen.dart';
import 'qr_scan_screen.dart'; // Import QR scanner

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
      Future.microtask(() => Navigator.pop(context));
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

            // ---------- TABLE ID / QR SCANNER ----------
            _tableIdSection(context, cart),

            const SizedBox(height: 20),

            // ---------- TOP BUTTONS (Diperbarui dengan fungsi onTap) ----------
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
              return _orderItem(context, item);
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

            _summaryRow("Total Harga Barang", "IDR ${totalHarga.toInt()}"),
            _summaryRow("Pajak (10%)", "IDR ${tax.toInt()}"),
            _summaryRow("Diskon", "- IDR ${discount.toInt()}", isDiscount: true),

            const Divider(height: 20),
            
            _summaryRow("Total Pembayaran", "IDR ${totalBayar.toInt()}", isTotal: true),

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
                // Nonaktifkan tombol jika tableId null
                onPressed: cart.tableId == null ? null : () async {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mengirim pesanan...")),
                  );
                  
                  final success = await OrderService.sendOrder(
                    tableId: cart.tableId ?? "unknown",
                    items: cart.items,
                  );

                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentSuccessScreen(),
                      ),
                    );
                    cart.clear();
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal mengirim pesanan. Silakan coba lagi.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cart.tableId == null ? Colors.grey : AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  cart.tableId == null ? "Scan QR Meja Dulu" : "Pesan Sekarang",
                  style: const TextStyle(
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

  Widget _tableIdSection(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cart.tableId == null ? Colors.red.shade200 : AppTheme.primary),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, color: cart.tableId == null ? Colors.red : AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nomor Meja Anda", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  cart.tableId ?? "Wajib Scan QR Meja",
                  style: TextStyle(color: cart.tableId == null ? Colors.red : Colors.black87),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Navigasi ke QRScanScreen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanScreen()),
              );
              if (result != null && result is String && result.isNotEmpty) {
                // Set table ID di CartProvider
                cart.setTable(result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Meja $result berhasil teridentifikasi")),
                );
              } else if (result == null) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Scan dibatalkan.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(cart.tableId == null ? "Scan QR" : "Ubah"),
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

  Widget _orderItem(BuildContext context, item) {
    // ... (rest of _orderItem logic)
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/kopi.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item.qty}x ${item.product.name}", // Menampilkan QTY di nama
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Size: ${item.size} - IDR ${item.product.price.toInt()}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          
          // Total price for item
          Text(
            "IDR ${(item.product.price * item.qty).toInt()}",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 15),
          ),
        ],
      ),
    );
  }


  Widget _summaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
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
            value,
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