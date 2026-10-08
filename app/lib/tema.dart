import 'package:flutter/material.dart';

/// Paleta no estilo dos sistemas corporativos (padrão TOTVS/Protheus):
/// barra escura, fundo cinza claro, cantos quase retos e tabelas compactas.
abstract final class Cores {
  static const primaria = Color(0xFF0C9ABE); // azul-petróleo dos botões
  static const primariaEscura = Color(0xFF087A97);
  static const barra = Color(0xFF1F3445); // barra superior
  static const menu = Color(0xFF26404F); // menu lateral
  static const menuSelecionado = Color(0xFF31556A);
  static const fundo = Color(0xFFF2F4F5);
  static const borda = Color(0xFFD5DADE);
  static const cabecalhoTabela = Color(0xFFE3E7EA);
  static const texto = Color(0xFF1C2B36);
  static const textoSuave = Color(0xFF5F6F7A);
  static const erro = Color(0xFFC0392B);
  static const sucesso = Color(0xFF2E8B57);
}

const _raio = BorderRadius.all(Radius.circular(4));

ThemeData temaCargaJusta() {
  final cores = ColorScheme.fromSeed(seedColor: Cores.primaria).copyWith(
    primary: Cores.primaria,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: Cores.texto,
    error: Cores.erro,
  );

  const formatoBotao = RoundedRectangleBorder(borderRadius: _raio);

  return ThemeData(
    colorScheme: cores,
    useMaterial3: true,
    scaffoldBackgroundColor: Cores.fundo,
    dividerColor: Cores.borda,
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.barra,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: _raio,
        side: BorderSide(color: Cores.borda),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: _raio, borderSide: BorderSide(color: Cores.borda)),
      enabledBorder: OutlineInputBorder(
          borderRadius: _raio, borderSide: BorderSide(color: Cores.borda)),
      focusedBorder: OutlineInputBorder(
          borderRadius: _raio,
          borderSide: BorderSide(color: Cores.primaria, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: formatoBotao,
        minimumSize: const Size.fromHeight(46),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: formatoBotao,
        minimumSize: const Size.fromHeight(46),
        foregroundColor: Cores.primaria,
        side: const BorderSide(color: Cores.primaria),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: formatoBotao,
        foregroundColor: Cores.primaria,
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: _raio),
      side: BorderSide(color: Cores.borda),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: _raio),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: _raio),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(Cores.cabecalhoTabela),
      headingRowHeight: 40,
      dataRowMinHeight: 44,
      dataRowMaxHeight: 52,
      headingTextStyle: TextStyle(
        color: Cores.texto,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      dataTextStyle: TextStyle(color: Cores.texto, fontSize: 13),
      dividerThickness: 1,
    ),
  );
}
