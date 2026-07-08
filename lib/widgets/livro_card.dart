import 'package:flutter/material.dart';
import '../models/livro.dart';

/// Card de livro reutilizável.
///
/// Usado em dois lugares diferentes:
///   1. Lista principal na HomeScreen
///   2. Seção "Outros livros" na tela de detalhe
///
/// Contém o `Hero` com tag única (Requisito 3 da Aula 9) — quando o
/// usuário toca no card, o ícone do livro "voa" para a tela de detalhe.
class LivroCard extends StatelessWidget {
  final Livro livro;
  final VoidCallback onTap;

  const LivroCard({
    super.key,
    required this.livro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Hero — tag única por livro, voa até a tela de detalhe
              Hero(
                tag: livro.id,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cores.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: cores.onPrimaryContainer,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Título, autor e mini barra de progresso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livro.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      livro.autor,
                      style: TextStyle(
                        fontSize: 13,
                        color: cores.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Barra de progresso M3
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: livro.progresso,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(livro.progresso * 100).toInt()}% lido',
                      style: TextStyle(
                        fontSize: 11,
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
