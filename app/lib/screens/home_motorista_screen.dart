import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../utils/formatadores.dart';
import '../widgets/area_central.dart';

/// Tela inicial do motorista aprovado.
/// A fila e as ofertas de carga entram aqui nas próximas etapas.
class HomeMotoristaScreen extends StatelessWidget {
  const HomeMotoristaScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cnh = usuario.cnh;
    final cnhVencida = cnh?.vencida ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${usuario.primeiroNome}'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: authService.sair,
          ),
        ],
      ),
      body: SafeArea(
        child: AreaCentral(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (cnh != null)
                Card(
                  color: cnhVencida ? tema.colorScheme.errorContainer : null,
                  child: ListTile(
                    leading: Icon(
                        cnhVencida ? Icons.warning_amber : Icons.badge_outlined),
                    title: Text('CNH categoria ${cnh.categoria}'),
                    subtitle: Text(cnhVencida
                        ? 'Vencida em ${formatarData(cnh.validade)}. '
                            'Renove para voltar a solicitar cargas.'
                        : 'Válida até ${formatarData(cnh.validade)}'),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // A fila de cargas será ligada na próxima etapa.
                onPressed: null,
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(usuario.podeOperar
                    ? 'Solicitar carga (em breve)'
                    : 'Solicitação bloqueada'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
