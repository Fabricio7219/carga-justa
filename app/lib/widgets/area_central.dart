import 'package:flutter/material.dart';

/// Centraliza o conteúdo e limita a largura.
///
/// No celular ocupa a tela toda; no painel web não deixa
/// o formulário esticado de ponta a ponta do monitor.
class AreaCentral extends StatelessWidget {
  const AreaCentral({super.key, required this.child, this.larguraMaxima = 480});

  final Widget child;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: child,
      ),
    );
  }
}
