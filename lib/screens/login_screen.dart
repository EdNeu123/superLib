import 'package:flutter/material.dart';
import '../widgets/botao_primario.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String nome;
  final String email;
  final String senha;

  const LoginScreen({
    super.key,
    required this.nome,
    required this.email,
    required this.senha,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  String _erro = '';

  void _entrar() {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }

    if (email != widget.email || senha != widget.senha) {
      setState(() => _erro = 'E-mail ou senha incorretos.');
      return;
    }

    // Login OK — navega para Home e limpa a pilha
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(nome: widget.nome),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.menu_book, size: 64, color: cores.primary),
            const SizedBox(height: 8),
            const Text(
              'Controle de Leitura',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Faça login para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

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

            // Fade suave para mensagem de erro
            AnimatedOpacity(
              opacity: _erro.isEmpty ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                _erro.isEmpty ? ' ' : _erro,
                style: TextStyle(color: cores.error, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Widget customizado — segundo uso
            BotaoPrimario(
              texto: 'Entrar',
              icone: Icons.login,
              onPressed: _entrar,
            ),
          ],
        ),
      ),
    );
  }
}
