// Smoke test básico: verifica que o app inicia na tela de Cadastro.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:controle_leitura/main.dart';

void main() {
  testWidgets('App inicia na tela de Cadastro', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
  });
}
