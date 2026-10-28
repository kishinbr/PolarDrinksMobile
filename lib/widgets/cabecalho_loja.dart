import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tema.dart';
import 'logo_polar.dart';

/// Barra branca com o logo, no topo da loja.
class CabecalhoLoja extends StatelessWidget {
  const CabecalhoLoja({super.key});

  @override
  Widget build(BuildContext context) {
    // Fundo branco: ícones escuros na barra de status (hora, bateria).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: CoresPolar.borda)),
        ),
        child: const SafeArea(
          bottom: false,
          child: SizedBox(
            height: 58,
            child: Center(child: LogoPolar(tamanho: 21)),
          ),
        ),
      ),
    );
  }
}
