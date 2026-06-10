import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'open_url.dart';

class HomeLocationBar extends StatelessWidget {
  const HomeLocationBar({
    super.key,
    required this.locationLabel,
    required this.mapUrl,
    this.onTap,
  });

  final String locationLabel;
  final String mapUrl;
  final VoidCallback? onTap;

  Future<void> _openMap(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final launched = await openExternalUrl(mapUrl);
    if (launched) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Could not open Google Maps.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap ?? () => _openMap(context),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFE5E0FA),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF6D5BD0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3F345C),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7B6E9A),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
