import 'package:flutter/material.dart';

/// Cores e estilos usados em todo o app.
ThemeData temaCargaJusta() {
  final cores = ColorScheme.fromSeed(seedColor: const Color(0xFF1F3A5F));

  return ThemeData(
    colorScheme: cores,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Botões grandes: o motorista usa o app com pressa e às vezes no sol.
        minimumSize: const Size.fromHeight(52),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );
}
