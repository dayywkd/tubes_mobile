import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // --- VARIABEL: RIWAYAT NOTIFIKASI ---
  // Menggunakan .obs agar UI otomatis update saat ada data baru
  var history = <RemoteMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initNotification();
  }

  void _initNotification() async {
    // 1. Request Permission (Penting untuk Android 13+)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getToken().then((token) {
      print("========================================");
      print("FCM TOKEN: $token");
      print("========================================");
    });

    // 2. Setup Local Notification Channel (Agar muncul Heads-up & Custom Sound)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel_v2', // ID Channel
      'High Importance Notifications V2', // Nama Channel
      description: 'Channel baru untuk notifikasi kopi.',
      importance: Importance.max, // Pastikan Max agar muncul Pop-up
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_kopi'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Setup Inisialisasi Lokal
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle klik notifikasi saat aplikasi di Foreground/Background (via Local Notif)
        if (details.payload != null) {
          _handleMessageNavigation(details.payload!);
        }
      },
    );

    // --- LISTENER LIFECYCLE FCM ---

    // A. KONDISI FOREGROUND (Aplikasi Dibuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // 1. Simpan ke history
      _addToHistory(message);

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // 2. Tampilkan notifikasi lokal agar muncul banner (Heads-up)
      if (notification != null && android != null) {
        print("FOREGROUND NOTIF: ${message.data}");
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              sound: const RawResourceAndroidNotificationSound('notif_kopi'),
              priority: Priority.high, // Wajib High agar muncul pop-up
              importance: Importance.max,
            ),
          ),
          payload: jsonEncode(message.data), // Simpan data untuk navigasi
        );
      }
    });

    // B. KONDISI BACKGROUND (Aplikasi Di-minimize & Klik Notif)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("BACKGROUND NOTIF CLICKED: ${message.data}");
      _handleMessageNavigation(jsonEncode(message.data));
    });

    // C. KONDISI TERMINATED (Aplikasi Mati Total)
    // Cek apakah aplikasi dibuka dari notifikasi saat statusnya mati
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("TERMINATED NOTIF CLICKED: ${initialMessage.data}");
      // Tambahkan ke history jika perlu
      _addToHistory(initialMessage);
      
      // Beri delay sedikit agar GetMaterialApp siap
      Future.delayed(const Duration(seconds: 1), () {
        _handleMessageNavigation(jsonEncode(initialMessage.data));
      });
    }
  }

  // --- FUNGSI MANAJEMEN HISTORY ---

  // Menambah pesan ke list (paling baru di urutan paling atas/index 0)
  void _addToHistory(RemoteMessage message) {
    history.insert(0, message);
  }

  // Menghapus semua riwayat
  void clearHistory() {
    history.clear();
  }

  // --- FUNGSI NAVIGASI ---
  
  // Fungsi Navigasi Pintar (Routing sesuai Payload)
  void _handleMessageNavigation(String payloadString) {
    try {
      Map<String, dynamic> data = jsonDecode(payloadString);

      // Logika Routing: Jika ada key 'route', pergi ke sana.
      if (data.containsKey('route')) {
        String route = data['route'];
        // Contoh payload: { "route": "/order", "order_id": "123" }
        Get.toNamed(route, arguments: data);
      } else {
        // Default ke home jika tidak ada route spesifik
        Get.toNamed('/home');
      }
    } catch (e) {
      print("Error parsing payload: $e");
    }
  }

  // --- FUNGSI BARU: SIMULASI NOTIFIKASI MANUAL & PROGRESS ---
  // Tambahkan ini agar bisa dipanggil dari tombol bayar

  void showLocalNotification({
    required String title,
    required String body,
    String? payload, // Opsional: data untuk navigasi
  }) {
    // Generate ID unik berbasis waktu
    int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel_v2', // ID Channel harus sama dengan init
          'High Importance Notifications V2',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notif_kopi'),
        ),
      ),
      payload: payload,
    );

    // Opsi: Simpan juga notifikasi manual ini ke History agar muncul di list
    // Kita buat objek RemoteMessage dummy
    _addToHistory(RemoteMessage(
      notification: RemoteNotification(title: title, body: body),
      sentTime: DateTime.now(),
      data: payload != null ? jsonDecode(payload) : {},
    ));
  }

  void simulateOrderProgress() async {
    // 1. Notifikasi Pesanan Masuk (Langsung)
    showLocalNotification(
      title: "Pesanan Diterima! 🧾",
      body: "Pembayaran berhasil. Baristanya sedang bersiap-siap nih.",
      payload: jsonEncode({"route": "/order"}), // Jika diklik lari ke halaman Order
    );

    // 2. Tunggu 4 Detik -> Notifikasi Sedang Dibuat
    await Future.delayed(const Duration(seconds: 4));
    showLocalNotification(
      title: "Sedang Diracik ☕",
      body: "Kopimu sedang dibuat dengan penuh cinta. Tunggu sebentar ya!",
      payload: jsonEncode({"route": "/order"}),
    );

    // 3. Tunggu 4 Detik lagi -> Notifikasi Selesai
    await Future.delayed(const Duration(seconds: 4));
    showLocalNotification(
      title: "Pesanan Siap! ✅",
      body: "Hore! Kopimu sudah jadi. Silakan ambil di meja kasir.",
      payload: jsonEncode({"route": "/order"}),
    );
  }
}