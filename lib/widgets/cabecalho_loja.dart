import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tema.dart';
import 'logo_polar.dart';

/// Faixa azul com avisos + barra branca com o logo, como no topo da loja web.
class CabecalhoLoja extends StatelessWidget {
  const CabecalhoLoja({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            color: CoresPolar.azul,
            child: const SafeArea(
              bottom: false,
              child: _FaixaAviso(),
            ),
          ),
          Container(
            height: 58,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: CoresPolar.borda)),
            ),
            child: const LogoPolar(tamanho: 21),
          ),
        ],
      ),
    );
  }
}

class _FaixaAviso extends StatefulWidget {
  const _FaixaAviso();

  @override
  State<_FaixaAviso> createState() => _FaixaAvisoState();
}

class _FaixaAvisoState extends State<_FaixaAviso> {
  static const _mensagens = [
    'Peça online e retire gelado na loja',
    'Pagamento por Pix ou cartão',
    'Retire em até 24 horas após a separação',
  ];

  int _indice = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (mounted) setState(() => _indice = (_indice + 1) % _mensagens.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            _mensagens[_indice].toUpperCase(),
            key: ValueKey(_indice),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
