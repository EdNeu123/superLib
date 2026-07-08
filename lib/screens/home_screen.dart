import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../widgets/livro_card.dart';
import 'detalhe_livro_screen.dart';

class HomeScreen extends StatelessWidget {
  final String nome;

  const HomeScreen({super.key, required this.nome});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final livros = Livro.exemplos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Livros'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Boas-vindas com nome do usuário
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: cores.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $nome!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seus últimos livros lidos:',
                  style: TextStyle(
                    fontSize: 14,
                    color: cores.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de livros — usa o widget customizado LivroCard (primeiro uso)
          Expanded(
            child: ListView.builder(
              itemCount: livros.length,
              itemBuilder: (context, index) {
                final livro = livros[index];
                return LivroCard(
                  livro: livro,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalheLivroScreen(livro: livro),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
