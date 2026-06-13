import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../cart/cart_logic.dart';
import '../cart/cart_page.dart';
import '../favorite/favorite_badge_button.dart';
import '../favorite/favorite_logic.dart';
import '../favorite/favorite_page.dart';
import '../models/product_model.dart';
import '../widgets/dark_mode_toggle_button.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/profile_menu_button.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel product;
  const ProductDetail({super.key, required this.product});
  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _selectedQuantity = 1;

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritePage()),
    );
  }

  void _toggleFavorite(ProductModel product) {
    final added = context.read<FavoriteLogic>().toggleFavorite(product);
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
  }

  void _increaseQuantity() {
    setState(() {
      _selectedQuantity += 1;
    });
  }

  void _decreaseQuantity() {
    if (_selectedQuantity <= 1) {
      return;
    }

    setState(() {
      _selectedQuantity -= 1;
    });
  }

  void _addToCart(ProductModel product) {
    context.read<CartLogic>().addProduct(product, quantity: _selectedQuantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.title}  '
                'Price: \$${product.price.toStringAsFixed(2)}  '
                'Qty: $_selectedQuantity  '
                'Total: \$${(product.price * _selectedQuantity).toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _buyNow(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          checkoutProduct: product,
          checkoutQuantity: _selectedQuantity,
        ),
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    return List.generate(5, (index) {
      if (index < fullStars) {
        return const Icon(
          Icons.star_rounded,
          color: Color(0xFFF5A623),
          size: 20,
        );
      }
      if (index == fullStars && hasHalfStar) {
        return const Icon(
          Icons.star_half_rounded,
          color: Color(0xFFF5A623),
          size: 20,
        );
      }
      return const Icon(
        Icons.star_border_rounded,
        color: Color(0xFFD9CFEA),
        size: 20,
      );
    });
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final product = widget.product;
    final rating = product.displayRating;
    final reviewCount = product.reviewCount;
    final topGradientColors = isDark
        ? const [Color(0xFF221733), Color(0xFF17111F), Color(0xFF121212)]
        : const [Color(0xFFEAD7FF), Color(0xFFF7F2FF), Color(0xFFF4EDFF)];
    final imageCardColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.72);
    final contentCardColor = colorScheme.surface;
    final titleColor = colorScheme.onSurface;
    final bodyColor = colorScheme.onSurfaceVariant;
    final mutedTextColor = isDark ? Colors.white70 : Colors.black54;
    final highlightBackground = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : const Color(0xFFF5EEFF);
    final chipBackground = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.9)
        : const Color(0xFFF9F7FF);
    final buttonBackground = isDark ? colorScheme.primary : Colors.deepPurple;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.9),
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: colorScheme.onSurface,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          CartBadgeButton(onPressed: _openCart),
          FavoriteBadgeButton(onPressed: _openFavorites),
          const ProfileMenuButton(),
          const DarkModeToggleButton(),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: topGradientColors,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: imageCardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.deepPurple.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Hero(
                              tag: product.id,
                              child: Center(
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 72,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                decoration: BoxDecoration(
                  color: contentCardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: GoogleFonts.manrope(
                              fontSize: 30,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: highlightBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _infoChip(
                          icon: Icons.sell_rounded,
                          label: product.category.toUpperCase(),
                          background: highlightBackground,
                          foreground: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _infoChip(
                          icon: Icons.reviews_rounded,
                          label: '$reviewCount reviews',
                          background: isDark
                              ? colorScheme.secondaryContainer.withValues(
                                  alpha: 0.8,
                                )
                              : const Color(0xFFF9F4E8),
                          foreground: isDark
                              ? colorScheme.onSecondaryContainer
                              : const Color(0xFF8E5B00),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: chipBackground,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating summary',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.manrope(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: _buildStars(rating)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$reviewCount verified reviews',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        color: mutedTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'About this product',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        height: 1.8,
                        color: bodyColor,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _infoChip(
                            icon: Icons.local_shipping_rounded,
                            label: 'Fast delivery',
                            background: isDark
                                ? colorScheme.tertiaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : const Color(0xFFEFF8F4),
                            foreground: isDark
                                ? colorScheme.onTertiaryContainer
                                : const Color(0xFF1D7A4D),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoChip(
                            icon: Icons.verified_user_rounded,
                            label: 'Secure checkout',
                            background: isDark
                                ? colorScheme.errorContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : const Color(0xFFFFF2F2),
                            foreground: isDark
                                ? colorScheme.onErrorContainer
                                : const Color(0xFFB42318),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: chipBackground,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select how many items to buy',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: mutedTextColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _QuantityStepper(
                            quantity: _selectedQuantity,
                            onMinus: _decreaseQuantity,
                            onPlus: _increaseQuantity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleFavorite(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: highlightBackground,
                          foregroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.favorite_rounded),
                        label: Text(
                          'Favorite',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: () => _buyNow(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: highlightBackground,
                                foregroundColor: colorScheme.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.bolt_rounded),
                              label: Text(
                                'Buy Now',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: () => _addToCart(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonBackground,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.shopping_bag_rounded),
                              label: Text(
                                _selectedQuantity == 1
                                    ? 'Add To Cart'
                                    : 'Add $_selectedQuantity To Cart',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onPressed: quantity > 1 ? onMinus : null,
        ),
        Container(
          width: 56,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          child: Text(
            quantity.toString(),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onPressed: onPlus,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: enabled
            ? Colors.deepPurple.withValues(alpha: 0.12)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.deepPurple : Colors.grey,
          ),
        ),
      ),
    );
  }

}
