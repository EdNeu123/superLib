import 'package:flutter/material.dart';

/// Widget customizado reutilizável — Requisito 5 da Aula 9.
///
/// Recebe parâmetros (texto, ícone opcional, callback) e é usado em
/// pelo menos 3 lugares diferentes: Cadastro, Login e Detalhe do Livro.
///
/// Usa `FilledButton` (componente do Material Design 3).
class BotaoPrimario extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback onPressed;

  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    // Se houver ícone, usa FilledButton.icon; caso contrário, FilledButton simples.
    // Ambos são componentes M3.
    if (icone != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icone),
        label: Text(texto),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(texto),
    );
  }
}
