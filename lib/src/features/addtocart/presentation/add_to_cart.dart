import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/books_notifier.dart';
import '../../home/presentation/bottom_nav_bar.dart';
import '../../../core/widgets/app_gradient_background.dart';

class AddToCart extends ConsumerWidget {
  const AddToCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: AppGradientBackground(
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Books saved for later or ready to check out.',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (cartItems.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyCartState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: cartItems.length + 1,
                    separatorBuilder: (_, index) =>
                        index == cartItems.length - 1
                        ? const SizedBox(height: 16)
                        : const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == cartItems.length) {
                        return _CartSummary(
                          totalItems: cartItems.fold<int>(
                            0,
                            (sum, item) => sum + item.quantity,
                          ),
                          uniqueItems: cartItems.length,
                        );
                      }

                      final cartItem = cartItems[index];
                      return _CartItemCard(item: cartItem);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.black26),
            SizedBox(height: 14),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Add a book from the details screen to keep it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 8,
      shadowColor: const Color(0x14000000),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 82,
                height: 112,
                child: item.book.thumbnail != null
                    ? Image.network(item.book.thumbnail!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFE9EDF5),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.black26,
                          size: 36,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () =>
                            ref.read(cartProvider.notifier).decrease(item.book),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () =>
                            ref.read(cartProvider.notifier).increase(item.book),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () =>
                            ref.read(cartProvider.notifier).remove(item.book),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalItems;
  final int uniqueItems;

  const _CartSummary({required this.totalItems, required this.uniqueItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Items', value: totalItems.toString()),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Unique books', value: uniqueItems.toString()),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Status', value: 'Ready to checkout'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
