import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'cart_logic.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedPaymentIndex = 0;
  bool _savePaymentDetails = true;

  static final List<_PaymentMethodData> _paymentMethods = [
    _PaymentMethodData(
      name: 'Aceleda Bank',
      imageUrl: 'https://www.acledabank.com.kh/kh/assets/layout/logo-white.png',
      fallbackLabel: 'AB',
      accentColor: Color(0xFF163C7A),
      badgeColor: Color(0xFF1C4A94),
    ),
    _PaymentMethodData(
      name: 'ABA Bank',
      imageUrl:
          'https://www.acledasecurities.com.kh/as/assets/listed_company/ABA/aba-web-top-logo.png',
      fallbackLabel: 'ABA',
      accentColor: Color(0xFF00657A),
      badgeColor: Color(0xFF0A7285),
    ),
    _PaymentMethodData(
      name: 'Wing Bank',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1t5E_3ir1VR1l2i93jV3uauE0PBkS8cXHxQ&s',
      fallbackLabel: 'W',
      accentColor: Color(0xFFB5D400),
      badgeColor: Color(0xFFB5D400),
    ),
  ];

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  String _formatDate(DateTime dateTime) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _timeWindow() => '15 - 30 mins';

  double _rounded(double value) => double.parse(value.toStringAsFixed(2));

  void _handlePayNow(BuildContext context, CartLogic cart) {
    final selectedPayment = _paymentMethods[_selectedPaymentIndex].name;
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Payment started with $selectedPayment. Save details: ${_savePaymentDetails ? 'on' : 'off'}.',
        ),
      ),
    );

    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF161112)
        : const Color(0xFFF9F7F4);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Consumer<CartLogic>(
        builder: (context, cart, _) {
          final subtotal = cart.totalAmount;
          final taxes = subtotal > 0 ? subtotal * 0.02 : 0.0;
          final deliveryFees = subtotal > 0 ? 1.50 : 0.0;
          final total = _rounded(subtotal + taxes + deliveryFees);
          final hasItems = cart.items.isNotEmpty;

          if (!hasItems) {
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
                      'Your checkout is empty.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add items from the shop to see the order summary and payment options here.',
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

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order summary',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SummaryRow(label: 'Order', value: _money(subtotal)),
                        const SizedBox(height: 14),
                        _SummaryRow(label: 'Taxes', value: _money(taxes)),
                        const SizedBox(height: 14),
                        _SummaryRow(
                          label: 'Delivery fees',
                          value: _money(deliveryFees),
                        ),
                        const SizedBox(height: 14),
                        Divider(color: Colors.grey.shade300, height: 1),
                        const SizedBox(height: 14),
                        _SummaryRow(
                          label: 'Total:',
                          value: _money(total),
                          isBold: true,
                        ),
                        const SizedBox(height: 18),
                        _SummaryRow(
                          label: 'Estimated delivery time:',
                          value: _timeWindow(),
                          valueAlign: TextAlign.right,
                          valueColor: Colors.grey.shade800,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Payment methods',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...List<Widget>.generate(_paymentMethods.length, (
                          index,
                        ) {
                          final method = _paymentMethods[index];
                          final isSelected = _selectedPaymentIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _PaymentCard(
                              method: method,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedPaymentIndex = index;
                                });
                              },
                            ),
                          );
                        }),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _savePaymentDetails,
                          activeColor: const Color(0xFFE53935),
                          checkColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _savePaymentDetails = value ?? false;
                            });
                          },
                          title: Text(
                            'Save card details for future payments',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total price',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _money(total),
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE53935),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 64,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => _handlePayNow(context, cart),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A3837),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Pay Now',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueAlign = TextAlign.left,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final TextAlign valueAlign;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.poppins(
      fontSize: isBold ? 18 : 17,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: Colors.grey.shade700,
    );

    final valueStyle = GoogleFonts.poppins(
      fontSize: isBold ? 18 : 17,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: valueColor ?? Colors.grey.shade800,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 16),
        Text(value, textAlign: valueAlign, style: valueStyle),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethodData method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? method.accentColor.withValues(alpha: 0.5)
        : Colors.transparent;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: selected ? 6 : 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            children: [
              _PaymentBadge(method: method),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  method.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? method.accentColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: selected ? 12 : 0,
                      height: selected ? 12 : 0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: method.accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.method});

  final _PaymentMethodData method;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 86,
        height: 54,
        color: method.badgeColor,
        child: Image.network(
          method.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                method.fallbackLabel,
                style: GoogleFonts.poppins(
                  fontSize: method.fallbackLabel.length > 2 ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentMethodData {
  const _PaymentMethodData({
    required this.name,
    required this.imageUrl,
    required this.fallbackLabel,
    required this.accentColor,
    required this.badgeColor,
  });

  final String name;
  final String imageUrl;
  final String fallbackLabel;
  final Color accentColor;
  final Color badgeColor;
}
