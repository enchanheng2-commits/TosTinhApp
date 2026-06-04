import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../favorite/favorite_logic.dart';
import 'api_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/dark_mode_toggle_button.dart';
import 'product_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final products = await ApiProvider.fetchProducts();

    if (!mounted) {
      return;
    }

    setState(() {
      allProducts = products;
      filteredProducts = products;
      isLoading = false;
    });
  }

  void searchProduct(String query) {
    final results = allProducts.where((product) {
      final title = product.title.toLowerCase();

      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteLogic = context.watch<FavoriteLogic>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        actions: const [DarkModeToggleButton()],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                onChanged: searchProduct,
                decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              builder: (_) => ProductDetail(product: product),
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
      ),
    );
  }
}
