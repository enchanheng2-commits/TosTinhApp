import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favorite_logic.dart';

class FavoriteBadgeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FavoriteBadgeButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteLogic>(
      builder: (context, favoriteLogic, _) {
        return IconButton(
          onPressed: onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.favorite_border),
              if (favoriteLogic.totalFavorites > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    child: Text(
                      favoriteLogic.totalFavorites > 99
                          ? '99+'
                          : favoriteLogic.totalFavorites.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
