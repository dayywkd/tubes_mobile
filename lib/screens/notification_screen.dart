import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Notifikasi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Semua',
            onPressed: () {
              if (controller.history.isNotEmpty) {
                Get.defaultDialog(
                  title: "Hapus Notifikasi",
                  middleText: "Hapus semua riwayat?",
                  textConfirm: "Ya",
                  textCancel: "Batal",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.clearHistory();
                    Get.back();
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        // Jika history kosong, tampilkan pesan
        if (controller.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, 
                  size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  "Belum ada notifikasi",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // Jika ada data, tampilkan list
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // Ambil data dengan aman
            final message = controller.history[index];
            return _buildNotificationCard(
              context: context,
              message: message,
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required RemoteMessage message,
  }) {
    final theme = Theme.of(context);
    final notification = message.notification;
    
    // Ambil sentTime ke variabel lokal untuk pengecekan null yang aman
    final sentTime = message.sentTime;

    // Logika warna ikon
    final title = notification?.title ?? '';
    final bool isPromo = title.toLowerCase().contains('promo');
    final Color cardColor = isPromo ? Colors.orange : theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Tampilkan detail saat diklik
          Get.snackbar(
            notification?.title ?? 'Info',
            notification?.body ?? '',
            backgroundColor: Colors.white,
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPromo ? Icons.discount_outlined : Icons.notifications_active_outlined,
                  color: cardColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Tanpa Judul',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification?.body ?? 'Tidak ada konten.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Waktu (Safe Check tanpa tanda seru !)
                    Text(
                      sentTime != null 
                          ? "${sentTime.hour.toString().padLeft(2, '0')}:${sentTime.minute.toString().padLeft(2, '0')}" 
                          : "Baru saja",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}