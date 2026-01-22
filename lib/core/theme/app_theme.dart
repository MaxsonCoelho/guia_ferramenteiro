import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  // Cores Metálicas e Tons de Cinza
  static const Color gunMetal = Color(0xFF2A2A2A); // Cinza Escuro (Fundo)
  static const Color brushedMetal = Color(0xFF484848); // Cinza Médio (Superfícies)
  static const Color silver = Color(0xFFC0C0C0); // Prata (Destaques/Texto Principal)
  static const Color chrome = Color(0xFFE8E8E8); // Branco Metálico (Títulos/Ícones)
  static const Color steel = Color(0xFF78909C); // Azul Acinzentado (Detalhes)
  
  static final ThemeData metalTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: gunMetal,
    primaryColor: brushedMetal,
    
    colorScheme: const ColorScheme.dark(
      primary: silver,
      secondary: steel,
      surface: brushedMetal,
      background: gunMetal,
      onPrimary: gunMetal, // Texto preto/escuro sobre prata
      onSecondary: Colors.white,
      onSurface: chrome,
      onBackground: silver,
      error: Color(0xFFCF6679),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: gunMetal,
      foregroundColor: chrome,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: chrome,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: chrome, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: chrome, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: chrome, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: silver, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: silver),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0)), // Cinza claro para texto secundário
    ),

    // cardTheme: CardTheme(
    //   color: brushedMetal,
    //   elevation: 4,
    //   shadowColor: Colors.black54,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     side: const BorderSide(color: Color(0xFF5C5C5C), width: 1), // Borda metálica sutil
    //   ),
    // ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: silver,
        foregroundColor: gunMetal, // Texto escuro no botão prata
        elevation: 6,
        shadowColor: Colors.black45,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: silver,
        side: const BorderSide(color: silver, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    iconTheme: const IconThemeData(
      color: chrome,
      size: 24,
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFF5C5C5C),
      thickness: 1,
    ),
  );
}

// Provider para expor o tema para a aplicação
final themeProvider = Provider<ThemeData>((ref) {
  return AppTheme.metalTheme;
});
