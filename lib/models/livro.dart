// Modelo simples de Livro.
// O `id` é usado como tag única do Hero (exigência da Aula 9).
// O `progresso` é um valor de 0.0 a 1.0 usado pelo CustomPainter.
class Livro {
  final String id;
  final String titulo;
  final String autor;
  final double progresso; // 0.0 a 1.0
  final int totalPaginas;
  final String sinopse;

  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.progresso,
    required this.totalPaginas,
    required this.sinopse,
  });

  // Lista fixa de livros usada no app (antes era um Map dentro do HomeScreen)
  static const List<Livro> exemplos = [
    Livro(
      id: 'livro-1',
      titulo: 'O Pequeno Príncipe',
      autor: 'Antoine de Saint-Exupéry',
      progresso: 1.0,
      totalPaginas: 96,
      sinopse:
          'Um piloto encontra, no deserto do Saara, um pequeno príncipe vindo do asteroide B-612. '
          'Uma fábula sobre amizade, amor e o olhar das crianças sobre o mundo.',
    ),
    Livro(
      id: 'livro-2',
      titulo: 'Dom Casmurro',
      autor: 'Machado de Assis',
      progresso: 0.75,
      totalPaginas: 256,
      sinopse:
          'Bentinho narra sua história com Capitu, questionando se foi traído. '
          'Um dos maiores clássicos da literatura brasileira.',
    ),
    Livro(
      id: 'livro-3',
      titulo: '1984',
      autor: 'George Orwell',
      progresso: 0.55,
      totalPaginas: 328,
      sinopse:
          'Em um regime totalitário, Winston Smith tenta manter sua individualidade '
          'sob a vigilância constante do Grande Irmão.',
    ),
    Livro(
      id: 'livro-4',
      titulo: 'O Hobbit',
      autor: 'J.R.R. Tolkien',
      progresso: 0.40,
      totalPaginas: 310,
      sinopse:
          'Bilbo Bolseiro embarca em uma aventura inesperada com treze anões e o mago Gandalf '
          'para recuperar um tesouro guardado pelo dragão Smaug.',
    ),
    Livro(
      id: 'livro-5',
      titulo: 'Clean Code',
      autor: 'Robert C. Martin',
      progresso: 0.20,
      totalPaginas: 464,
      sinopse:
          'Guia prático de boas práticas para escrever código limpo, legível e de fácil manutenção. '
          'Leitura obrigatória para desenvolvedores.',
    ),
  ];
}
