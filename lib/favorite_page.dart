import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'favorite/favorite_logic.dart';
import 'models/product_model.dart';
import 'product_detail.dart';
import 'widgets/dark_mode_toggle_button.dart';

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
        title: const Text('Favorite History'),
        actions: [
          Consumer<FavoriteLogic>(
            builder: (context, favoriteLogic, _) {
              if (favoriteLogic.totalFavorites == 0) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: favoriteLogic.clear,
                child: const Text('Clear all'),
              );
            },
          ),
          const DarkModeToggleButton(),
        ],
      ),
      body: Consumer<FavoriteLogic>(
        builder: (context, favoriteLogic, _) {
          if (favoriteLogic.items.isEmpty) {
            return const Center(
              child: Text('Your favorite list is empty.'),
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
              return _FavoriteTile(
                entry: entry,
                timestampLabel: _formatTimestamp(entry.favoritedAt),
                onRemove: () => favoriteLogic.removeFavorite(entry.product),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetail(product: entry.product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteEntry entry;
  final String timestampLabel;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteTile({
    required this.entry,
    required this.timestampLabel,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ProductModel product = entry.product;

    return Card(
      child: ListTile(
        onTap: onTap,
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
                child: const Icon(Icons.image_not_supported_outlined),
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
          'Favorited: $timestampLabel',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: onRemove,
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }
}
