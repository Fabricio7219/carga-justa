import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens_erro.dart';
import '../utils/validadores.dart';
import '../widgets/area_central.dart';

class CadastroMotoristaScreen extends StatefulWidget {
  const CadastroMotoristaScreen({super.key});

  @override
  State<CadastroMotoristaScreen> createState() =>
      _CadastroMotoristaScreenState();
}

class _CadastroMotoristaScreenState extends State<CadastroMotoristaScreen> {
  /// Caminhões de 6 t para cima exigem no mínimo a categoria C.
  static const categoriasCnh = ['C', 'D', 'E'];

  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _telefone = TextEditingController();
  final _numeroCnh = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();

  String? _categoriaCnh;
  DateTime? _validadeCnh;
  bool _aceitouTermos = false;
  bool _senhaVisivel = false;
  bool _carregando = false;
  bool _tentouEnviar = false;

  @override
  void dispose() {
    for (final c in [
      _nome, _cpf, _telefone, _numeroCnh, _email, _senha, _confirmarSenha,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherValidade() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _validadeCnh ?? hoje.add(const Duration(days: 365)),
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 15),
      helpText: 'Validade da CNH',
    );
    if (data != null) setState(() => _validadeCnh = data);
  }

  String? get _erroCategoria =>
      _categoriaCnh == null ? 'Escolha a categoria da CNH' : null;

  String? get _erroValidade {
    if (_validadeCnh == null) return 'Informe a validade da CNH';
    if (_validadeCnh!.isBefore(DateTime.now())) {
      return 'CNH vencida. Renove antes de se cadastrar.';
    }
    return null;
  }

  String? get _erroTermos =>
      _aceitouTermos ? null : 'É preciso aceitar os termos para continuar';

  Future<void> _cadastrar() async {
    setState(() => _tentouEnviar = true);
    final camposOk = _form.currentState!.validate();
    if (!camposOk ||
        _erroCategoria != null ||
        _erroValidade != null ||
        _erroTermos != null) {
      // Avisa, porque o campo com erro pode estar fora da tela.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Confira os campos marcados em vermelho.'),
      ));
      return;
    }

    setState(() => _carregando = true);
    try {
      await authService.cadastrarMotorista(
        nome: _nome.text,
        cpf: _cpf.text,
        telefone: _telefone.text,
        email: _email.text,
        senha: _senha.text,
        cnh: Cnh(
          numero: somenteDigitos(_numeroCnh.text),
          categoria: _categoriaCnh!,
          validade: _validadeCnh!,
        ),
      );
      // O cadastro já faz o login. Volta para o início, onde o
      // AuthGate vai mostrar a tela de "aguardando aprovação".
      if (mounted) Navigator.of(context).popUntil((rota) => rota.isFirst);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemDeErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corErro = tema.colorScheme.error;

    Widget titulo(String texto) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(texto, style: tema.textTheme.titleMedium),
        );

    Widget erroAbaixo(String? erro) => (_tentouEnviar && erro != null)
        ? Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(erro,
                style: tema.textTheme.bodySmall?.copyWith(color: corErro)),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de motorista')),
      body: SafeArea(
        child: AreaCentral(
          child: Form(
            key: _form,
            // Depois da primeira tentativa, o erro some assim que o campo é corrigido.
            autovalidateMode: _tentouEnviar
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              children: [
                titulo('Dados pessoais'),
                TextFormField(
                  controller: _nome,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validarNome,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cpf,
                  decoration: const InputDecoration(
                      labelText: 'CPF', hintText: 'Só números'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: validarCpf,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefone,
                  decoration: const InputDecoration(
                      labelText: 'Celular com DDD', hintText: '11999999999'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: validarTelefone,
                ),

                titulo('CNH'),
                TextFormField(
                  controller: _numeroCnh,
                  decoration:
                      const InputDecoration(labelText: 'Número da CNH'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: validarNumeroCnh,
                ),
                const SizedBox(height: 16),
                Text('Categoria', style: tema.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final categoria in categoriasCnh)
                      ChoiceChip(
                        label: Text(categoria),
                        selected: _categoriaCnh == categoria,
                        onSelected: (_) =>
                            setState(() => _categoriaCnh = categoria),
                      ),
                  ],
                ),
                erroAbaixo(_erroCategoria),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _escolherValidade,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(_validadeCnh == null
                      ? 'Validade da CNH'
                      : 'Validade: ${formatarData(_validadeCnh!)}'),
                ),
                erroAbaixo(_erroValidade),

                titulo('Acesso ao app'),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validarEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    suffixIcon: IconButton(
                      tooltip:
                          _senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                      icon: Icon(_senhaVisivel
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                  ),
                  obscureText: !_senhaVisivel,
                  textInputAction: TextInputAction.next,
                  validator: validarSenha,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarSenha,
                  decoration:
                      const InputDecoration(labelText: 'Confirmar senha'),
                  obscureText: !_senhaVisivel,
                  textInputAction: TextInputAction.done,
                  validator: (valor) =>
                      valor == _senha.text ? null : 'As senhas não conferem',
                ),

                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _aceitouTermos,
                  onChanged: (valor) =>
                      setState(() => _aceitouTermos = valor ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Autorizo o uso do meu CPF, CNH, telefone e localização '
                    'para a distribuição de cargas, conforme a LGPD.',
                  ),
                ),
                erroAbaixo(_erroTermos),

                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar cadastro'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seu cadastro será analisado pelo programador antes '
                  'de liberar a solicitação de cargas.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
