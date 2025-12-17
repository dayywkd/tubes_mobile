// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // IMPORT BARU UNTUK NAMA LOKASI

import '../config/theme.dart';
import '../providers/product_provider.dart';
import '../widgets/product_cart.dart';
import '../widgets/product_skeleton.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All Coffee";
  TextEditingController searchCtrl = TextEditingController();
  String searchQuery = "";
  
  // Default text saat loading
  String _currentLocation = "Mencari Lokasi..."; 
  
  int _selectedIndex = 0; 

  final categories = [
    "All Coffee",
    "Mocha",
    "Latte",
    "Americano",
    "Flat White",
    "Espresso",
  ];

  @override
  void initState() {
    super.initState();
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    Future.delayed(Duration.zero, () {
      productProvider.loadProducts();
      _determinePosition(); // Panggil fungsi lokasi saat mulai
    });
  }

  // --- FUNGSI LOKASI DIPERBARUI (REVERSE GEOCODING) ---
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek Service GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) setState(() => _currentLocation = "GPS Mati");
      return;
    }

    // 2. Cek Izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() => _currentLocation = "Izin Lokasi Ditolak");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if(mounted) setState(() => _currentLocation = "Izin Ditolak Permanen");
      return;
    } 

    try {
      // 3. Ambil Koordinat
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 4. UBAH KOORDINAT JADI ALAMAT (GEOCODING)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          // Anda bisa memilih field lain: locality, subLocality, thoroughfare, dll.
          // subLocality = Kecamatan/Kelurahan
          // locality = Kota/Kabupaten
          // administrativeArea = Provinsi
          
          String locationName = "${place.subLocality ?? ''}, ${place.locality ?? ''}";
          
          // Jika kosong, coba ambil administrative area
          if (locationName.trim() == ",") {
             locationName = place.administrativeArea ?? "Lokasi Tidak Diketahui";
          }
          
          // Hapus koma di awal jika subLocality kosong
          if (locationName.startsWith(",")) {
            locationName = locationName.substring(1).trim();
          }

          if(mounted) {
            setState(() {
              _currentLocation = locationName;
            });
          }
        } else {
           if(mounted) setState(() => _currentLocation = "Alamat tidak ditemukan");
        }
      } catch (e) {
        // Jika gagal ubah ke alamat (misal tidak ada internet), tampilkan koordinat saja
        if(mounted) {
          setState(() {
             _currentLocation = "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
          });
        }
      }

    } catch (e) {
      if(mounted) setState(() => _currentLocation = "Gagal memuat lokasi");
      print("Geolocation Error: $e");
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        break; 
      case 1: 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Favorite belum tersedia")));
        break;
      case 2: 
        Navigator.pushNamed(context, "/notification").then((_) {
          // Reset highlight kembali ke Home (index 0) setelah user kembali dari halaman notifikasi
          if (mounted) setState(() => _selectedIndex = 0); 
        });
        break;
      case 3: // PROFILE
        Navigator.pushNamed(context, "/profile").then((_) {
          if (mounted) setState(() => _selectedIndex = 0); 
        });
        break;
      case 4: // CART
        Navigator.pushNamed(context, "/cart").then((_) {
          if (mounted) setState(() => _selectedIndex = 0); 
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped,        
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(context),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPromoCard(context),
                    const SizedBox(height: 16),
                    _buildCategoryChips(),
                    const SizedBox(height: 12),
                    SizedBox(
                      // Agar GridView tidak error di dalam SingleChildScrollView
                      // Kita pakai shrinkWrap atau beri tinggi fix. 
                      // Di sini saya pakai logic provider.isLoading untuk content
                      height: 500, // Estimasi tinggi, atau gunakan shrinkWrap: true di GridView
                      child: productProvider.isLoading
                          ? _buildSkeletonGrid() 
                          : _buildProductGrid(productProvider),
                    ),
                    const SizedBox(height: 80), // Space untuk bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- TOP SECTION --------------------
  Widget _buildTopSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 12), 
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF414345)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOCATION HEADER 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Gunakan Expanded agar teks panjang tidak overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Location",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    // LOKASI (ICON + TEXT)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentLocation, // TAMPILKAN NAMA LOKASI DI SINI
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)), // Sesuaikan font size agar muat
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ikon logo di pojok kanan
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_cafe, color: Colors.white, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEARCH BAR 
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: (value) {
                            setState(() => searchQuery = value.toLowerCase());
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search coffee",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // -------------------- PROMO CARD --------------------
  Widget _buildPromoCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40; 
    final height = width / 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFB86F44),
          borderRadius: BorderRadius.circular(18),
          // Pastikan gambar aset ini ada
          image: const DecorationImage(
            image: AssetImage("assets/kopi.png"), 
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Promo",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const Positioned(
              left: 16,
              bottom: 20,
              child: Text(
                "Buy one get\none FREE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                  height: 1.1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // -------------------- CATEGORY FILTER --------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final isSelected = categories[i] == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.brown.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------- SKELETON GRID --------------------
  Widget _buildSkeletonGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll diurus parent
      shrinkWrap: true, // Agar fit content
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 240,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, i) => const ProductSkeleton(),
    );
  }

  // -------------------- PRODUCT GRID --------------------
  Widget _buildProductGrid(ProductProvider provider) {
    final categoryFiltered = provider.products.where((p) {
      if (selectedCategory == "All Coffee") return true;
      return p.category == selectedCategory;
    }).toList();

    final items = categoryFiltered.where((p) {
      final q = searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
    
    if (items.isEmpty && !provider.isLoading) {
       return const Padding(
         padding: EdgeInsets.all(20.0),
         child: Center(
            child: Text("Tidak ada produk ditemukan", style: TextStyle(color: Colors.grey)),
          ),
       );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll diurus parent
      shrinkWrap: true, // Agar fit content
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 240,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, i) => ProductCard(product: items[i]),
    );
  }
}