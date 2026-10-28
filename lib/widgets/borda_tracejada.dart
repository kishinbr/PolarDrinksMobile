import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// Borda tracejada arredondada (o Flutter não tem uma pronta).
/// Usada na caixa do código de retirada, como no site.
class BordaTracejada extends StatelessWidget {
  final Widget child;
  final Color cor;
  final double raio;
  final double espessura;
  final double traco;
  final double espaco;

  const BordaTracejada({
    super.key,
    required this.child,
    required this.cor,
    this.raio = 16,
    this.espessura = 2,
    this.traco = 7,
    this.espaco = 5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _PintorTracejado(cor, raio, espessura, traco, espaco),
      child: child,
    );
  }
}

class _PintorTracejado extends CustomPainter {
  final Color cor;
  final double raio;
  final double espessura;
  final double traco;
  final double espaco;

  _PintorTracejado(this.cor, this.raio, this.espessura, this.traco, this.espaco);

  @override
  void paint(Canvas canvas, Size size) {
    final metade = espessura / 2;
    final contorno = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(metade, metade, size.width - espessura, size.height - espessura),
        Radius.circular(raio),
      ));

    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura;

    for (final PathMetric medida in contorno.computeMetrics()) {
      double inicio = 0;
      while (inicio < medida.length) {
        canvas.drawPath(medida.extractPath(inicio, inicio + traco), pincel);
        inicio += traco + espaco;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorTracejado antigo) =>
      antigo.cor != cor || antigo.raio != raio || antigo.espessura != espessura;
}
