import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> products = [];
  bool isLoading = false;

  Future loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await ProductService.getProducts();
    } catch (e) {
      debugPrint("Error loading products: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
