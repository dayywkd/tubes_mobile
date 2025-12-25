import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/product_provider.dart';
import '../widgets/product_cart.dart';
import '../widgets/product_skeleton.dart';
import '../widgets/bottom_nav.dart';
import '../controllers/home_controller.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'purchase_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late HomeController controller;
  final TextEditingController searchCtrl = TextEditingController();

  void refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    controller = HomeController(context);

    Future.delayed(Duration.zero, () {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          _homeTab(),
          _profileTab(),
          _cartTab(),
          const PurchaseHistoryScreen(),
        ],
      ),
    );
  }

  // ============================
  // HOME TAB CONTENT
  // ============================
  Widget _homeTab() {
    final productProvider = Provider.of<ProductProvider>(context);

    return SafeArea(
      child: Column(
        children: [
          _buildTopSection(controller),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPromoCard(),
                  const SizedBox(height: 16),
                  _buildCategoryChips(),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 500,
                    child: productProvider.isLoading
                        ? _buildSkeletonGrid()
                        : _buildProductGrid(productProvider),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // PROFILE TAB
  // ============================
  Widget _profileTab() => const ProfileScreen();

  // ============================
  // CART TAB
  // ============================
  Widget _cartTab() => const CartScreen();

  // ============================
  // TOP SECTION
  // ============================
  Widget _buildTopSection(HomeController controller) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/kopi.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        controller.currentLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Find your best coffee",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // ============================
  // PROMO
  // ============================
  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                "Nikmati promo spesial kopi pilihan hari ini!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.local_cafe, size: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ============================
  // CATEGORY
  // ============================
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final item = controller.categories[index];
          final isSelected = controller.selectedCategory == item;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(item),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => controller.onCategorySelected(item, refresh),
            ),
          );
        },
      ),
    );
  }

  // ============================
  // GRID + SKELETON
  // ============================
  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => const ProductSkeleton(),
      itemCount: 6,
    );
  }

  Widget _buildProductGrid(ProductProvider productProvider) {
    final filtered = productProvider.products.where((p) {
      final matchesCategory = controller.selectedCategory == "All Coffee" ||
          p.category == controller.selectedCategory;

      final matchesSearch = controller.searchQuery.isEmpty ||
          p.name.toLowerCase().contains(controller.searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => ProductCard(product: filtered[i]),
    );
  }
}
