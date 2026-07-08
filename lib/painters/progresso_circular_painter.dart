import 'dart:math';
import 'package:flutter/material.dart';

/// CustomPainter — Requisito BÔNUS da Aula 9.
///
/// Desenha um círculo de fundo e um arco que representa o progresso
/// de leitura do livro (0.0 a 1.0). Usa `drawCircle`, `drawArc` e
/// implementa corretamente o `shouldRepaint`.
class ProgressoCircularPainter extends CustomPainter {
  final double progresso; // 0.0 a 1.0 (já aplicada a curva, se houver)
  final Color corFundo;
  final Color corProgresso;
  final double espessura;

  ProgressoCircularPainter({
    required this.progresso,
    required this.corFundo,
    required this.corProgresso,
    this.espessura = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = (min(size.width, size.height) - espessura) / 2;

    // Círculo de fundo (trilho)
    final pincelFundo = Paint()
      ..color = corFundo
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(centro, raio, pincelFundo);

    // Arco de progresso — começa no topo (-90°) e vai no sentido horário
    if (progresso > 0) {
      final pincelProgresso = Paint()
        ..color = corProgresso
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..strokeCap = StrokeCap.round;

      final inicio = -pi / 2; // topo do círculo
      final varredura = 2 * pi * progresso;

      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raio),
        inicio,
        varredura,
        false,
        pincelProgresso,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProgressoCircularPainter oldDelegate) {
    // Só redesenha quando algo realmente muda — evita rebuilds desnecessários.
    return oldDelegate.progresso != progresso ||
        oldDelegate.corFundo != corFundo ||
        oldDelegate.corProgresso != corProgresso ||
        oldDelegate.espessura != espessura;
  }
}
