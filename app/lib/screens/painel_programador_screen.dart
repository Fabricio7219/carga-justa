import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens_erro.dart';
import '../widgets/area_central.dart';

/// Painel do programador: por enquanto, aprovação de cadastros.
/// Cargas, fila e configurações entram aqui nas próximas etapas.
class PainelProgramadorScreen extends StatelessWidget {
  const PainelProgramadorScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do programador'),
        actions: [
          Center(child: Text(usuario.primeiroNome)),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: authService.sair,
          ),
        ],
      ),
      body: AreaCentral(
        larguraMaxima: 900,
        child: StreamBuilder<List<Usuario>>(
          stream: authService.cadastrosPendentes(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text(mensagemDeErro(snap.error!)));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final pendentes = snap.data!;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Cadastros aguardando aprovação (${pendentes.length})',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (pendentes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text('Nenhum cadastro pendente.',
                        textAlign: TextAlign.center),
                  ),
                for (final motorista in pendentes)
                  _CartaoCadastro(motorista: motorista),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartaoCadastro extends StatefulWidget {
  const _CartaoCadastro({required this.motorista});

  final Usuario motorista;

  @override
  State<_CartaoCadastro> createState() => _CartaoCadastroState();
}

class _CartaoCadastroState extends State<_CartaoCadastro> {
  bool _salvando = false;

  Future<void> _executar(Future<void> Function() acao, String sucesso) async {
    setState(() => _salvando = true);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await acao();
      mensageiro.showSnackBar(SnackBar(content: Text(sucesso)));
    } catch (erro) {
      mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(erro))));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _recusar() async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoMotivo(),
    );
    if (motivo == null || motivo.trim().isEmpty) return;
    await _executar(
      () => authService.recusar(widget.motorista.uid, motivo),
      'Cadastro de ${widget.motorista.primeiroNome} recusado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.motorista;
    final tema = Theme.of(context);
    final cnh = m.cnh;

    Widget linha(String rotulo, String valor, {bool alerta = false}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: '$rotulo: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
              text: valor,
              style: alerta ? TextStyle(color: tema.colorScheme.error) : null,
            ),
          ])),
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.nome, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            linha('CPF', formatarCpf(m.cpf)),
            linha('Celular', formatarTelefone(m.telefone)),
            linha('E-mail', m.email),
            if (cnh != null)
              linha(
                'CNH',
                '${cnh.numero} · categoria ${cnh.categoria} · '
                    'validade ${formatarData(cnh.validade)}'
                    '${cnh.vencida ? ' (VENCIDA)' : ''}',
                alerta: cnh.vencida,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _salvando ? null : _recusar,
                  child: const Text('Recusar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 44)),
                  onPressed: _salvando
                      ? null
                      : () => _executar(
                            () => authService.aprovar(m.uid),
                            'Cadastro de ${m.primeiroNome} aprovado.',
                          ),
                  child: const Text('Aprovar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoMotivo extends StatefulWidget {
  const _DialogoMotivo();

  @override
  State<_DialogoMotivo> createState() => _DialogoMotivoState();
}

class _DialogoMotivoState extends State<_DialogoMotivo> {
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recusar cadastro'),
      content: TextField(
        controller: _motivo,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Motivo',
          hintText: 'Ex.: CNH ilegível, categoria incompatível',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: () => Navigator.of(context).pop(_motivo.text),
          child: const Text('Recusar'),
        ),
      ],
    );
  }
}
