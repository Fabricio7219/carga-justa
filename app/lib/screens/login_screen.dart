import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../tema.dart';
import '../utils/mensagens_erro.dart';
import '../utils/validadores.dart';
import '../widgets/area_central.dart';
import '../widgets/marca.dart';
import '../widgets/quadro.dart';
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
    return Scaffold(
      body: SafeArea(
        child: AreaCentral(
          larguraMaxima: 420,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: Marca(tamanho: 26)),
                const SizedBox(height: 6),
                const Text(
                  'Distribuição de cargas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Cores.textoSuave),
                ),
                const SizedBox(height: 28),
                Quadro(
                  titulo: 'Acesso ao sistema',
                  escuro: true,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _email,
                            decoration:
                                const InputDecoration(labelText: 'E-mail'),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            validator: validarEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senha,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              suffixIcon: IconButton(
                                tooltip: _senhaVisivel
                                    ? 'Esconder senha'
                                    : 'Mostrar senha',
                                icon: Icon(_senhaVisivel
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _senhaVisivel = !_senhaVisivel),
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
                          const SizedBox(height: 4),
                          FilledButton(
                            onPressed: _carregando ? null : _entrar,
                            child: _carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('ENTRAR'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Motorista sem cadastro?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Cores.textoSuave),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _carregando
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CadastroMotoristaScreen())),
                  child: const Text('CRIAR CADASTRO DE MOTORISTA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
