import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Traduz os erros do Firebase para mensagens que o motorista entende.
String mensagemDeErro(Object erro) {
  if (erro is FirebaseAuthException) {
    switch (erro.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado. Tente entrar ou recuperar a senha.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
      case 'network-request-failed':
        return 'Sem internet. Verifique a conexão e tente de novo.';
      case 'user-disabled':
        return 'Este acesso foi desativado. Fale com o programador.';
    }
    return 'Erro no login (${erro.code}).';
  }
  if (erro is FirebaseException) {
    if (erro.code == 'permission-denied') {
      return 'Sem permissão para esta ação.';
    }
    if (erro.code == 'unavailable') {
      return 'Sem conexão com o servidor. Tente de novo.';
    }
    return 'Erro no servidor (${erro.code}).';
  }
  return 'Algo deu errado. Tente de novo.';
}
