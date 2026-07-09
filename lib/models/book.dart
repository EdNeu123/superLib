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

  /// Converte para o formato de linha usada na tabela `favorites` (SQLite).
  Map<String, Object?> toDbMap() {
    return {
      'work_key': workKey,
      'title': title,
      // sqflite não guarda listas nativamente — junta os autores em uma
      // única string separada por "|" e desfaz em [Book.fromDbMap].
      'authors': authorNames.join('|'),
      'cover_id': coverId,
      'first_publish_year': firstPublishYear,
      'edition_count': editionCount,
    };
  }

  /// Reconstrói um [Book] a partir de uma linha da tabela `favorites`.
  factory Book.fromDbMap(Map<String, Object?> map) {
    final authorsRaw = map['authors'] as String?;
    return Book(
      workKey: map['work_key'] as String,
      title: map['title'] as String,
      authorNames: (authorsRaw == null || authorsRaw.isEmpty)
          ? const []
          : authorsRaw.split('|'),
      coverId: map['cover_id'] as int?,
      firstPublishYear: map['first_publish_year'] as int?,
      editionCount: map['edition_count'] as int?,
    );
  }
}

/// Uma "página" de resultados, usada para controlar o scroll infinito.
class BookPage {
  final List<Book> books;
  final bool hasMore;

  const BookPage({required this.books, required this.hasMore});
}