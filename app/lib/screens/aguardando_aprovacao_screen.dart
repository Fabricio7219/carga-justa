import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../widgets/area_central.dart';

/// Mostrada enquanto o cadastro não está aprovado.
/// Atualiza sozinha quando o programador aprova ou recusa.
class AguardandoAprovacaoScreen extends StatelessWidget {
  const AguardandoAprovacaoScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final (IconData icone, Color cor, String titulo, String texto) =
        switch (usuario.status) {
      StatusCadastro.recusado => (
          Icons.cancel_outlined,
          tema.colorScheme.error,
          'Cadastro recusado',
          usuario.motivoRecusa?.isNotEmpty == true
              ? 'Motivo: ${usuario.motivoRecusa}'
              : 'Fale com o programador da Jofege para saber o motivo.',
        ),
      StatusCadastro.bloqueado => (
          Icons.block,
          tema.colorScheme.error,
          'Acesso bloqueado',
          'Fale com o programador da Jofege.',
        ),
      _ => (
          Icons.hourglass_top,
          tema.colorScheme.primary,
          'Cadastro em análise',
          'Olá, ${usuario.primeiroNome}! Seu cadastro foi enviado e está '
              'aguardando a aprovação do programador. Esta tela atualiza '
              'sozinha assim que for aprovado.',
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: AreaCentral(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(icone, size: 72, color: cor),
                const SizedBox(height: 16),
                Text(titulo,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(texto,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyLarge),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: authService.sair,
                  child: const Text('Sair'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
