import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../widgets/caixa_codigo.dart';
import '../widgets/componentes.dart';
import '../widgets/itens_pedido.dart';
import '../widgets/selo_status.dart';

/// Detalhe de um pedido: número, status, código de retirada, histórico, itens, total e cancelar.
/// Busca a versão mais recente ao abrir, porque o status pode ter mudado na loja.
class PedidoDetalheScreen extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetalheScreen({super.key, required this.pedido});

  @override
  State<PedidoDetalheScreen> createState() => _PedidoDetalheScreenState();
}

class _PedidoDetalheScreenState extends State<PedidoDetalheScreen> {
  late Pedido _pedido = widget.pedido;
  bool _cancelando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  Future<void> _atualizar() async {
    try {
      final atual = await PedidoService.instance.obter(_pedido.pedidoID);
      if (mounted) setState(() => _pedido = atual);
    } on ApiException {
      // Sem conexão: continua mostrando o que já tinha.
    }
  }

  Future<void> _cancelar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Cancelar pedido?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('O pedido #${_pedido.pedidoID} será cancelado e o estorno será processado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('VOLTAR', style: TextStyle(color: CoresPolar.textoFraco)),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('CANCELAR PEDIDO', style: TextStyle(color: CoresPolar.erro)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _cancelando = true;
      _erro = null;
    });

    try {
      final atualizado = await PedidoService.instance.cancelar(_pedido.pedidoID);
      if (mounted) setState(() => _pedido = atualizado);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _cancelando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = _pedido;
    final status = pedido.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PEDIDO #${pedido.pedidoID}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('PEDIDO #${pedido.pedidoID}', style: TextosPolar.titulo.copyWith(fontSize: 22)),
                ),
                SeloStatus(status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Feito em ${formatarDataHora(pedido.pedidoData)}', style: TextosPolar.subtitulo),
            const SizedBox(height: 20),

            if (_erro != null) ...[
              Aviso(_erro!),
              const SizedBox(height: 14),
            ],
            ..._avisoDoStatus(pedido),

            QuadrosInfo(itens: [
              ('Nº do pedido', '#${pedido.pedidoID}'),
              ('Pagamento', pedido.pagamentoTexto),
            ]),
            const SizedBox(height: 12),

            // Código grande só enquanto o pedido ainda vai ser retirado
            if (status.emAndamento)
              CaixaCodigo(codigo: pedido.pedidoCodigo)
            else
              QuadrosInfo(itens: [('Código de retirada', pedido.pedidoCodigo)]),

            const SizedBox(height: 24),
            _Historico(pedido: pedido),

            const SizedBox(height: 24),
            ItensPedido(pedido: pedido),

            if (pedido.podeCancelar) ...[
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: _cancelando ? null : _cancelar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: CoresPolar.erro,
                  side: const BorderSide(color: CoresPolar.erro, width: 1.5),
                ),
                icon: _cancelando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: CoresPolar.erro),
                      )
                    : const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('CANCELAR PEDIDO'),
              ),
              const SizedBox(height: 8),
              Text(
                'Você pode cancelar até ${formatarDataHora(pedido.pedidoData.add(const Duration(hours: 24)))}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CoresPolar.textoFraco),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _avisoDoStatus(Pedido pedido) {
    final (String? texto, TipoAviso tipo) = switch (pedido.status) {
      StatusPedido.aguardandoSeparacao => ('Estamos separando seu pedido. Avisaremos no status quando estiver pronto.', TipoAviso.alerta),
      StatusPedido.separado => (
          pedido.limiteRetirada == null
              ? 'Seu pedido está pronto para retirada.'
              : 'Seu pedido está pronto! Retire até ${formatarDataHora(pedido.limiteRetirada!)}.',
          TipoAviso.info,
        ),
      StatusPedido.concluido => ('Pedido retirado. Obrigado pela compra!', TipoAviso.sucesso),
      StatusPedido.canceladoNaoRetirado => ('O prazo de retirada passou e o pedido expirou.', TipoAviso.erro),
      StatusPedido.canceladoCliente || StatusPedido.canceladoAdmin => ('Este pedido foi cancelado.', TipoAviso.erro),
      StatusPedido.desconhecido => (null, TipoAviso.info),
    };

    if (texto == null) return const [];
    return [Aviso(texto, tipo: tipo), const SizedBox(height: 14)];
  }
}

/// Linha do tempo: comprado, separado, retirado.
class _Historico extends StatelessWidget {
  final Pedido pedido;

  const _Historico({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final etapas = <(IconData, String, DateTime?)>[
      (Icons.shopping_bag_outlined, 'Comprado', pedido.pedidoData),
      (Icons.inventory_2_outlined, 'Separado', pedido.pedidoDataSeparado),
      (Icons.check_circle_outline, 'Retirado', pedido.pedidoDataConcluido),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ANDAMENTO',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8, color: CoresPolar.textoFraco),
        ),
        const SizedBox(height: 10),
        for (final (icone, nome, data) in etapas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: data != null ? CoresPolar.azul : CoresPolar.fundoSuave,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, size: 15, color: data != null ? Colors.white : const Color(0xFFB0B6BE)),
                ),
                const SizedBox(width: 12),
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: data != null ? CoresPolar.texto : CoresPolar.textoFraco,
                  ),
                ),
                const Spacer(),
                Text(
                  data != null ? formatarDataHora(data) : '—',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
