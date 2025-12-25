import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class HomeController {
  final BuildContext context;
  HomeController(this.context);

  /// CATEGORY DATA
  final categories = [
    "All Coffee",
    "Mocha",
    "Latte",
    "Americano",
    "Flat White",
    "Esspreso",
  ];

  String selectedCategory = "All Coffee";
  String searchQuery = "";
  int selectedIndex = 0;

  /// LOCATION
  String currentLocation = "Mencari Lokasi...";

  /// INITIAL LOAD
  Future<void> init() async {
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
    await determinePosition();
  }

  /// CATEGORY SELECT
  void onCategorySelected(String value, VoidCallback refresh) {
    selectedCategory = value;
    refresh();
  }

  /// SEARCH
  void onSearchChanged(String value, VoidCallback refresh) {
    searchQuery = value.toLowerCase();
    refresh();
  }

  /// GET USER LOCATION
  Future<void> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentLocation = "GPS Mati";
      _refresh();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        currentLocation = "Izin Lokasi Ditolak";
        _refresh();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      currentLocation = "Izin Ditolak Permanen";
      _refresh();
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> places =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);

        if (places.isNotEmpty) {
          final p = places[0];

          String name = "${p.subLocality ?? ''}, ${p.locality ?? ''}".trim();

          if (name == "," || name.isEmpty) {
            name = p.administrativeArea ?? "Lokasi Tidak Diketahui";
          }

          if (name.startsWith(",")) {
            name = name.replaceFirst(",", "").trim();
          }

          currentLocation = name;
        } else {
          currentLocation = "Alamat tidak ditemukan";
        }
      } catch (_) {
        currentLocation =
            "${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}";
      }
    } catch (_) {
      currentLocation = "Gagal memuat lokasi";
    }

    _refresh();
  }

  /// BOTTOM NAVIGATION HANDLER
  void onBottomNavTap(int index, VoidCallback refresh) {
    selectedIndex = index;
    refresh();

    switch (index) {
      case 1: // PROFILE
        Navigator.pushNamed(context, "/profile").then((_) {
          selectedIndex = 0;
          _refresh();
        });
        break;

      case 2: // CART
        Navigator.pushNamed(context, "/cart").then((_) {
          selectedIndex = 0;
          _refresh();
        });
        break;
    }
  }

  /// REFRESH UI
  void _refresh() {
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }
}
