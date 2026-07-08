import 'package:flutter/material.dart';
import '../widgets/botao_primario.dart';
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // Controllers para os campos (Aula 7)
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Mensagem de erro
  String _erro = '';

  // Valida e navega para Login passando os dados (Aula 8)
  void _cadastrar() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    // Validação simples
    if (nome.isEmpty) {
      setState(() => _erro = 'Informe seu nome.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _erro = 'Informe seu e-mail.');
      return;
    }
    if (senha.isEmpty) {
      setState(() => _erro = 'Informe sua senha.');
      return;
    }
    if (senha.length < 4) {
      setState(() => _erro = 'A senha deve ter pelo menos 4 caracteres.');
      return;
    }

    // Navega para Login passando os dados via construtor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          nome: nome,
          email: email,
          senha: senha,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone e título
            Icon(Icons.person_add, size: 64, color: cores.primary),
            const SizedBox(height: 8),
            const Text(
              'Crie sua conta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Campo: Nome
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Campo: Senha
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Mensagem de erro com AnimatedOpacity — animação implícita extra.
            // Aparece suavemente em 300ms em vez de "piscar" na tela.
            AnimatedOpacity(
              opacity: _erro.isEmpty ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                _erro.isEmpty ? ' ' : _erro, // espaço reserva a altura
                style: TextStyle(color: cores.error, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Widget customizado — primeiro uso
            BotaoPrimario(
              texto: 'Cadastrar',
              icone: Icons.person_add_alt_1,
              onPressed: _cadastrar,
            ),
          ],
        ),
      ),
    );
  }
}
