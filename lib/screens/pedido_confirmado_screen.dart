import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/pedido.dart';
import '../widgets/borda_tracejada.dart';
import '../widgets/componentes.dart';

/// O que fazer ao sair da tela de pedido confirmado.
enum DestinoAposPedido { catalogo, pedidos }

/// Tela depois do checkout: código de retirada em destaque, itens e total (igual à loja web).
/// Fecha devolvendo para onde o cliente quer ir.
class PedidoConfirmadoScreen extends StatelessWidget {
  final Pedido pedido;

  const PedidoConfirmadoScreen({super.key, required this.pedido});

  void _copiarCodigo(BuildContext context) {
    Clipboard.setData(ClipboardData(text: pedido.pedidoCodigo));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Código copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    final data = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(pedido.pedidoData);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PEDIDO #${pedido.pedidoID}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(DestinoAposPedido.catalogo),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
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
              'Feito em $data · ${pedido.pagamentoTexto}',
              textAlign: TextAlign.center,
              style: TextosPolar.subtitulo,
            ),
            const SizedBox(height: 28),

            // Código de retirada
            BordaTracejada(
              cor: CoresPolar.azul,
              child: Material(
                color: CoresPolar.azulTinta,
                borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
                child: InkWell(
                  borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
                  onTap: () => _copiarCodigo(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                    child: Column(
                      children: [
                        const Text(
                          'SEU CÓDIGO DE RETIRADA',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: CoresPolar.azulEscuro),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          // compensa o espaçamento após o último dígito, para centralizar
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            pedido.pedidoCodigo,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: 14,
                              color: CoresPolar.azulNoite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded, size: 13, color: CoresPolar.azulEscuro),
                            SizedBox(width: 5),
                            Text(
                              'Toque para copiar',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CoresPolar.azulEscuro),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Aviso(
              'Apresente esse código e o seu nome na loja para retirar o pedido. '
              'Você tem até 24 horas após a separação para retirar.',
              tipo: TipoAviso.info,
            ),

            // Itens
            const SizedBox(height: 28),
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

            // Ações
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
