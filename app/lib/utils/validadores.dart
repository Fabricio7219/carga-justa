/// Funções de validação dos formulários.
///
/// Cada função devolve `null` quando o valor está certo, ou o texto
/// do erro quando está errado. É o formato que o TextFormField espera.
library;

String somenteDigitos(String valor) => valor.replaceAll(RegExp(r'\D'), '');

String? obrigatorio(String? valor, {String campo = 'Campo'}) {
  if (valor == null || valor.trim().isEmpty) return '$campo é obrigatório';
  return null;
}

String? validarNome(String? valor) {
  final erro = obrigatorio(valor, campo: 'Nome');
  if (erro != null) return erro;
  if (valor!.trim().split(RegExp(r'\s+')).length < 2) {
    return 'Informe nome e sobrenome';
  }
  return null;
}

String? validarEmail(String? valor) {
  final erro = obrigatorio(valor, campo: 'E-mail');
  if (erro != null) return erro;
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor!.trim());
  return ok ? null : 'E-mail inválido';
}

String? validarSenha(String? valor) {
  final erro = obrigatorio(valor, campo: 'Senha');
  if (erro != null) return erro;
  return valor!.length < 6 ? 'A senha precisa ter pelo menos 6 caracteres' : null;
}

String? validarTelefone(String? valor) {
  final erro = obrigatorio(valor, campo: 'Telefone');
  if (erro != null) return erro;
  final digitos = somenteDigitos(valor!);
  return (digitos.length == 10 || digitos.length == 11)
      ? null
      : 'Telefone com DDD, ex.: 11 99999-9999';
}

String? validarNumeroCnh(String? valor) {
  final erro = obrigatorio(valor, campo: 'Número da CNH');
  if (erro != null) return erro;
  return somenteDigitos(valor!).length == 11
      ? null
      : 'A CNH tem 11 números';
}

/// Confere os dois dígitos verificadores do CPF.
bool cpfValido(String valor) {
  final digitos = somenteDigitos(valor);
  if (digitos.length != 11) return false;

  // CPFs com todos os números iguais passam na conta, mas não existem.
  if (RegExp(r'^(\d)\1{10}$').hasMatch(digitos)) return false;

  final n = digitos.split('').map(int.parse).toList();

  int calcularDigito(int quantidade) {
    var soma = 0;
    for (var i = 0; i < quantidade; i++) {
      soma += n[i] * (quantidade + 1 - i);
    }
    final resto = (soma * 10) % 11;
    return resto == 10 ? 0 : resto;
  }

  return calcularDigito(9) == n[9] && calcularDigito(10) == n[10];
}

String? validarCpf(String? valor) {
  final erro = obrigatorio(valor, campo: 'CPF');
  if (erro != null) return erro;
  return cpfValido(valor!) ? null : 'CPF inválido';
}
