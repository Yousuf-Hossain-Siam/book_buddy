import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/books_notifier.dart';
import '../../home/domain/book.dart';
import '../../book description/presentation/book_description_screen.dart';
import '../../../core/widgets/app_gradient_background.dart';
import 'bottom_nav_bar.dart';
import 'widgets/shimmer_loader.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<String> _genres = [
    'All',
    'Fiction',
    'Science',
    'Business',
    'History',
    'Romance',
    'Mystery',
    'Fantasy',
    'Biography',
    'Travel',
    'Health',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(booksNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final visibleBooks = _filteredBooks(state.books, searchQuery);
    final trimmedQuery = searchQuery.trim();

    // Trigger initial load once after first build if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.books.isEmpty && !state.isLoading) {
        ref.read(booksNotifierProvider.notifier).loadInitial();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: AppGradientBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        const Text(
                          'BookBuddy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello Reader ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: '\u{1F44B}'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ready to find your next favorite story?',
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 16),

                // Search field
                TextField(
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  onSubmitted: (value) {
                    final query = value.trim();
                    ref.read(searchQueryProvider.notifier).state = query;
                    ref
                        .read(booksNotifierProvider.notifier)
                        .loadInitial(query.isEmpty ? null : query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, or genre...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    // ignore: deprecated_member_use
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (trimmedQuery.isNotEmpty) ...[
                  _SearchResultsHeader(resultCount: visibleBooks.length),
                  const SizedBox(height: 10),
                  if (state.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.error != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.error ?? 'Failed to load books.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _refreshBooks(ref),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (visibleBooks.isEmpty)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshBooks(ref),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            _EmptySearchState(),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshBooks(ref),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: visibleBooks.length,
                          itemBuilder: (context, index) {
                            final book = visibleBooks[index];
                            return _BookCard(
                              book: book,
                              onTap: () {
                                ref.read(selectedBookProvider.notifier).state =
                                    book;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BookDescriptionScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ] else ...[
                  // Category chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _genres.length,
                      itemBuilder: (context, index) {
                        final genre = _genres[index];
                        return _buildChip(
                          genre,
                          selected:
                              state.selectedGenre == genre ||
                              (state.selectedGenre == null &&
                                  genre == _genres.first),
                          onSelected: () {
                            if (genre == 'All') {
                              ref
                                  .read(booksNotifierProvider.notifier)
                                  .loadInitial();
                            } else {
                              ref
                                  .read(booksNotifierProvider.notifier)
                                  .loadGenre(genre);
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Book list with scroll notification for pagination
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _refreshBooks(ref),
                      child: state.isLoading
                          ? ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (context, index) =>
                                  const ShimmerBookCard(),
                            )
                          : (state.error != null && state.books.isEmpty)
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 120),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(state.error ?? 'Failed to load books.'),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () => ref
                                                .read(booksNotifierProvider.notifier)
                                                .loadInitial(),
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent - 200) {
                                      ref
                                          .read(booksNotifierProvider.notifier)
                                          .loadMore();
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        state.books.length +
                                        (state.isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index >= state.books.length) {
                                        return const ShimmerBookCard();
                                      }

                                      final book = state.books[index];
                                      return _BookCard(
                                        book: book,
                                        onTap: () {
                                          ref
                                                  .read(
                                                    selectedBookProvider.notifier,
                                                  )
                                                  .state =
                                              book;
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const BookDescriptionScreen(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Book> _filteredBooks(List<Book> books, String searchQuery) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return books;

    return books.where((book) {
      final titleMatch = book.title.toLowerCase().contains(query);
      final authorMatch = book.author.toLowerCase().contains(query);
      final genreMatch = book.genres.any(
        (genre) => genre.toLowerCase().contains(query),
      );
      return titleMatch || authorMatch || genreMatch;
    }).toList();
  }

  Future<void> _refreshBooks(WidgetRef ref) async {
    await ref.read(booksNotifierProvider.notifier).refreshCurrent();
  }

  Widget _buildChip(
    String label, {
    bool selected = false,
    VoidCallback? onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        backgroundColor: const Color(0xFFF6F6F8),
        selectedColor: Colors.deepPurple,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
        onSelected: (_) => onSelected?.call(),
      ),
    );
  }
}

class _SearchResultsHeader extends StatelessWidget {
  final int resultCount;

  const _SearchResultsHeader({required this.resultCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Search Results',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(
          '$resultCount books',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No books match your search.',
        style: TextStyle(color: Colors.black54, fontSize: 16),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFFCFCFD),
        elevation: 10,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 104,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEAF4FF), Color(0xFFD6E9FF)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.thumbnail != null
                        ? Image.network(
                            book.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _bookFallback(),
                          )
                        : _bookFallback(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.author,
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookFallback() {
    return Container(
      color: const Color(0xFFF4F8FF),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Color(0xFF6B8FC7),
          size: 34,
        ),
      ),
    );
  }
}
