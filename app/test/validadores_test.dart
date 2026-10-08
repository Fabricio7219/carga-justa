import 'package:app/utils/formatadores.dart';
import 'package:app/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

// Para rodar: abra o terminal na pasta app e digite  flutter test
void main() {
  group('CPF', () {
    test('aceita CPF válido, com ou sem pontuação', () {
      expect(cpfValido('52998224725'), isTrue);
      expect(cpfValido('529.982.247-25'), isTrue);
    });

    test('recusa dígito verificador errado', () {
      expect(cpfValido('52998224724'), isFalse);
    });

    test('recusa CPF com todos os números iguais', () {
      expect(cpfValido('11111111111'), isFalse);
      expect(cpfValido('00000000000'), isFalse);
    });

    test('recusa tamanho errado', () {
      expect(cpfValido('5299822472'), isFalse);
      expect(cpfValido(''), isFalse);
    });

    test('mensagem do formulário', () {
      expect(validarCpf(''), 'CPF é obrigatório');
      expect(validarCpf('12345678900'), 'CPF inválido');
      expect(validarCpf('52998224725'), isNull);
    });
  });

  group('Telefone', () {
    test('aceita fixo e celular com DDD', () {
      expect(validarTelefone('1133334444'), isNull);
      expect(validarTelefone('11999998888'), isNull);
    });

    test('recusa sem DDD', () {
      expect(validarTelefone('999998888'), isNotNull);
    });
  });

  group('Outros campos', () {
    test('nome precisa de sobrenome', () {
      expect(validarNome('Nelson'), 'Informe nome e sobrenome');
      expect(validarNome('Nelson Santos'), isNull);
    });

    test('e-mail', () {
      expect(validarEmail('motorista@gmail.com'), isNull);
      expect(validarEmail('motorista@'), 'E-mail inválido');
    });

    test('senha com no mínimo 6 caracteres', () {
      expect(validarSenha('12345'), isNotNull);
      expect(validarSenha('123456'), isNull);
    });

    test('CNH com 11 números', () {
      expect(validarNumeroCnh('12345678901'), isNull);
      expect(validarNumeroCnh('1234'), 'A CNH tem 11 números');
    });
  });

  group('Formatação', () {
    test('CPF, telefone e data', () {
      expect(formatarCpf('52998224725'), '529.982.247-25');
      expect(formatarTelefone('11999998888'), '(11) 99999-8888');
      expect(formatarData(DateTime(2027, 3, 5)), '05/03/2027');
    });
  });
}
