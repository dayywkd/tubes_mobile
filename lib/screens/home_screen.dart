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
    "Machiatto",
    "Latte",
    "Americano",
    "Flat White",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
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
              Navigator.pushNamed(context, "/favorite");
              break;
            case 2:
              Navigator.pushNamed(context, "/notifications");
              break;
            case 3:
              Navigator.pushNamed(context, "/profile");
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
            _buildTopSection(),
            const SizedBox(height: 20),
            _buildPromoCard(),
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
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF414345)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOCATION HEADER
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
              const Text("SEMBILAN",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 16),

          // SEARCH BAR
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  // -------------------- PROMO CARD --------------------
  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 130,
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
              left: 12,
              top: 12,
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
              left: 12,
              bottom: 20,
              child: Text(
                "Buy one get\none FREE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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

  // -------------------- BOTTOM NAV --------------------
  Widget _buildBottomNav() {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home, color: AppTheme.primary, size: 28),
          Icon(Icons.favorite_border, color: Colors.grey, size: 26),
          Icon(Icons.notifications_outlined, color: Colors.grey, size: 26),
          Icon(Icons.person_outline, color: Colors.grey, size: 26),
        ],
      ),
    );
  }
}
