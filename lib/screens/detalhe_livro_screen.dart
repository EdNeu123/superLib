import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../widgets/botao_primario.dart';
import '../widgets/livro_card.dart';
import '../painters/progresso_circular_painter.dart';

/// Tela de detalhe do livro.
///
/// Reúne os principais requisitos da Aula 9:
///   - Hero (destino) com o ícone que veio da Home
///   - AnimationController + Tween + CurvedAnimation + AnimatedBuilder
///     animando o progresso circular (0 → valor real)
///   - AnimatedContainer reagindo ao toque do botão "Marcar como lido"
///   - CustomPainter desenhando o arco de progresso (bônus)
///   - FilledButton (M3) via o widget customizado BotaoPrimario
class DetalheLivroScreen extends StatefulWidget {
  final Livro livro;

  const DetalheLivroScreen({super.key, required this.livro});

  @override
  State<DetalheLivroScreen> createState() => _DetalheLivroScreenState();
}

class _DetalheLivroScreenState extends State<DetalheLivroScreen>
    with SingleTickerProviderStateMixin {
  // ---- Animação explícita ----
  late AnimationController _controller;
  late Animation<double> _animacaoProgresso;

  // ---- Estado para a animação implícita ----
  bool _marcadoComoLido = false;

  @override
  void initState() {
    super.initState();

    // Controller que dura 1200ms — tempo suficiente para o arco preencher
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Tween: vai de 0.0 até o progresso real do livro
    // CurvedAnimation: easeOutCubic dá uma desaceleração suave no final
    _animacaoProgresso = Tween<double>(
      begin: 0.0,
      end: widget.livro.progresso,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Inicia a animação quando a tela abre
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // SEMPRE liberar o controller
    super.dispose();
  }

  void _marcarComoLido() {
    setState(() => _marcadoComoLido = !_marcadoComoLido);
    // Reanima o arco quando marca como lido (vai até 100%)
    if (_marcadoComoLido) {
      _animacaoProgresso = Tween<double>(
        begin: _animacaoProgresso.value,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final livro = widget.livro;

    // Outros livros para a seção "Continue lendo"
    final outrosLivros = Livro.exemplos
        .where((l) => l.id != livro.id)
        .take(2)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----------------------------------------------------------------
            // Cabeçalho com Hero + CustomPainter animado
            // ----------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: cores.surfaceContainerLow,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // CustomPainter + AnimatedBuilder — reconstrói apenas
                      // o arco a cada frame, não a árvore inteira.
                      AnimatedBuilder(
                        animation: _animacaoProgresso,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(200, 200),
                            painter: ProgressoCircularPainter(
                              progresso: _animacaoProgresso.value,
                              corFundo: cores.surfaceContainerHighest,
                              corProgresso: cores.primary,
                            ),
                          );
                        },
                      ),

                      // Hero destino — mesma tag que estava na Home
                      Hero(
                        tag: livro.id,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cores.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: cores.onPrimaryContainer,
                            size: 56,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título e autor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livro.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    livro.autor,
                    style: TextStyle(
                      fontSize: 16,
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------------------
            // AnimatedContainer — animação implícita
            // Muda cor, padding e borderRadius quando o livro é marcado
            // como lido. Duração de 400ms com curva easeInOut.
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(_marcadoComoLido ? 20 : 12),
                decoration: BoxDecoration(
                  color: _marcadoComoLido
                      ? cores.primaryContainer
                      : cores.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(_marcadoComoLido ? 20 : 12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _marcadoComoLido
                          ? Icons.check_circle
                          : Icons.auto_stories,
                      color: _marcadoComoLido
                          ? cores.onPrimaryContainer
                          : cores.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _marcadoComoLido
                            ? 'Livro marcado como lido!'
                            : '${livro.totalPaginas} páginas • '
                                '${(livro.progresso * 100).toInt()}% concluído',
                        style: TextStyle(
                          color: _marcadoComoLido
                              ? cores.onPrimaryContainer
                              : cores.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sinopse
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    livro.sinopse,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão customizado (segundo uso do BotaoPrimario)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BotaoPrimario(
                texto: _marcadoComoLido
                    ? 'Marcado como lido'
                    : 'Marcar como lido',
                icone: _marcadoComoLido
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                onPressed: _marcarComoLido,
              ),
            ),

            const SizedBox(height: 32),

            // Seção "Outros livros" — usa o LivroCard pela segunda vez
            if (outrosLivros.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Outros livros',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...outrosLivros.map(
                (l) => LivroCard(
                  livro: l,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalheLivroScreen(livro: l),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
