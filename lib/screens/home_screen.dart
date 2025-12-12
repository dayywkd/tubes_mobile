// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    Future.delayed(Duration.zero, () {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Home
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Favorite belum tersedia")));
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Notifikasi belum tersedia")));
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Profile belum tersedia")));
              break;
            case 4:
              Navigator.pushNamed(context, "/cart");
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(context),
            const SizedBox(height: 20),
            _buildPromoCard(context),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 12),
            Expanded(
              child: productProvider.isLoading
                  ? _buildSkeletonGrid() 
                  : _buildProductGrid(productProvider),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- TOP SECTION --------------------
  Widget _buildTopSection(BuildContext context) {
    return Container(
      // Responsive padding
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 12), 
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF414345)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)), // Radius lebih besar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOCATION HEADER (Dibuat lebih rapi)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Location",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(height: 4),
                  Text("Tuban, Jawa Timur",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              // Ikon logo di pojok kanan
              Container(
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

          // SEARCH BAR (Dibuat lebih modern)
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
    // Menggunakan perbandingan rasio layar untuk responsif
    final width = MediaQuery.of(context).size.width - 40; 
    final height = width / 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFB86F44),
          borderRadius: BorderRadius.circular(18),
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
       return const Center(
          child: Text("Tidak ada produk ditemukan", style: TextStyle(color: Colors.grey)),
        );
    }

    return GridView.builder(
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