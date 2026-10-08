import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../tema.dart';
import '../utils/formatadores.dart';
import '../widgets/area_central.dart';
import '../widgets/marca.dart';
import '../widgets/quadro.dart';

/// Tela inicial do motorista aprovado.
/// A fila e as ofertas de carga entram aqui nas próximas etapas.
class HomeMotoristaScreen extends StatelessWidget {
  const HomeMotoristaScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final cnh = usuario.cnh;
    final cnhVencida = cnh?.vencida ?? false;

    Widget linha(String rotulo, String valor, {Color? cor}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(rotulo,
                    style: const TextStyle(
                        fontSize: 13, color: Cores.textoSuave)),
              ),
              Text(valor,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cor ?? Cores.texto)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Marca(claro: true, tamanho: 18),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: authService.sair,
          ),
        ],
      ),
      body: SafeArea(
        child: AreaCentral(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Olá, ${usuario.primeiroNome}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Cores.texto)),
              const SizedBox(height: 16),
              Quadro(
                titulo: 'Situação',
                child: Column(
                  children: [
                    linha('Cadastro', 'APROVADO', cor: Cores.sucesso),
                    const Divider(height: 1),
                    if (cnh != null) ...[
                      linha('CNH', 'Categoria ${cnh.categoria}'),
                      const Divider(height: 1),
                      linha(
                        'Validade da CNH',
                        cnhVencida
                            ? '${formatarData(cnh.validade)} VENCIDA'
                            : formatarData(cnh.validade),
                        cor: cnhVencida ? Cores.erro : null,
                      ),
                    ],
                  ],
                ),
              ),
              if (cnhVencida) ...[
                const SizedBox(height: 12),
                const Text(
                  'CNH vencida: renove para voltar a solicitar cargas.',
                  style: TextStyle(color: Cores.erro),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                // A fila de cargas será ligada na próxima etapa.
                onPressed: null,
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(usuario.podeOperar
                    ? 'SOLICITAR CARGA (EM BREVE)'
                    : 'SOLICITAÇÃO BLOQUEADA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
