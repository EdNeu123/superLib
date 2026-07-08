import 'package:flutter/material.dart';
import '../models/book.dart';

/// Card usado no grid de livros (3 colunas): capa pequena à esquerda,
/// título e autor à direita. Ao tocar, abre o pop-up de detalhes — [onTap].
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
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: book.workKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 38,
                    height: 56,
                    child: _Cover(book: book, cores: cores),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.authorsText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              width: 12,
              height: 12,
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
        size: 18,
        color: cores.onSurfaceVariant,
      ),
    );
  }
}