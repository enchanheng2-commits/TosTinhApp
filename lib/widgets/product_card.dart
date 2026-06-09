import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: product.id,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                product.category.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: onFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
