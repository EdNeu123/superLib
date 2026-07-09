# 📚 Busca e Organização de Livros

Aplicativo Flutter para pesquisar livros por título ou autor, visualizar
informações básicas (capa, autor, ano, sinopse) e salvar favoritos
localmente para consulta posterior — consumindo a API pública da
[Open Library](https://openlibrary.org/developers/api).

---

## Nome do curso

[Ads 5 FAse]

## Nome da unidade curricular

[Desenvolvimento Mobile]

## Alunos

- [Eduardo Jhonathan Passos Neumann](https://github.com/EdNeu123)
- [Iago Rech Tramontin](https://github.com/I4g0m1t0)

---

## Sobre o projeto

O app tem uma tela inicial com um campo de busca por título ou autor. Enquanto
o usuário não busca nada, é exibida uma vitrine de livros (assunto "fiction")
vinda da própria API, já com scroll infinito. Ao tocar em um livro, um pop-up
mostra os detalhes (capa, autor, ano, número de edições, sinopse e assuntos).
Cada livro pode ser marcado como favorito direto no card — os favoritos são
salvos em um banco SQLite local e ficam disponíveis em uma tela própria,
mesmo depois de fechar o app.

## Funcionalidades

- 🔎 Busca por título ou autor, com debounce (não dispara uma requisição a
  cada tecla digitada) e botão para limpar a busca e voltar à vitrine inicial.
- 📖 Vitrine inicial e resultados de busca com **scroll infinito** (carrega
  20 livros por vez, sempre que o usuário chega perto do fim da lista).
- 🖼️ Cards com capa, título e autor, em grid de 2 colunas.
- 📋 Pop-up de detalhes com capa, autor, ano de publicação, número de
  edições, sinopse e assuntos relacionados.
- ❤️ Favoritar/desfavoritar direto pelo card (ícone de coração sobre a capa).
- 📁 Tela de **Favoritos**, acessível pela barra superior, com os livros
  salvos localmente — permite remover um favorito direto por lá.
- ⏳ Indicadores de carregamento, mensagens de erro com botão de
  "Tentar novamente" e mensagens de "nenhum resultado encontrado".
- 🔄 Puxar para atualizar (`RefreshIndicator`) na listagem e nos favoritos.

## Tecnologias utilizadas

| Tecnologia | Uso no projeto |
|---|---|
| **Flutter / Dart** | Framework e linguagem do app |
| **http** | Requisições à API pública da Open Library |
| **sqflite** + **sqflite_common_ffi** | Armazenamento local dos favoritos (SQLite nativo em Android/iOS, e via FFI em Windows/Linux/macOS para testes em desktop) |
| **path** | Montagem do caminho do banco SQLite local |
| **Material Design 3** | Tema claro/escuro do app |

### API pública utilizada

- Listagem inicial: `GET https://openlibrary.org/subjects/fiction.json?limit=20&offset=...`
- Busca por título/autor: `GET https://openlibrary.org/search.json?q=...&page=...`
- Detalhes de um livro: `GET https://openlibrary.org/works/{id}.json`
- Capas: `https://covers.openlibrary.org/b/id/{cover_id}-M.jpg`

## Estrutura do projeto

```
lib/
  main.dart                        # MaterialApp, tema, tela inicial
  models/
    book.dart                      # Livro (listagem) + conversão para SQLite
    book_detail.dart                # Detalhes completos de um livro
  services/
    open_library_service.dart      # Consumo da API pública (busca e listagem)
    favorites_database.dart        # Acesso ao SQLite local (favoritos)
  screens/
    busca_screen.dart              # Tela inicial: busca + vitrine + scroll infinito
    favoritos_screen.dart          # Tela de favoritos salvos localmente
  widgets/
    book_card.dart                 # Card reutilizável (grid de busca e de favoritos)
    book_details_dialog.dart       # Pop-up de detalhes do livro
```

## Como instalar e rodar o app

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone o repositório:
   ```bash
   git clone <url-do-repositorio>
   cd controle_de_leitura_animado-main
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Rode o app (emulador Android ou dispositivo físico conectado via USB, com
   a depuração USB ativada):
   ```bash
   flutter run
   ```

> No Windows, se aparecer erro de Gradle/Java ao rodar num Android físico,
> garanta que o `flutter config --jdk-dir` aponte para um JDK 17+
> (`flutter doctor -v` mostra o que está configurado).

## Organização do trabalho em equipe

- Cada integrante ficou responsável por uma frente do projeto (estrutura e
  navegação, integração com a API, armazenamento local/favoritos, interface
  e ajustes finais).
- Cada membro abriu pelo menos um Pull Request com sua parte, revisado pelo
  grupo antes de ser integrado à branch principal.
- Commits organizados e descritivos, refletindo o progresso de cada etapa
  (estrutura → API → detalhes/favoritos → armazenamento local → ajustes finais).