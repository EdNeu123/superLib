import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/favorites_database.dart';
import '../widgets/book_card.dart';
import '../widgets/book_details_dialog.dart';

/// Tela que lista os livros marcados como favoritos (salvos no SQLite
/// local). Permite remover um favorito direto pelo coração do card, e
/// abrir os detalhes tocando no card.
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Book> _favoritos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favoritos = await FavoritesDatabase.instance.getAllFavorites();
      setState(() => _favoritos = favoritos);
    } catch (e) {
      setState(() => _errorMessage = 'Não foi possível carregar os favoritos.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removerFavorito(Book book) async {
    // Remove da lista imediatamente (otimista) e desfaz se der erro.
    final indiceOriginal = _favoritos.indexOf(book);
    setState(() => _favoritos.remove(book));

    try {
      await FavoritesDatabase.instance.removeFavorite(book.workKey);
    } catch (_) {
      if (!mounted) return;
      setState(() => _favoritos.insert(indiceOriginal, book));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível remover o favorito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: _buildBody(cores),
    );
  }

  Widget _buildBody(ColorScheme cores) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: cores.error),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _carregarFavoritos,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_favoritos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 48, color: cores.onSurfaceVariant),
              const SizedBox(height: 12),
              const Text(
                'Você ainda não marcou nenhum livro como favorito.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Toque no coração de um livro na busca para salvá-lo aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: cores.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarFavoritos,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 100,
        ),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          final book = _favoritos[index];
          return BookCard(
            book: book,
            isFavorite: true,
            onTap: () => showBookDetailsDialog(context, book),
            onToggleFavorite: () => _removerFavorito(book),
          );
        },
      ),
    );
  }
}