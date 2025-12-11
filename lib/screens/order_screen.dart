import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import 'package:toko_kopi_sembilan/screens/payment_succes_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

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
          "Order",
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

            // ---------- TOP BUTTONS ----------
            Row(
              children: [
                _topButton(icon: Icons.edit, label: "Edit Order"),
                const SizedBox(width: 12),
                _topButton(icon: Icons.note_add_outlined, label: "Add Note"),
              ],
            ),

            const SizedBox(height: 20),

            // ---------- ITEM LIST ----------
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
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Color.fromARGB(255, 255, 255, 255)),
                  const SizedBox(width: 10),
                  const Text("1 Discount is Applied",
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
              "Payment Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            _summaryRow("Price", "IDR ${cart.total.toInt()}"),
            _summaryRow("Tax", "IDR 1.000"),

            const SizedBox(height: 20),

            // ---------- PAYMENT METHOD ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Cash/Wallet",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        "IDR 50.000",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------- PLACE ORDER BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Order",
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

  // Top buttons (Edit order & add note)
  Widget _topButton({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
    );
  }

  // Order item list
  Widget _orderItem(BuildContext context, item) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Text(item.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item.product.subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // Qty control
          Row(
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: () => cart.changeQty(item, -1),
              ),
              const SizedBox(width: 12),
              Text(
                "${item.qty}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              _qtyButton(
                icon: Icons.add,
                onTap: () => cart.changeQty(item, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Minus / Plus button
  Widget _qtyButton({required IconData icon, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 32,        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  // Payment Summary row
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
