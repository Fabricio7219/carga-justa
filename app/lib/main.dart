import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'tema.dart';

Future<void> main() async {
  // Garante que o Flutter está pronto antes de iniciar o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CargaJustaApp());
}

class CargaJustaApp extends StatelessWidget {
  const CargaJustaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carga Justa',
      debugShowCheckedModeBanner: false,
      theme: temaCargaJusta(),
      // Deixa calendário, botões padrão e textos do sistema em português.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // O AuthGate decide qual tela mostrar conforme o login e o perfil.
      home: const AuthGate(),
    );
  }
}
