import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/google_books_api.dart';
import '../domain/book.dart';

final googleBooksApiProvider = Provider((ref) => GoogleBooksApi());
final selectedBookProvider = StateProvider<Book?>((ref) => null);

class CartItem {
  final Book book;
  final int quantity;

  const CartItem({required this.book, required this.quantity});

  CartItem copyWith({Book? book, int? quantity}) {
    return CartItem(
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      book: Book.fromJson(json['book'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class FavouriteBooksNotifier extends StateNotifier<List<Book>> {
  static const String _storageKey = 'favourite_books';

  FavouriteBooksNotifier() : super(const []) {
    unawaited(_loadFromStorage());
  }

  Future<void> _loadFromStorage() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }

    final encodedBooks = prefs.getStringList(_storageKey) ?? const [];

    state = encodedBooks
        .map((encodedBook) => Book.fromJson(jsonDecode(encodedBook) as Map<String, dynamic>))
        .toList();
  }

  Future<void> reload() async {
    await _loadFromStorage();
  }

  Future<void> _saveToStorage() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }

    final encodedBooks = state.map((book) => jsonEncode(book.toJson())).toList();
    await prefs.setStringList(_storageKey, encodedBooks);
  }

  Future<void> toggle(Book book) async {
    final exists = state.any((item) => item.id == book.id);
    if (exists) {
      state = state.where((item) => item.id != book.id).toList();
    } else {
      state = [...state, book];
    }

    await _saveToStorage();
  }

  bool isFavourite(String bookId) {
    return state.any((item) => item.id == bookId);
  }
}

final favouriteBooksProvider = StateNotifierProvider<FavouriteBooksNotifier, List<Book>>((ref) {
  return FavouriteBooksNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  static const String _storageKey = 'cart_items';

  CartNotifier() : super(const []) {
    unawaited(_loadFromStorage());
  }

  Future<void> _loadFromStorage() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }

    final encodedItems = prefs.getStringList(_storageKey) ?? const [];

    state = encodedItems
        .map((encodedItem) => CartItem.fromJson(jsonDecode(encodedItem) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToStorage() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }

    final encodedItems = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, encodedItems);
  }

  Future<void> add(Book book) async {
    final index = state.indexWhere((item) => item.book.id == book.id);

    if (index == -1) {
      state = [...state, CartItem(book: book, quantity: 1)];
    } else {
      final updatedItems = [...state];
      updatedItems[index] = updatedItems[index].copyWith(quantity: updatedItems[index].quantity + 1);
      state = updatedItems;
    }

    await _saveToStorage();
  }

  Future<void> increase(Book book) async {
    await add(book);
  }

  Future<void> decrease(Book book) async {
    final index = state.indexWhere((item) => item.book.id == book.id);
    if (index == -1) {
      return;
    }

    final updatedItems = [...state];
    final currentItem = updatedItems[index];

    if (currentItem.quantity <= 1) {
      updatedItems.removeAt(index);
    } else {
      updatedItems[index] = currentItem.copyWith(quantity: currentItem.quantity - 1);
    }

    state = updatedItems;
    await _saveToStorage();
  }

  Future<void> remove(Book book) async {
    state = state.where((item) => item.book.id != book.id).toList();
    await _saveToStorage();
  }

  Future<void> clear() async {
    state = const [];
    await _saveToStorage();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class BooksState {
  final List<Book> books;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String query;
  final String? selectedGenre;

  BooksState({
    required this.books,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.query,
    required this.selectedGenre,
  });

  factory BooksState.initial() => BooksState(
        books: [],
        isLoading: false,
        isLoadingMore: false,
        hasMore: true,
      error: null,
        query: 'flutter',
        selectedGenre: null,
      );

  BooksState copyWith({
    List<Book>? books,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    String? error,
    String? selectedGenre,
    bool clearSelectedGenre = false,
  }) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
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
      error: null,
      hasMore: true,
      clearSelectedGenre: true,
    );
    _startIndex = 0;

    try {
      final results = await _api.searchBooks(q, startIndex: _startIndex, maxResults: _pageSize);
      _startIndex += results.length;
      state = state.copyWith(books: results, isLoading: false, hasMore: results.length == _pageSize, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false, error: e.toString());
    }
  }

  Future<void> loadGenre(String genre) async {
    final q = 'subject:$genre';
    state = state.copyWith(
      isLoading: true,
      books: [],
      query: q,
      error: null,
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
        error: null,
        selectedGenre: genre,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false, selectedGenre: genre, error: e.toString());
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
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, hasMore: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final results = await _api.searchBooks(state.query, startIndex: _startIndex, maxResults: _pageSize);
      _startIndex += results.length;
      final deduped = results.where((r) => !state.books.any((b) => b.id == r.id)).toList();
      final all = List<Book>.from(state.books)..addAll(deduped);
      state = state.copyWith(books: all, isLoadingMore: false, hasMore: results.length == _pageSize, error: null);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, hasMore: false, error: e.toString());
    }
  }
}

final booksNotifierProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  final api = ref.read(googleBooksApiProvider);
  return BooksNotifier(api);
});
