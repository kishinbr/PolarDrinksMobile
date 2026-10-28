import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/pedido.dart';

/// Lista "ITENS DO PEDIDO" + total, usada na confirmação e no detalhe do pedido.
class ItensPedido extends StatelessWidget {
  final Pedido pedido;

  const ItensPedido({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ITENS DO PEDIDO',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8, color: CoresPolar.textoFraco),
        ),
        const SizedBox(height: 4),
        for (final item in pedido.itens)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CoresPolar.borda))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${item.itemPedidoQtd}× ${item.produtoNome}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Text(formatarPreco(item.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'TOTAL DO PEDIDO',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: CoresPolar.textoFraco),
            ),
            const Spacer(),
            Text(formatarPreco(pedido.pedidoValorTotal), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}
