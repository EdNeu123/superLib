import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_detail.dart';
import '../services/open_library_service.dart';

/// Exibe o pop-up de detalhes de um [book].
///
/// Uso: `showBookDetailsDialog(context, book);`
Future<void> showBookDetailsDialog(BuildContext context, Book book) {
  return showDialog(
    context: context,
    builder: (_) => BookDetailsDialog(book: book),
  );
}

class BookDetailsDialog extends StatefulWidget {
  final Book book;

  const BookDetailsDialog({super.key, required this.book});

  @override
  State<BookDetailsDialog> createState() => _BookDetailsDialogState();
}

class _BookDetailsDialogState extends State<BookDetailsDialog> {
  final _service = OpenLibraryService();
  late Future<BookDetail> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = _service.fetchBookDetail(widget.book.workKey);
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final book = widget.book;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: book.workKey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 90,
                              height: 130,
                              child: book.coverUrl != null
                                  ? Image.network(
                                      book.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _coverPlaceholder(cores),
                                    )
                                  : _coverPlaceholder(cores),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authorsText,
                                style: TextStyle(color: cores.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              if (book.firstPublishYear != null)
                                _InfoChip(
                                  icon: Icons.calendar_today,
                                  label: '${book.firstPublishYear}',
                                ),
                              if (book.editionCount != null)
                                _InfoChip(
                                  icon: Icons.menu_book,
                                  label: '${book.editionCount} edições',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<BookDetail>(
                      future: _futureDetail,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Não foi possível carregar a sinopse deste livro.',
                              style: TextStyle(color: cores.error),
                            ),
                          );
                        }

                        final detail = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (detail.description != null &&
                                detail.description!.isNotEmpty) ...[
                              const Text(
                                'Sinopse',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                detail.description!,
                                style: const TextStyle(height: 1.4),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (detail.subjects.isNotEmpty) ...[
                              const Text(
                                'Assuntos',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: detail.subjects
                                    .take(8)
                                    .map((s) => Chip(
                                          label: Text(
                                            s,
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder(ColorScheme cores) => Container(
        color: cores.surfaceContainerHighest,
        child: Icon(Icons.menu_book_rounded, color: cores.onSurfaceVariant),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cores.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: cores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
