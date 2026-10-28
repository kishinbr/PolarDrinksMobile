import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/pedido.dart';
import '../widgets/caixa_codigo.dart';
import '../widgets/componentes.dart';
import '../widgets/itens_pedido.dart';

/// O que fazer ao sair da tela de pedido confirmado.
enum DestinoAposPedido { catalogo, pedidos }

/// Tela depois do checkout: número do pedido, código de retirada em destaque, itens e total.
/// Fecha devolvendo para onde o cliente quer ir.
class PedidoConfirmadoScreen extends StatelessWidget {
  final Pedido pedido;

  const PedidoConfirmadoScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(DestinoAposPedido.catalogo),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: CoresPolar.sucessoTinta, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 36, color: CoresPolar.sucesso),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'PEDIDO CONFIRMADO!',
              textAlign: TextAlign.center,
              style: TextosPolar.titulo.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              'Feito em ${formatarDataHora(pedido.pedidoData)}',
              textAlign: TextAlign.center,
              style: TextosPolar.subtitulo,
            ),
            const SizedBox(height: 26),

            QuadrosInfo(itens: [
              ('Nº do pedido', '#${pedido.pedidoID}'),
              ('Pagamento', pedido.pagamentoTexto),
            ]),
            const SizedBox(height: 12),
            CaixaCodigo(codigo: pedido.pedidoCodigo),
            const SizedBox(height: 16),
            const Aviso(
              'Apresente o código de retirada e o seu nome na loja para retirar o pedido. '
              'Você tem até 24 horas após a separação para retirar.',
              tipo: TipoAviso.info,
            ),

            const SizedBox(height: 28),
            ItensPedido(pedido: pedido),

            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(DestinoAposPedido.pedidos),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('MEUS PEDIDOS'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(DestinoAposPedido.catalogo),
              child: const Text('CONTINUAR COMPRANDO'),
            ),
          ],
        ),
      ),
    );
  }
}
