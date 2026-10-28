import 'package:flutter/material.dart';

import '../models/pedido.dart';

/// Etiqueta colorida com o status do pedido (mesmas cores da loja web).
class SeloStatus extends StatelessWidget {
  final StatusPedido status;

  const SeloStatus(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: status.fundo, borderRadius: BorderRadius.circular(99)),
      child: Text(
        status.texto.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: status.cor),
      ),
    );
  }
}
