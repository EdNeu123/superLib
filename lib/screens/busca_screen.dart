import 'dart:async';

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/favorites_database.dart';
import '../services/open_library_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_details_dialog.dart';
import 'favoritos_screen.dart';

/// Tela inicial do app.
///
/// Mostra uma vitrine de livros (assunto "fiction") por padrão. Quando o
/// usuário digita algo na busca, troca para os resultados de
/// `search.json` — com debounce para não disparar uma requisição a cada
/// tecla. Scroll infinito funciona nos dois modos.
class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  static const int _pageSize = 20;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  final OpenLibraryService _service = OpenLibraryService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<Book> _books = [];
  Set<String> _favoriteKeys = {};

  // Quando null, estamos mostrando a vitrine por assunto.
  // Quando preenchida, estamos mostrando resultado de busca.
  String? _query;

  int _offset = 0; // paginação da vitrine (por assunto)
  int _page = 1; // paginação da busca (search.json usa "page")

  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
    _loadFavoriteKeys();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoadingFirstPage) return;

    // Dispara a próxima página um pouco antes de chegar ao fim da lista.
    const gatilho = 300.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - gatilho) {
      _loadMore();
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      final novaQuery = text.trim();
      setState(() => _query = novaQuery.isEmpty ? null : novaQuery);
      _loadFirstPage();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = null);
    _loadFirstPage();
  }

  Future<void> _loadFavoriteKeys() async {
    try {
      final keys = await FavoritesDatabase.instance.getFavoriteKeys();
      if (mounted) setState(() => _favoriteKeys = keys);
    } catch (_) {
      // Se o banco local falhar (ex: plataforma sem suporte), a busca
      // continua funcionando normalmente — só os favoritos ficam indisponíveis.
    }
  }

  Future<void> _toggleFavorite(Book book) async {
    final eraFavorito = _favoriteKeys.contains(book.workKey);

    // Atualiza a UI imediatamente (otimista) e só desfaz se o banco falhar.
    setState(() {
      if (eraFavorito) {
        _favoriteKeys.remove(book.workKey);
      } else {
        _favoriteKeys.add(book.workKey);
      }
    });

    try {
      if (eraFavorito) {
        await FavoritesDatabase.instance.removeFavorite(book.workKey);
      } else {
        await FavoritesDatabase.instance.addFavorite(book);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (eraFavorito) {
          _favoriteKeys.add(book.workKey);
        } else {
          _favoriteKeys.remove(book.workKey);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o favorito.')),
      );
    }
  }

  Future<void> _abrirFavoritos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritosScreen()),
    );
    // Ao voltar da tela de favoritos, o usuário pode ter removido algum
    // — recarrega as chaves pra manter os corações da listagem em dia.
    _loadFavoriteKeys();
  }

  Future<BookPage> _fetchPage({required bool isFirstPage}) {
    final query = _query;
    if (query != null) {
      final page = isFirstPage ? 1 : _page;
      return _service.searchBooks(query: query, page: page, limit: _pageSize);
    }
    final offset = isFirstPage ? 0 : _offset;
    return _service.fetchBooksBySubject(
      subject: 'fiction',
      limit: _pageSize,
      offset: offset,
    );
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _errorMessage = null;
    });

    try {
      final page = await _fetchPage(isFirstPage: true);
      setState(() {
        _books
          ..clear()
          ..addAll(page.books);
        _offset = page.books.length;
        _page = 2; // próxima página da busca, se for o caso
        _hasMore = page.hasMore;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingFirstPage = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final page = await _fetchPage(isFirstPage: false);
      setState(() {
        _books.addAll(page.books);
        _offset += page.books.length;
        _page += 1;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      // Falha ao carregar mais: mantém o que já foi exibido e avisa via
      // SnackBar, sem travar a lista já carregada.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar mais livros.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoritos',
            onPressed: _abrirFavoritos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Limpar busca',
                      onPressed: _clearSearch,
                    );
                  },
                ),
                filled: true,
                fillColor: cores.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(cores)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cores) {
    if (_isLoadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 48, color: cores.error),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar os livros.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadFirstPage,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      final query = _query;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: cores.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                query != null
                    ? 'Nenhum resultado para "$query".'
                    : 'Nenhum livro encontrado.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        // mainAxisExtent fixa a altura da linha — mais previsível que
        // childAspectRatio para um card com texto de tamanho variável.
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 100,
        ),
        // +1 para o indicador de "carregando mais" no fim da lista.
        itemCount: _books.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _books.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final book = _books[index];
          return BookCard(
            book: book,
            isFavorite: _favoriteKeys.contains(book.workKey),
            onTap: () => showBookDetailsDialog(context, book),
            onToggleFavorite: () => _toggleFavorite(book),
          );
        },
      ),
    );
  }
}