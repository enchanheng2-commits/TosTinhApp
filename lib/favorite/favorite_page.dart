import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../async_module/product_detail.dart';
import '../widgets/dark_mode_toggle_button.dart';
import 'favorite_logic.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.month}/${local.day}/${local.year} $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: const [DarkModeToggleButton()],
      ),
      body: Consumer<FavoriteLogic>(
        builder: (context, favoriteLogic, _) {
          if (favoriteLogic.items.isEmpty) {
            return const Center(
              child: Text('You have no favorite items yet.'),
            );
          }

          final items = [...favoriteLogic.items]
            ..sort((a, b) => b.favoritedAt.compareTo(a.favoritedAt));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = items[index];
              final product = entry.product;

              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetail(product: product),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child:
                              const Icon(Icons.image_not_supported_outlined),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Added: ${_formatTimestamp(entry.favoritedAt)}',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: IconButton(
                    onPressed: () => favoriteLogic.removeFavorite(product),
                    icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
