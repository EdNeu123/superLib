# Controle de Leitura — Galeria de Animações

**Atividade Prática — Aula 9 | Desenvolvimento para Dispositivos Móveis**

---

## Aluno

Eduardo Jhonathan Passos Neumann
ADS — 5ª Fase | Faculdade Senac Joinville | 2026/1

---

## Descrição

Aplicativo Flutter que simula um controle de leitura pessoal. Parte da avaliação prática das aulas 7/8 (cadastro, login e lista de livros) e foi estendido na Aula 9 para demonstrar **animações implícitas e explícitas, Hero animation, Material Design 3, widgets customizados reutilizáveis e CustomPainter**.

---

## Fluxo de navegação

```
Cadastro ──(push)──→ Login ──(pushAndRemoveUntil)──→ Home ──(push)──→ Detalhe do Livro
                                                       (pilha limpa,
                                                        sem voltar)
```

---

## Requisitos da Aula 9 — onde cada um está

| Requisito | Implementação |
|---|---|
| **1. Animação implícita** | `AnimatedOpacity` nas mensagens de erro (Cadastro/Login) — fade suave de 300ms. `AnimatedContainer` no card de status da tela de detalhe — muda cor, padding e `borderRadius` em 400ms com `Curves.easeInOut` ao marcar o livro como lido. |
| **2. Animação explícita** | `DetalheLivroScreen`: `AnimationController` (1200ms, `SingleTickerProviderStateMixin`) + `Tween<double>(begin: 0.0, end: livro.progresso)` + `CurvedAnimation(curve: Curves.easeOutCubic)` + `AnimatedBuilder`. `dispose()` do controller é chamado corretamente. |
| **3. Hero Animation** | Ícone do livro "voa" do `LivroCard` (Home) até o cabeçalho do `DetalheLivroScreen`. Cada livro tem uma `tag` única (`livro.id` — `livro-1`, `livro-2`, ...). |
| **4. Material Design 3** | `useMaterial3: true` + `ColorScheme.fromSeed(seedColor: Colors.indigo)` no `main.dart`, com tema claro e escuro. Componente M3 utilizado: `FilledButton` (dentro do `BotaoPrimario`). |
| **5. Widget customizado** | Dois widgets com `const` constructor e parâmetros: `BotaoPrimario` (usado em Cadastro, Login e Detalhe — 3 lugares) e `LivroCard` (usado na Home e na seção "Outros livros" da tela de detalhe — 2 lugares). |
| **🌟 BÔNUS — CustomPainter** | `ProgressoCircularPainter` desenha um círculo de fundo com `drawCircle` e um arco de progresso com `drawArc`. Implementa `shouldRepaint` corretamente (só redesenha quando o progresso ou as cores mudam). |

---

## Estrutura do projeto

```
lib/
├── main.dart                              # Tema M3 (claro + escuro)
├── models/
│   └── livro.dart                         # Modelo com id, titulo, autor, progresso, sinopse
├── widgets/
│   ├── botao_primario.dart                # Widget customizado #1 (FilledButton)
│   └── livro_card.dart                    # Widget customizado #2 (contém o Hero)
├── painters/
│   └── progresso_circular_painter.dart    # CustomPainter (bônus)
└── screens/
    ├── cadastro_screen.dart               # BotaoPrimario + AnimatedOpacity
    ├── login_screen.dart                  # BotaoPrimario + AnimatedOpacity
    ├── home_screen.dart                   # LivroCard + Hero origem
    └── detalhe_livro_screen.dart          # Hero destino + Controller + AnimatedContainer + CustomPainter
```

---

## Detalhamento das animações

### Na tela de detalhe (onde mora a maior parte)

1. **Ao abrir a tela**, o `AnimationController.forward()` dispara e o arco de progresso circular preenche de 0% até o progresso real do livro — desacelerando no final (`easeOutCubic`) em 1200ms.
2. **O `AnimatedBuilder`** reconstrói apenas o `CustomPaint`, não a árvore inteira — padrão recomendado para performance.
3. **Ao tocar em "Marcar como lido"**, o `AnimatedContainer` do card de status anima (cor, padding e borda arredondada) em 400ms, e um novo `Tween` é criado para animar o arco até 100%.
4. **O Hero** do ícone do livro anima automaticamente da Home para o centro do círculo de progresso.

### Nas telas de autenticação

- Mensagens de erro aparecem com `AnimatedOpacity` em 300ms, em vez de "piscar" na tela.

---

## Como executar

```bash
git clone 
cd controle-leitura-flutter
flutter pub get
flutter run
```

---

## Conceitos utilizados

- **Dart**: classes, construtores com parâmetros nomeados, `const` constructors, `late`
- **Flutter Widgets**: Scaffold, AppBar, Column, Row, Text, TextField, FilledButton, Icon, Container, Card, InkWell, ListView.builder, SingleChildScrollView, LinearProgressIndicator, Stack, SizedBox, ClipRRect
- **Animações implícitas**: AnimatedContainer, AnimatedOpacity
- **Animações explícitas**: AnimationController, Tween, CurvedAnimation, AnimatedBuilder, SingleTickerProviderStateMixin
- **Hero Animation**: transição entre telas com tag única
- **Material Design 3**: ColorScheme.fromSeed, FilledButton, primaryContainer/onPrimaryContainer, surfaceContainer, tema claro e escuro
- **Desenho customizado**: CustomPainter, Canvas.drawCircle, Canvas.drawArc, Paint (stroke, strokeCap, strokeWidth), shouldRepaint
- **Gerenciamento de estado**: StatefulWidget, setState
- **Ciclo de vida**: initState (iniciar controller), dispose (liberar controller e TextEditingControllers)
- **Navegação**: Navigator.push, Navigator.pushReplacement, Navigator.pushAndRemoveUntil

---

## Screenshots

Screenshots das telas de Cadastro, Login e Home do projeto base estão em `screenshots/`. Para a Aula 9, recomenda-se adicionar capturas demonstrando a transição Hero e o arco de progresso animado.
