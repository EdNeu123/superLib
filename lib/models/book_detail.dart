/// Detalhes completos de um livro, obtidos em
/// https://openlibrary.org/works/{id}.json
class BookDetail {
  final String workKey;
  final String title;
  final String? description;
  final List<String> subjects;
  final String? firstPublishDate;

  const BookDetail({
    required this.workKey,
    required this.title,
    this.description,
    this.subjects = const [],
    this.firstPublishDate,
  });

  factory BookDetail.fromJson(String workKey, Map<String, dynamic> json) {
    // A descrição pode vir como String simples ou como
    // { "type": "/type/text", "value": "..." }
    String? desc;
    final rawDesc = json['description'];
    if (rawDesc is String) {
      desc = rawDesc;
    } else if (rawDesc is Map && rawDesc['value'] is String) {
      desc = rawDesc['value'] as String;
    }

    return BookDetail(
      workKey: workKey,
      title: json['title'] as String? ?? '',
      description: desc,
      subjects: (json['subjects'] as List?)?.map((s) => s.toString()).toList() ??
          const [],
      firstPublishDate: json['first_publish_date'] as String?,
    );
  }
}
