import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'aguardando_aprovacao_screen.dart';
import 'home_motorista_screen.dart';
import 'login_screen.dart';
import 'painel_programador_screen.dart';

/// Porta de entrada do app: decide a tela pelo login e pelo perfil.
///
/// Sem login           -> tela de login
/// Cadastro pendente   -> aguardando aprovação
/// Motorista aprovado  -> home do motorista
/// Programador/admin   -> painel do programador
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Os streams ficam guardados para não reconectar a cada redesenho da tela.
  late final Stream<User?> _login = authService.usuarioLogado;
  String? _uidAtual;
  Stream<Usuario?>? _perfil;

  Stream<Usuario?> _perfilDe(String uid) {
    if (uid != _uidAtual) {
      _uidAtual = uid;
      _perfil = authService.perfil(uid);
    }
    return _perfil!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _login,
      builder: (context, login) {
        if (login.connectionState == ConnectionState.waiting) {
          return const TelaCarregando();
        }
        final user = login.data;
        if (user == null) return const LoginScreen();

        return StreamBuilder<Usuario?>(
          stream: _perfilDe(user.uid),
          builder: (context, perfil) {
            if (perfil.hasError) {
              return const TelaCarregando(
                mensagem: 'Não foi possível carregar seu cadastro.',
                mostrarSair: true,
              );
            }
            final usuario = perfil.data;
            // Logo após o cadastro, o login chega antes dos dados.
            if (usuario == null) {
              return const TelaCarregando(mostrarSair: true);
            }

            if (usuario.status != StatusCadastro.aprovado) {
              return AguardandoAprovacaoScreen(usuario: usuario);
            }
            if (usuario.ehGestor) {
              return PainelProgramadorScreen(usuario: usuario);
            }
            return HomeMotoristaScreen(usuario: usuario);
          },
        );
      },
    );
  }
}

class TelaCarregando extends StatelessWidget {
  const TelaCarregando({super.key, this.mensagem, this.mostrarSair = false});

  final String? mensagem;
  final bool mostrarSair;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mensagem == null)
              const CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(mensagem!, textAlign: TextAlign.center),
              ),
            if (mostrarSair) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: authService.sair,
                child: const Text('Sair'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
