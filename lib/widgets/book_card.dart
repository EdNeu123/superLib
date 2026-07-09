import 'package:flutter/material.dart';
import '../models/book.dart';

/// Card usado no grid de livros (3 colunas): capa à esquerda (com botão de
/// favorito sobreposto), título e autor à direita. Ao tocar no card, abre
/// o pop-up de detalhes — [onTap]. Ao tocar no coração, marca/desmarca
/// como favorito — [onToggleFavorite].
class BookCard extends StatelessWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: book.workKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 56,
                        height: 82,
                        child: _Cover(book: book, cores: cores),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onToggleFavorite,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
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
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.authorsText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
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

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 14,
          color: isFavorite ? Colors.redAccent : Colors.white,
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
              width: 16,
              height: 16,
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
        size: 26,
        color: cores.onSurfaceVariant,
      ),
    );
  }
}