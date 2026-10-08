import 'package:flutter/material.dart';

import '../tema.dart';

/// Ícone e nome do sistema, usados no login e na barra superior.
class Marca extends StatelessWidget {
  const Marca({super.key, this.claro = false, this.tamanho = 22});

  /// Texto branco, para fundo escuro.
  final bool claro;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final cor = claro ? Colors.white : Cores.barra;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Cores.primaria,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Icon(Icons.local_shipping, color: Colors.white, size: tamanho),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'Carga',
                style: TextStyle(fontWeight: FontWeight.w300, color: cor)),
            TextSpan(
                text: 'Justa',
                style: TextStyle(fontWeight: FontWeight.w800, color: cor)),
          ]),
          style: TextStyle(fontSize: tamanho),
        ),
      ],
    );
  }
}
