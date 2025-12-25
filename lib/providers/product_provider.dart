import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> products = [];
  bool isLoading = false;

  final _boxName = "productsBox";

  ProductProvider() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    // Ensure Hive box is opened and seeded if empty
    await Hive.openBox<Product>(_boxName);
    final box = Hive.box<Product>(_boxName);

    if (box.isEmpty) {
      await seedProducts();
    }

    await loadProducts();
  }

  /// Load products – prefer Hive first, fallback Supabase
  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    final box = Hive.box<Product>(_boxName);

    // Load from Hive ONLY
    products = box.values.toList();
    isLoading = false;
    notifyListeners();
  }

  /// 🔹 STEP: Fetch from Hive (Offline)
  Future<void> fetchFromHive() async {
    final box = await Hive.openBox<Product>(_boxName);

    if (box.isNotEmpty) {
      products = box.values.toList();
      notifyListeners();
    }
  }

  /// 🔹 STEP: Fetch from Supabase (Online → Save to Hive)
  Future<void> fetchFromSupabase() async {
    final client = Supabase.instance.client;

    final res = await client.from('products').select();

    final fetched = (res as List).map((e) => Product.fromJson(e)).toList();

    products = fetched;

    // Save to Hive
    final box = await Hive.openBox<Product>(_boxName);
    await box.clear();
    await box.addAll(fetched);

    notifyListeners();
  }

  Future<void> seedProducts() async {
    final box = Hive.box<Product>('productsBox');

    if (box.isEmpty) {
      await box.addAll([
        Product(
          id: "1",
          name: "Americano",
          subtitle: "Strong & bold espresso with hot water",
          price: 18000,
          category: "Coffee",
          imageUrl: "assets/americano.jpg",
        ),
        Product(
          id: "2",
          name: "Cappuccino",
          subtitle: "Espresso with steamed milk & foam",
          price: 22000,
          category: "Coffee",
          imageUrl: "assets/cappucino.jpg",
        ),
        Product(
          id: "3",
          name: "Espresso",
          subtitle: "Pure concentrated coffee shot",
          price: 15000,
          category: "Coffee",
          imageUrl: "assets/esspreso.jpg",
        ),
        Product(
          id: "4",
          name: "Kopi Hitam",
          subtitle: "Classic Indonesian black coffee",
          price: 12000,
          category: "Coffee",
          imageUrl: "assets/kopi_hitam.jpg",
        ),
        Product(
          id: "5",
          name: "Latte",
          subtitle: "Smooth espresso with creamy milk",
          price: 23000,
          category: "Coffee",
          imageUrl: "assets/latte.jpg",
        ),
        Product(
          id: "6",
          name: "Milk Coffee",
          subtitle: "Coffee mixed with fresh milk",
          price: 20000,
          category: "Coffee",
          imageUrl: "assets/milkcoffe.jpg",
        ),
        Product(
          id: "7",
          name: "Mocha",
          subtitle: "Chocolate flavored coffee latte",
          price: 24000,
          category: "Coffee",
          imageUrl: "assets/mocha.jpg",
        ),
      ]);
    }
  }
}
