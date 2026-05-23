import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/books_notifier.dart';
import '../../home/domain/book.dart';
import '../../home/presentation/bottom_nav_bar.dart';
import '../../book description/presentation/book_description_screen.dart';
import '../../../core/widgets/app_gradient_background.dart';

class FavouriteBooksScreen extends ConsumerWidget {
  const FavouriteBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouriteBooks = ref.watch(favouriteBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: AppGradientBackground(
          child: RefreshIndicator(
            onRefresh: () => ref.read(favouriteBooksProvider.notifier).reload(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Favorites',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'The books that captured your imagination.',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (favouriteBooks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavoritesState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _FavouriteBookCard(book: favouriteBooks[index]);
                      }, childCount: favouriteBooks.length),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavouriteBookCard extends ConsumerWidget {
  final Book book;

  const _FavouriteBookCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavourite = ref
        .watch(favouriteBooksProvider)
        .any((item) => item.id == book.id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ref.read(selectedBookProvider.notifier).state = book;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookDescriptionScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: book.thumbnail != null
                            ? Image.network(book.thumbnail!, fit: BoxFit.cover)
                            : Container(
                                color: const Color(0xFFE9EDF5),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.black26,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavouritePill(
                        isFavourite: isFavourite,
                        onTap: () => ref
                            .read(favouriteBooksProvider.notifier)
                            .toggle(book),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavouritePill extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onTap;

  const _FavouritePill({required this.isFavourite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.88),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: const Color(0xFF4F46E5),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 56, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Tap the heart on a book to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
