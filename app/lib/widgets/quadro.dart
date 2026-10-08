import 'package:flutter/material.dart';

import '../tema.dart';

/// Caixa branca com faixa de título cinza, no estilo das telas do TOTVS.
class Quadro extends StatelessWidget {
  const Quadro({
    super.key,
    required this.titulo,
    required this.child,
    this.acoes = const [],
    this.escuro = false,
  });

  final String titulo;
  final Widget child;
  final List<Widget> acoes;

  /// Faixa escura (usada no login) em vez da cinza.
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: escuro ? Cores.barra : Cores.cabecalhoTabela,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: escuro ? Colors.white : Cores.texto,
                    ),
                  ),
                ),
                ...acoes,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
