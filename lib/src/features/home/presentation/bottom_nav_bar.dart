import 'package:flutter/material.dart';
import 'dart:ui';

import '../../addtocart/presentation/add_to_cart.dart';
import '../../favourite/presentation/favourite_books_screen.dart';
import 'home_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFFFDFDFF).withOpacity(0.92),
                borderRadius: BorderRadius.circular(26),
                // ignore: deprecated_member_use
                border: Border.all(color: const Color(0xFFCBD5FF).withOpacity(0.95), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF4F46E5).withOpacity(0.24),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: currentIndex == 0,
                    onTap: () => _navigateTo(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Favorites',
                    selected: currentIndex == 1,
                    onTap: () => _navigateTo(context, 1),
                  ),
                  _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Add to cart',
                    selected: currentIndex == 2,
                    onTap: () => _navigateTo(context, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FavouriteBooksScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AddToCart()),
      );
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF3F3CFF) : const Color(0xFF626B7A);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.0,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 4,
              child: selected
                  ? Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3F3CFF),
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
