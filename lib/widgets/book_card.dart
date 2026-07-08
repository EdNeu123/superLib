import 'package:flutter/material.dart';
import '../models/book.dart';

/// Card usado no grid de livros. Mostra a capa e o título/autor.
/// Ao tocar, abre o pop-up (Dialog) com os detalhes — ver [onTap].
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: book.workKey,
                child: _Cover(book: book, cores: cores),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.authorsText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final Book book;
  final ColorScheme cores;

  const _Cover({required this.book, required this.cores});

  @override
  Widget build(BuildContext context) {
    final url = book.coverUrl;
    if (url == null) {
      return _placeholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      // Placeholder enquanto a imagem carrega — evita "pulos" de layout.
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: cores.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: cores.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book_rounded,
        size: 40,
        color: cores.onSurfaceVariant,
      ),
    );
  }
}
