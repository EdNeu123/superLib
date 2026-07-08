import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/book_detail.dart';

/// Camada de acesso à API pública da Open Library.
///
/// Documentação usada:
///  - Listagem por assunto: https://openlibrary.org/dev/docs/api/subjects
///  - Busca por título/autor: https://openlibrary.org/dev/docs/api/search
///  - Detalhes de uma obra: https://openlibrary.org/works/{id}.json
class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';

  // Boa prática recomendada pela própria Open Library: identificar o app
  // no header User-Agent (evita ser tratado como tráfego anônimo/abusivo).
  static const Map<String, String> _headers = {
    'User-Agent': 'BuscaDeLivrosApp/1.0 (contato@buscadelivros.app)',
  };

  /// Busca livros de um assunto/categoria (usado como listagem inicial,
  /// antes de o usuário digitar algo na busca).
  ///
  /// [subject] segue o slug da Open Library, ex: "fiction", "science".
  Future<BookPage> fetchBooksBySubject({
    String subject = 'fiction',
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/subjects/$subject.json?limit=$limit&offset=$offset',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar os livros agora.');
    }

    final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final worksJson = (data['works'] as List?) ?? const [];
    final books = worksJson
        .map((w) => Book.fromSubjectJson(w as Map<String, dynamic>))
        .toList();

    final workCount = data['work_count'] as int? ?? books.length;
    final hasMore = offset + books.length < workCount;

    return BookPage(books: books, hasMore: hasMore);
  }

  /// Busca os detalhes completos de um livro a partir da sua workKey
  /// (ex: "/works/OL66534W").
  Future<BookDetail> fetchBookDetail(String workKey) async {
    final uri = Uri.parse('$_baseUrl$workKey.json');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar os detalhes deste livro.');
    }

    final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return BookDetail.fromJson(workKey, data);
  }
}
