import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../tema.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens_erro.dart';
import '../widgets/marca.dart';
import '../widgets/quadro.dart';

/// Painel do programador, no estilo das telas do TOTVS:
/// barra escura, menu lateral e conteúdo em tabelas.
class PainelProgramadorScreen extends StatelessWidget {
  const PainelProgramadorScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Marca(claro: true, tamanho: 18),
        actions: [
          const Icon(Icons.person_outline, size: 18),
          const SizedBox(width: 6),
          Text(usuario.primeiroNome, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: authService.sair,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, tela) {
          // Em tela pequena (celular) o menu lateral some.
          final mostrarMenu = tela.maxWidth >= 800;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mostrarMenu) const _MenuLateral(),
              const Expanded(child: _CadastrosPendentes()),
            ],
          );
        },
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icone, String texto,
        {bool selecionado = false, bool emBreve = false}) {
      return Container(
        decoration: BoxDecoration(
          color: selecionado ? Cores.menuSelecionado : null,
          border: Border(
            left: BorderSide(
              color: selecionado ? Cores.primaria : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icone,
                size: 18,
                color: emBreve ? Colors.white38 : Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 13,
                  color: emBreve ? Colors.white38 : Colors.white,
                  fontWeight: selecionado ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (emBreve)
              const Text('em breve',
                  style: TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
      );
    }

    Widget grupo(String texto) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: Text(texto.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600)),
        );

    return Container(
      width: 230,
      color: Cores.menu,
      child: ListView(
        children: [
          grupo('Cadastros'),
          item(Icons.how_to_reg_outlined, 'Aprovação de motoristas',
              selecionado: true),
          item(Icons.badge_outlined, 'Motoristas', emBreve: true),
          item(Icons.local_shipping_outlined, 'Veículos', emBreve: true),
          grupo('Operação'),
          item(Icons.inventory_2_outlined, 'Cargas do dia', emBreve: true),
          item(Icons.format_list_numbered, 'Fila', emBreve: true),
          item(Icons.receipt_long_outlined, 'Ordens de carregamento',
              emBreve: true),
          grupo('Sistema'),
          item(Icons.tune, 'Parâmetros', emBreve: true),
          item(Icons.history, 'Histórico', emBreve: true),
        ],
      ),
    );
  }
}

class _CadastrosPendentes extends StatefulWidget {
  const _CadastrosPendentes();

  @override
  State<_CadastrosPendentes> createState() => _CadastrosPendentesState();
}

class _CadastrosPendentesState extends State<_CadastrosPendentes> {
  // Guardado para não reconectar ao banco a cada redesenho.
  final _pendentes = authService.cadastrosPendentes();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Cadastros  ›  Aprovação de motoristas',
            style: TextStyle(fontSize: 12, color: Cores.textoSuave)),
        const SizedBox(height: 6),
        const Text('Aprovação de motoristas',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Cores.texto)),
        const SizedBox(height: 16),
        StreamBuilder<List<Usuario>>(
          stream: _pendentes,
          builder: (context, snap) {
            final pendentes = snap.data ?? const <Usuario>[];
            return Quadro(
              titulo: 'Aguardando aprovação',
              acoes: [
                Text('${pendentes.length} registro(s)',
                    style: const TextStyle(
                        fontSize: 12, color: Cores.textoSuave)),
              ],
              child: _conteudo(snap, pendentes),
            );
          },
        ),
      ],
    );
  }

  Widget _conteudo(AsyncSnapshot<List<Usuario>> snap, List<Usuario> lista) {
    if (snap.hasError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(mensagemDeErro(snap.error!)),
      );
    }
    if (!snap.hasData) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (lista.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text('Nenhum cadastro pendente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Cores.textoSuave)),
      );
    }

    // Rolagem lateral para a tabela caber no celular.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: const WidgetStatePropertyAll(Colors.white),
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('CPF')),
          DataColumn(label: Text('Celular')),
          DataColumn(label: Text('CNH')),
          DataColumn(label: Text('Cat.')),
          DataColumn(label: Text('Validade')),
          DataColumn(label: Text('Ações')),
        ],
        rows: [
          for (final m in lista)
            DataRow(cells: [
              DataCell(Text(m.nome)),
              DataCell(Text(formatarCpf(m.cpf))),
              DataCell(Text(formatarTelefone(m.telefone))),
              DataCell(Text(m.cnh?.numero ?? '-')),
              DataCell(Text(m.cnh?.categoria ?? '-')),
              DataCell(_Validade(cnh: m.cnh)),
              DataCell(_AcoesCadastro(motorista: m)),
            ]),
        ],
      ),
    );
  }
}

class _Validade extends StatelessWidget {
  const _Validade({required this.cnh});

  final Cnh? cnh;

  @override
  Widget build(BuildContext context) {
    final cnh = this.cnh;
    if (cnh == null) return const Text('-');
    if (!cnh.vencida) return Text(formatarData(cnh.validade));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Cores.erro,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text('${formatarData(cnh.validade)} VENCIDA',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _AcoesCadastro extends StatefulWidget {
  const _AcoesCadastro({required this.motorista});

  final Usuario motorista;

  @override
  State<_AcoesCadastro> createState() => _AcoesCadastroState();
}

class _AcoesCadastroState extends State<_AcoesCadastro> {
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
    const tamanho = Size(0, 32);
    final m = widget.motorista;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: tamanho,
            backgroundColor: Cores.sucesso,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          onPressed: _salvando
              ? null
              : () => _executar(
                    () => authService.aprovar(m.uid),
                    'Cadastro de ${m.primeiroNome} aprovado.',
                  ),
          child: const Text('Aprovar'),
        ),
        const SizedBox(width: 6),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: tamanho,
            foregroundColor: Cores.erro,
            side: const BorderSide(color: Cores.erro),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          onPressed: _salvando ? null : _recusar,
          child: const Text('Recusar'),
        ),
      ],
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
    const tamanho = Size(100, 40);
    return AlertDialog(
      title: const Text('Recusar cadastro'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _motivo,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            hintText: 'Ex.: CNH ilegível, categoria incompatível',
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: tamanho),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: tamanho, backgroundColor: Cores.erro),
          onPressed: () => Navigator.of(context).pop(_motivo.text),
          child: const Text('Recusar'),
        ),
      ],
    );
  }
}
