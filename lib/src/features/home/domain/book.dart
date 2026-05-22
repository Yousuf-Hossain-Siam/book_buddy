class Book {
  final String id;
  final String title;
  final String author;
  final List<String> genres;
  final String? thumbnail;
  final String? description;
  final String? publishedYear;
  final int? pageCount;
  final double? averageRating;
  final int? ratingsCount;
  final String? previewLink;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genres,
    this.thumbnail,
    this.description,
    this.publishedYear,
    this.pageCount,
    this.averageRating,
    this.ratingsCount,
    this.previewLink,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final authors = volumeInfo['authors'] as List<dynamic>?;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final categories = volumeInfo['categories'] as List<dynamic>?;
    final publishedDate = volumeInfo['publishedDate'] as String?;
    final pageCount = volumeInfo['pageCount'] as int?;
    final averageRating = (volumeInfo['averageRating'] as num?)?.toDouble();
    final ratingsCount = volumeInfo['ratingsCount'] as int?;

    String? thumb;
    if (imageLinks != null) {
      thumb = imageLinks['thumbnail'] as String? ?? imageLinks['smallThumbnail'] as String?;
      if (thumb != null && thumb.startsWith('http:')) {
        thumb = thumb.replaceFirst('http:', 'https:');
      }
    }

    return Book(
      id: json['id'] as String? ?? '',
      title: volumeInfo['title'] as String? ?? 'Unknown',
      author: (authors != null && authors.isNotEmpty) ? (authors.first as String) : 'Unknown',
      genres: categories?.map((category) => category.toString()).toList() ?? const [],
      thumbnail: thumb,
      description: volumeInfo['description'] as String?,
      publishedYear: publishedDate != null && publishedDate.isNotEmpty ? publishedDate.split('-').first : null,
      pageCount: pageCount,
      averageRating: averageRating,
      ratingsCount: ratingsCount,
      previewLink: volumeInfo['previewLink'] as String?,
    );
  }
}
