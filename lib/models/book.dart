/// Representa um livro na listagem (resultado de busca ou de um assunto).
///
/// Os campos vêm das APIs `/search.json` e `/subjects/{assunto}.json` da
/// Open Library, que retornam um formato bem parecido entre si.
class Book {
  final String workKey; // ex: "/works/OL66534W" — identificador único do livro
  final String title;
  final List<String> authorNames;
  final int? coverId;
  final int? firstPublishYear;
  final int? editionCount;

  const Book({
    required this.workKey,
    required this.title,
    required this.authorNames,
    this.coverId,
    this.firstPublishYear,
    this.editionCount,
  });

  /// Constrói a partir de um item da lista "works" do endpoint de assuntos:
  /// https://openlibrary.org/subjects/{assunto}.json
  factory Book.fromSubjectJson(Map<String, dynamic> json) {
    final authors = (json['authors'] as List?)
            ?.map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        const <String>[];

    return Book(
      workKey: json['key'] as String? ?? '',
      title: json['title'] as String? ?? 'Sem título',
      authorNames: authors,
      coverId: json['cover_id'] as int?,
      firstPublishYear: json['first_publish_year'] as int?,
      editionCount: json['edition_count'] as int?,
    );
  }

  /// Constrói a partir de um item "docs" do endpoint de busca:
  /// https://openlibrary.org/search.json?q=...
  factory Book.fromSearchJson(Map<String, dynamic> json) {
    final rawKey = json['key'] as String? ?? '';
    final authors = (json['author_name'] as List?)
            ?.map((a) => a.toString())
            .toList() ??
        const <String>[];

    return Book(
      // O search.json retorna a key sem o prefixo "/works/", então normalizamos.
      workKey: rawKey.startsWith('/works/') ? rawKey : '/works/$rawKey',
      title: json['title'] as String? ?? 'Sem título',
      authorNames: authors,
      coverId: json['cover_i'] as int?,
      firstPublishYear: json['first_publish_year'] as int?,
      editionCount: json['edition_count'] as int?,
    );
  }

  String get authorsText =>
      authorNames.isEmpty ? 'Autor desconhecido' : authorNames.join(', ');

  String? get coverUrl =>
      coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg' : null;
}

/// Uma "página" de resultados, usada para controlar o scroll infinito.
class BookPage {
  final List<Book> books;
  final bool hasMore;

  const BookPage({required this.books, required this.hasMore});
}
