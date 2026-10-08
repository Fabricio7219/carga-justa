import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de acesso ao sistema.
enum Perfil { administrador, programador, transportadora, motorista }

/// Situação do cadastro. Todo cadastro novo começa como pendente.
enum StatusCadastro { pendente, aprovado, recusado, bloqueado }

/// Converte o texto salvo no banco de volta para o enum.
/// Se o texto for desconhecido, usa o valor padrão em vez de travar o app.
T _enumPorNome<T extends Enum>(List<T> valores, Object? nome, T padrao) {
  for (final valor in valores) {
    if (valor.name == nome) return valor;
  }
  return padrao;
}

class Cnh {
  const Cnh({
    required this.numero,
    required this.categoria,
    required this.validade,
  });

  final String numero;
  final String categoria;
  final DateTime validade;

  bool get vencida => validade.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'numero': numero,
        'categoria': categoria,
        'validade': Timestamp.fromDate(validade),
      };

  factory Cnh.fromMap(Map<String, dynamic> mapa) => Cnh(
        numero: mapa['numero'] as String? ?? '',
        categoria: mapa['categoria'] as String? ?? '',
        validade: (mapa['validade'] as Timestamp?)?.toDate() ?? DateTime(2000),
      );
}

/// Um usuário do sistema, salvo em `usuarios/{uid}` no Firestore.
class Usuario {
  const Usuario({
    required this.uid,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.perfil,
    required this.status,
    this.cnh,
    this.motivoRecusa,
  });

  final String uid;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final Perfil perfil;
  final StatusCadastro status;
  final Cnh? cnh;
  final String? motivoRecusa;

  bool get ehGestor =>
      perfil == Perfil.programador || perfil == Perfil.administrador;

  /// Só opera quem está aprovado e com a CNH em dia.
  bool get podeOperar =>
      status == StatusCadastro.aprovado && !(cnh?.vencida ?? false);

  String get primeiroNome => nome.trim().split(' ').first;

  factory Usuario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data() ?? {};
    final cnh = dados['cnh'];

    return Usuario(
      uid: doc.id,
      nome: dados['nome'] as String? ?? '',
      cpf: dados['cpf'] as String? ?? '',
      telefone: dados['telefone'] as String? ?? '',
      email: dados['email'] as String? ?? '',
      perfil: _enumPorNome(Perfil.values, dados['perfil'], Perfil.motorista),
      status: _enumPorNome(
          StatusCadastro.values, dados['status'], StatusCadastro.pendente),
      cnh: cnh is Map ? Cnh.fromMap(Map<String, dynamic>.from(cnh)) : null,
      motivoRecusa: dados['motivoRecusa'] as String?,
    );
  }
}
