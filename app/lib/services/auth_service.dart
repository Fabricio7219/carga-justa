import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';
import '../utils/validadores.dart';

/// Um único serviço de autenticação para o app inteiro.
final authService = AuthService();

/// Tudo que envolve login, cadastro e aprovação de usuários.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');

  /// Avisa sempre que alguém entra ou sai.
  Stream<User?> get usuarioLogado => _auth.authStateChanges();

  /// Acompanha o cadastro do usuário em tempo real (status, perfil, CNH).
  Stream<Usuario?> perfil(String uid) => _usuarios
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? Usuario.fromDoc(doc) : null);

  Future<void> entrar(String email, String senha) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);

  Future<void> sair() => _auth.signOut();

  Future<void> recuperarSenha(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Cria o login e o cadastro do motorista, que fica pendente de aprovação.
  Future<void> cadastrarMotorista({
    required String nome,
    required String cpf,
    required String telefone,
    required String email,
    required String senha,
    required Cnh cnh,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final usuario = credencial.user!;

    try {
      await _usuarios.doc(usuario.uid).set({
        'nome': _nomeComIniciais(nome),
        'cpf': somenteDigitos(cpf),
        'telefone': somenteDigitos(telefone),
        'email': email.trim().toLowerCase(),
        'perfil': Perfil.motorista.name,
        'status': StatusCadastro.pendente.name,
        'cnh': cnh.toMap(),
        'aceitouTermosEm': FieldValue.serverTimestamp(),
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Se o cadastro não foi salvo, apaga o login para não deixar
      // uma conta "fantasma" sem dados.
      await usuario.delete();
      rethrow;
    }
  }

  /// "fabricio  andrade de araujo" -> "Fabricio Andrade de Araujo"
  static String _nomeComIniciais(String nome) {
    const minusculas = {'da', 'das', 'de', 'do', 'dos', 'e'};
    return nome
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((parte) => minusculas.contains(parte)
            ? parte
            : parte[0].toUpperCase() + parte.substring(1))
        .join(' ');
  }

  // ---------- Ações do programador ----------

  Stream<List<Usuario>> cadastrosPendentes() => _usuarios
      .where('status', isEqualTo: StatusCadastro.pendente.name)
      .snapshots()
      .map((resultado) =>
          resultado.docs.map((doc) => Usuario.fromDoc(doc)).toList());

  Future<void> aprovar(String uid) => _usuarios.doc(uid).update({
        'status': StatusCadastro.aprovado.name,
        'motivoRecusa': FieldValue.delete(),
        'avaliadoPor': _auth.currentUser?.uid,
        'avaliadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> recusar(String uid, String motivo) =>
      _usuarios.doc(uid).update({
        'status': StatusCadastro.recusado.name,
        'motivoRecusa': motivo.trim(),
        'avaliadoPor': _auth.currentUser?.uid,
        'avaliadoEm': FieldValue.serverTimestamp(),
      });
}
