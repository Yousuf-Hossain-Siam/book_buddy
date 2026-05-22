import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/book.dart';

class GoogleBooksApi {
  final http.Client _client;
  final String apiKey;

  GoogleBooksApi({http.Client? client, this.apiKey = 'AIzaSyDX49FlbF0ywsz5masLwBaDkNI0KA7Yhdc'})
      : _client = client ?? http.Client();

  /// Search books using Google Books API.
  /// [q] is the query string. [startIndex] and [maxResults] control pagination.
  Future<List<Book>> searchBooks(String q, {int startIndex = 0, int maxResults = 10}) async {
    final params = {
      'q': q,
      'startIndex': startIndex.toString(),
      'maxResults': maxResults.toString(),
      'key': apiKey,
    };

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', params);
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Books API error: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(resp.body) as Map<String, dynamic>;
    final items = jsonBody['items'] as List<dynamic>?;
    if (items == null) return [];

    return items.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }
}
