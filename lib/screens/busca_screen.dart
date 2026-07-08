import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/open_library_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_details_dialog.dart';

/// Tela inicial do app.
///
/// ETAPA ATUAL: carrega livros da Open Library (assunto "fiction" como
/// vitrine inicial) com paginação (20 por vez) e scroll infinito. Ao tocar
/// em um card, abre o pop-up de detalhes.
///
/// A busca por título/autor (campo no topo) será ligada na próxima etapa.
class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  static const int _pageSize = 20;

  final OpenLibraryService _service = OpenLibraryService();
  final ScrollController _scrollController = ScrollController();

  final List<Book> _books = [];
  int _offset = 0;
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _errorMessage = null;
    });

    try {
      final page = await _service.fetchBooksBySubject(
        subject: 'fiction',
        limit: _pageSize,
        offset: 0,
      );
      setState(() {
        _books
          ..clear()
          ..addAll(page.books);
        _offset = page.books.length;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoadingFirstPage = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final page = await _service.fetchBooksBySubject(
        subject: 'fiction',
        limit: _pageSize,
        offset: _offset,
      );
      setState(() {
        _books.addAll(page.books);
        _offset += page.books.length;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      // Falha ao carregar mais: mantém o que já foi exibido e avisa via SnackBar,
      // sem travar a lista já carregada.
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
      ),
      body: Column(
        children: [
          // Campo de busca — visual pronto, funcionalidade na próxima etapa.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor (em breve)',
                prefixIcon: const Icon(Icons.search),
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
      return const Center(child: Text('Nenhum livro encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.58,
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
            onTap: () => showBookDetailsDialog(context, book),
          );
        },
      ),
    );
  }
}
