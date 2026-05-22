import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/google_books_api.dart';
import '../domain/book.dart';

final googleBooksApiProvider = Provider((ref) => GoogleBooksApi());
final selectedBookProvider = StateProvider<Book?>((ref) => null);

class FavouriteBooksNotifier extends StateNotifier<List<Book>> {
  FavouriteBooksNotifier() : super(const []);

  void toggle(Book book) {
    final exists = state.any((item) => item.id == book.id);
    if (exists) {
      state = state.where((item) => item.id != book.id).toList();
      return;
    }

    state = [...state, book];
  }

  bool isFavourite(String bookId) {
    return state.any((item) => item.id == bookId);
  }
}

final favouriteBooksProvider = StateNotifierProvider<FavouriteBooksNotifier, List<Book>>((ref) {
  return FavouriteBooksNotifier();
});

class BooksState {
  final List<Book> books;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final String? selectedGenre;

  BooksState({
    required this.books,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.query,
    required this.selectedGenre,
  });

  factory BooksState.initial() => BooksState(
        books: [],
        isLoading: false,
        isLoadingMore: false,
        hasMore: true,
        query: 'flutter',
        selectedGenre: null,
      );

  BooksState copyWith({
    List<Book>? books,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    String? selectedGenre,
    bool clearSelectedGenre = false,
  }) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      selectedGenre: clearSelectedGenre ? null : (selectedGenre ?? this.selectedGenre),
    );
  }
}

class BooksNotifier extends StateNotifier<BooksState> {
  final GoogleBooksApi _api;
  static const int _pageSize = 10;
  int _startIndex = 0;

  BooksNotifier(this._api) : super(BooksState.initial());

  Future<void> loadInitial([String? query]) async {
    final q = query ?? state.query;
    state = state.copyWith(
      isLoading: true,
      books: [],
      query: q,
      hasMore: true,
      clearSelectedGenre: true,
    );
    _startIndex = 0;

    try {
      final results = await _api.searchBooks(q, startIndex: _startIndex, maxResults: _pageSize);
      _startIndex += results.length;
      state = state.copyWith(books: results, isLoading: false, hasMore: results.length == _pageSize);
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  Future<void> loadGenre(String genre) async {
    final q = 'subject:$genre';
    state = state.copyWith(
      isLoading: true,
      books: [],
      query: q,
      hasMore: true,
      selectedGenre: genre,
    );
    _startIndex = 0;

    try {
      final results = await _api.searchBooks(q, startIndex: _startIndex, maxResults: _pageSize);
      _startIndex += results.length;
      state = state.copyWith(
        books: results,
        isLoading: false,
        hasMore: results.length == _pageSize,
        selectedGenre: genre,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false, selectedGenre: genre);
    }
  }

  Future<void> refreshCurrent() async {
    final query = state.selectedGenre != null ? 'subject:${state.selectedGenre!}' : state.query;

    try {
      final results = await _api.searchBooks(query, startIndex: 0, maxResults: _pageSize);
      _startIndex = results.length;
      state = state.copyWith(
        books: results,
        isLoading: false,
        isLoadingMore: false,
        hasMore: results.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, hasMore: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final results = await _api.searchBooks(state.query, startIndex: _startIndex, maxResults: _pageSize);
      _startIndex += results.length;
      final all = List<Book>.from(state.books)..addAll(results);
      state = state.copyWith(books: all, isLoadingMore: false, hasMore: results.length == _pageSize);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }
}

final booksNotifierProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  final api = ref.read(googleBooksApiProvider);
  return BooksNotifier(api);
});
