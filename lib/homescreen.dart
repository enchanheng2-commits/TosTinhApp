import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorite/favorite_logic.dart';
import 'async_module/api_provider.dart';
import 'models/product_model.dart';
import 'widgets/product_card.dart';
import 'widgets/dark_mode_toggle_button.dart';
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
    'Men\'s': "men's clothing",
    'Women\'s': "women's clothing",
    'Jewelry': 'jewelery',
    'Electronics': 'electronics',
  };

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiProvider.fetchProducts();
  }

  Widget _buildCategoryButton(String label) {
    final selected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedCategory = label;
          });
        },
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
          final filteredProducts = selectedCategory == 'All Products'
              ? products
              : products
                    .where(
                      (product) =>
                          product.category == categoryMap[selectedCategory],
                    )
                    .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text("No products available in this category."),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemBuilder: (context, index) {
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
