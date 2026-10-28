import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tema.dart';
import '../widgets/logo_polar.dart';

/// Estrutura comum de login e cadastro: logo no topo, cartão branco com título e formulário.
class ContaLayout extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Widget> children;
  final bool mostrarVoltar;

  const ContaLayout({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.children,
    this.mostrarVoltar = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ícones escuros na barra de status (o resto do app usa a faixa azul com ícones claros).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
      backgroundColor: CoresPolar.fundoGelo,
      appBar: mostrarVoltar
          ? AppBar(
              backgroundColor: CoresPolar.fundoGelo,
              leading: const BackButton(),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, mostrarVoltar ? 0 : 32, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  const LogoPolar(tamanho: 24),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
                      border: Border.all(color: CoresPolar.borda),
                      boxShadow: [
                        BoxShadow(
                          color: CoresPolar.azulNoite.withValues(alpha: 0.06),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          titulo.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextosPolar.titulo.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitulo,
                          textAlign: TextAlign.center,
                          style: TextosPolar.subtitulo.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 26),
                        ...children,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
