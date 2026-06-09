import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../favorite/favorite_logic.dart';
import 'api_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/dark_mode_toggle_button.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<ProductModel>> _productsFuture;
  String selectedCategory = 'All Products';
  int currentBanner = 0;

  static const Map<String, String> categoryMap = {
    'All Products': '',
    "Men's": "men's clothing",
    "Women's": "women's clothing",
    'Jewelry': 'jewelery',
    'Electronics': 'electronics',
  };

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiProvider.fetchProducts();
  }

  List<ProductModel> _getBannerProducts(List<ProductModel> products) {
    final categories = ["men's clothing", "women's clothing", "jewelery", "electronics"];
    final List<ProductModel> featured = [];
    for (final cat in categories) {
      final match = products.where((p) => p.category == cat).toList();
      if (match.isNotEmpty) featured.add(match.first);
    }
    return featured.isEmpty ? products.take(4).toList() : featured;
  }

  Widget _buildCategoryButton(String label) {
    final selected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: OutlinedButton(
        onPressed: () => setState(() => selectedCategory = label),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.deepPurple : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black,
          side: BorderSide(
            color: selected ? Colors.deepPurple : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteLogic = context.watch<FavoriteLogic>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: const [DarkModeToggleButton()],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final products = snapshot.data!;
          final bannerProducts = _getBannerProducts(products);
          final filteredProducts = selectedCategory == 'All Products'
              ? products
              : products
                  .where((p) => p.category == categoryMap[selectedCategory])
                  .toList();

          return CustomScrollView(
            slivers: [
              // ── Banner ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        onPageChanged: (index, _) =>
                            setState(() => currentBanner = index),
                      ),
                      items: bannerProducts.map((product) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: const Color.fromARGB(255, 206, 174, 215),
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.6),
                                        ],
                                      ),
                                    ),
                                ),
                                Positioned(
                                  left: 14,
                                  bottom: 14,
                                  right: 14,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          product.category.toUpperCase(),
                                          style:  TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:  TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: bannerProducts.asMap().entries.map((entry) {
                        final isActive = currentBanner == entry.key;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // ── Category Filter ──────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: categoryMap.keys
                            .map((label) => _buildCategoryButton(label))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Product Grid ─────────────────────────────────────────
              filteredProducts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text("No products available in this category."),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              isFavorited: favoriteLogic.isFavorited(product),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetail(product: product),
                                  ),
                                );
                              },
                              onFavorite: () {
                                final added = context
                                    .read<FavoriteLogic>()
                                    .toggleFavorite(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? '${product.title} added to favorites'
                                          : '${product.title} removed from favorites',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: filteredProducts.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
