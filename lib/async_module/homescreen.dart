import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../favorite/favorite_logic.dart';
import '../models/product_model.dart';
import '../widgets/dark_mode_toggle_button.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_location_bar.dart';
import '../widgets/product_card.dart';
import 'api_provider.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<ProductModel>> _productsFuture;
  String selectedCategory = 'All Products';

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
    final categories = [
      "men's clothing",
      "women's clothing",
      "jewelery",
      "electronics",
    ];
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
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/tostinh_logo.png',
              height: 160,
              width: 160,
              fit: BoxFit.contain,
            ),
          ],
        ),
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
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeLocationBar(
                      locationLabel: 'National University of Management',
                      mapUrl:
                          'https://www.google.com/maps/place/National+University+of+Management/@11.5747699,104.918627,16z/data=!3m1!4b1!4m6!3m5!1s0x310951431e152d17:0x9b79af8befbd4a18!8m2!3d11.5747699!4d104.918627!16s%2Fm%2F0279my9?entry=ttu&g_ep=EgoyMDI2MDYwMy4xIKXMDSoASAFQAw%3D%3D',
                    ),
                    HomeBanner(products: bannerProducts),
                    const SizedBox(height: 16),
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
              filteredProducts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text("No products available in this category."),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                        }, childCount: filteredProducts.length),
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
