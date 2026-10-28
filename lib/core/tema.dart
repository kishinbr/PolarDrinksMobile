import 'package:flutter/material.dart';

/// Cores da identidade PolarDrinks (as mesmas da loja web).
class CoresPolar {
  static const azul = Color(0xFF0277C9);
  static const azulEscuro = Color(0xFF035A99);
  static const azulGelo = Color(0xFF38BDF8);
  static const azulTinta = Color(0xFFE8F4FC);
  static const azulNoite = Color(0xFF08233D);
  static const azulProfundo = Color(0xFF0B3A63);

  static const texto = Color(0xFF0A0A0A);
  static const textoSuave = Color(0xFF374151);
  static const textoFraco = Color(0xFF6B7280);
  static const textoApagado = Color(0x59000000); // preto 35%

  static const fundo = Colors.white;
  static const fundoSuave = Color(0xFFF2F4F6);
  static const fundoGelo = Color(0xFFF1F6FA);
  static const midia = Color(0xFFF2F2F2);
  static const borda = Color(0xFFE5E7EB);

  static const sucesso = Color(0xFF15803D);
  static const sucessoTinta = Color(0xFFE9F7EE);
  static const alerta = Color(0xFFB45309);
  static const alertaTinta = Color(0xFFFEF6E7);
  static const erro = Color(0xFFC81E1E);
  static const erroTinta = Color(0xFFFDECEC);

  static const selo = Color(0xD918181B); // preto 85%
}

/// Estilos de texto repetidos nas telas.
class TextosPolar {
  /// Títulos grandes em caixa alta (ex.: "NOSSOS PRODUTOS").
  static const titulo = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.4,
    height: 1.15,
    color: CoresPolar.texto,
  );

  static const subtitulo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: CoresPolar.textoFraco,
  );

  /// Rótulos pequenos em caixa alta com espaçamento (ex.: "E-MAIL", "CATEGORIA").
  static const rotulo = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.8,
    color: CoresPolar.textoSuave,
  );

  static const secao = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    color: CoresPolar.texto,
  );
}

class TemaPolar {
  static const raio = 12.0;
  static const raioGrande = 16.0;

  static ThemeData get tema {
    final esquema = ColorScheme.fromSeed(seedColor: CoresPolar.azul).copyWith(
      primary: CoresPolar.azul,
      onPrimary: Colors.white,
      secondary: CoresPolar.texto,
      surface: Colors.white,
      onSurface: CoresPolar.texto,
      error: CoresPolar.erro,
    );

    final bordaCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(raio),
      borderSide: const BorderSide(color: CoresPolar.borda, width: 1.5),
    );

    const textoBotao = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.5,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: esquema,
      scaffoldBackgroundColor: Colors.white,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: CoresPolar.borda,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: CoresPolar.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CoresPolar.azul,
          foregroundColor: Colors.white,
          disabledBackgroundColor: CoresPolar.azul.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio)),
          textStyle: textoBotao,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CoresPolar.texto,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: const BorderSide(color: CoresPolar.texto, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio)),
          textStyle: textoBotao,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CoresPolar.azul,
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CoresPolar.fundoSuave,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: Color(0xFF9AA1AB), fontWeight: FontWeight.w500, fontSize: 14),
        prefixIconColor: CoresPolar.textoFraco,
        suffixIconColor: CoresPolar.textoFraco,
        border: bordaCampo,
        enabledBorder: bordaCampo,
        focusedBorder: bordaCampo.copyWith(
          borderSide: const BorderSide(color: CoresPolar.azul, width: 1.5),
        ),
        errorBorder: bordaCampo.copyWith(
          borderSide: const BorderSide(color: CoresPolar.erro, width: 1.5),
        ),
        focusedErrorBorder: bordaCampo.copyWith(
          borderSide: const BorderSide(color: CoresPolar.erro, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CoresPolar.texto,
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CoresPolar.azulTinta,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final ativo = estados.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: ativo ? CoresPolar.azul : CoresPolar.textoFraco,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final ativo = estados.contains(WidgetState.selected);
          return IconThemeData(color: ativo ? CoresPolar.azul : CoresPolar.textoFraco, size: 24);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: CoresPolar.azul),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: Color(0xFFC3C8CF), width: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
