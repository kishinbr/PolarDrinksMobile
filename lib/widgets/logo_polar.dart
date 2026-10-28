import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Urso + "polardrinks", igual ao logo do site.
class LogoPolar extends StatelessWidget {
  final double tamanho;

  const LogoPolar({super.key, this.tamanho = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/urso.png', width: tamanho * 1.45, height: tamanho * 1.45),
        SizedBox(width: tamanho * 0.35),
        Text.rich(
          TextSpan(
            children: const [
              TextSpan(text: 'polar'),
              TextSpan(text: 'drinks', style: TextStyle(color: CoresPolar.azul)),
            ],
            style: TextStyle(
              fontSize: tamanho,
              fontWeight: FontWeight.w900,
              letterSpacing: -tamanho * 0.03,
              height: 1,
              color: CoresPolar.texto,
            ),
          ),
        ),
      ],
    );
  }
}
