import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../widgets/dark_mode_toggle_button.dart';
import 'cart_logic.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.month}/${local.day}/${local.year} $hour:$minute $amPm';
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: const [DarkModeToggleButton()],
      ),
      body: Consumer<CartLogic>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 72,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your receipt is empty.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add products to see quantity, total, and date here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final sortedItems = [...cart.items]
            ..sort((a, b) => b.lastAddedAt.compareTo(a.lastAddedAt));

          final receiptDate = _formatTimestamp(DateTime.now());

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.deepPurple.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt summary',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              label: 'Items',
                              value: cart.totalItems.toString(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryItem(
                              label: 'Total',
                              value: _formatCurrency(cart.totalAmount),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Date: $receiptDate',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: cart.clear,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: sortedItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = sortedItems[index];
                    return _ReceiptTile(
                      entry: entry,
                      timestampLabel: _formatTimestamp(entry.lastAddedAt),
                      lineTotal: entry.product.price * entry.quantity,
                      onRemove: () => cart.removeProduct(entry.product),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile({
    required this.entry,
    required this.timestampLabel,
    required this.lineTotal,
    required this.onRemove,
  });

  final CartEntry entry;
  final String timestampLabel;
  final double lineTotal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ProductModel product = entry.product;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Qty: ${entry.quantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: $timestampLabel',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Line total: \$${lineTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onRemove,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
