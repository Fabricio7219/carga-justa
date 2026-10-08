import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/mensagens_erro.dart';
import '../utils/validadores.dart';
import '../widgets/area_central.dart';
import 'cadastro_motorista_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _senhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await authService.entrar(_email.text, _senha.text);
      // Não precisa navegar: o AuthGate troca de tela sozinho.
    } catch (erro) {
      if (mounted) _avisar(mensagemDeErro(erro));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final erro = validarEmail(_email.text);
    if (erro != null) {
      _avisar('Digite seu e-mail no campo acima para recuperar a senha.');
      return;
    }
    try {
      await authService.recuperarSenha(_email.text);
      if (mounted) {
        _avisar('Enviamos um link para redefinir a senha no seu e-mail.');
      }
    } catch (erro) {
      if (mounted) _avisar(mensagemDeErro(erro));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: AreaCentral(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: tema.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Carga Justa',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Distribuição de cargas',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: validarEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        tooltip: _senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                        icon: Icon(_senhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    obscureText: !_senhaVisivel,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _entrar(),
                    validator: validarSenha,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _carregando ? null : _recuperarSenha,
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Motorista sem cadastro?',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _carregando
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const CadastroMotoristaScreen())),
                    child: const Text('Criar cadastro de motorista'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
