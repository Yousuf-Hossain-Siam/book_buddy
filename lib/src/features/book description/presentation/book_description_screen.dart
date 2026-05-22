import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/books_notifier.dart';
import '../../home/domain/book.dart';
import '../../home/presentation/widgets/shimmer_loader.dart';

class BookDescriptionScreen extends ConsumerWidget {
  const BookDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBook = ref.watch(selectedBookProvider);
    final booksState = ref.watch(booksNotifierProvider);

    if (selectedBook == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F5F8),
        body: SafeArea(child: _BookDescriptionShimmer()),
      );
    }

    final favouriteBooks = ref.watch(favouriteBooksProvider);
    final isFavourite = favouriteBooks.any((book) => book.id == selectedBook.id);
    final relatedBooks = booksState.books.where((book) => book.id != selectedBook.id).take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEAF4FF),
                Color(0xFFF7FBFF),
                Color(0xFFF2F8FF),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _FavoriteCircleButton(
                      isFavourite: isFavourite,
                      onTap: () => ref.read(favouriteBooksProvider.notifier).toggle(selectedBook),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(child: _BookCover(book: selectedBook)),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        selectedBook.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'by ${selectedBook.author}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _MetricBlock(
                          label: 'RATING',
                          value: selectedBook.averageRating?.toStringAsFixed(1) ?? '4.8',
                          accent: true,
                        ),
                        const SizedBox(width: 20),
                        _MetricBlock(
                          label: 'YEAR',
                          value: selectedBook.publishedYear ?? '2023',
                        ),
                        const SizedBox(width: 20),
                        _MetricBlock(
                          label: 'PAGES',
                          value: selectedBook.pageCount?.toString() ?? '432',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedBook.genres.isEmpty
                          ? const [
                              _GenreChip(label: 'Literary Fiction', selected: true),
                              _GenreChip(label: 'Mystery'),
                              _GenreChip(label: 'Historical'),
                            ]
                          : selectedBook.genres.take(4).map((genre) {
                              final cleanGenre = genre.replaceFirst('subject:', '').trim();
                              return _GenreChip(
                                label: cleanGenre,
                                selected: genre == selectedBook.genres.first,
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedBook.description?.trim().isNotEmpty == true
                          ? selectedBook.description!.trim()
                          : 'No description is available for this book yet. Select another book from the home screen to explore its details.',
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: Color(0xFF4A4A57),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Similar Books',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        final selectedGenre = selectedBook.genres.isNotEmpty
                            ? selectedBook.genres.first.replaceFirst('subject:', '').trim()
                            : null;

                        if (selectedGenre != null && selectedGenre.isNotEmpty) {
                          ref.read(booksNotifierProvider.notifier).loadGenre(selectedGenre);
                        }

                        Navigator.of(context).pop();
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: booksState.isLoading || relatedBooks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _RelatedBooksShimmer(),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedBooks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final relatedBook = relatedBooks[index];
                          return _RelatedBookCard(
                            book: relatedBook,
                            onTap: () {
                              ref.read(selectedBookProvider.notifier).state = relatedBook;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BookDescriptionScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final Book book;

  const _BookCover({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3340),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F3340).withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: book.thumbnail != null
            ? Image.network(
                book.thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _coverFallback(),
              )
            : _coverFallback(),
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      color: const Color(0xFF233847),
      child: const Center(
        child: Icon(Icons.auto_stories_rounded, color: Colors.white70, size: 54),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _MetricBlock({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black38,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: accent ? const Color(0xFF4F46E5) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _GenreChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE6DCFF) : const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? const Color(0xFF5B43D8) : const Color(0xFF555A66),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: const Color(0xFF1F2430)),
        ),
      ),
    );
  }
}

class _FavoriteCircleButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onTap;

  const _FavoriteCircleButton({required this.isFavourite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavourite ? const Color(0xFF4F46E5) : const Color(0xFF1F2430),
          ),
        ),
      ),
    );
  }
}

class _RelatedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _RelatedBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: book.thumbnail != null
                    ? Image.network(book.thumbnail!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.book_outlined, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookDescriptionShimmer extends StatelessWidget {
  const _BookDescriptionShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CircleShimmer(),
                _CircleShimmer(),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Center(child: _CoverShimmer()),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _CardShimmer(),
          ),
        ],
      ),
    );
  }
}

class _CircleShimmer extends StatelessWidget {
  const _CircleShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFE6E8EE),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CoverShimmer extends StatelessWidget {
  const _CoverShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: 180,
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8EE),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(width: 180, height: 24),
            const SizedBox(height: 10),
            _line(width: 120, height: 14),
            const SizedBox(height: 18),
            Row(
              children: [
                _line(width: 58, height: 42),
                const SizedBox(width: 18),
                _line(width: 58, height: 42),
                const SizedBox(width: 18),
                _line(width: 58, height: 42),
              ],
            ),
            const SizedBox(height: 20),
            _line(width: 120, height: 18),
            const SizedBox(height: 10),
            _line(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            _line(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            _line(width: 210, height: 12),
          ],
        ),
      ),
    );
  }
}

class _RelatedBooksShimmer extends StatelessWidget {
  const _RelatedBooksShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        return SizedBox(
          width: 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(width: 128, height: 150),
              const SizedBox(height: 8),
              _line(width: 110, height: 14),
              const SizedBox(height: 3),
              _line(width: 76, height: 12),
            ],
          ),
        );
      },
    );
  }
}

Widget _line({required double width, required double height}) {
  return ShimmerLoader(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8EE),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}