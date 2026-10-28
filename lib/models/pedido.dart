import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Pedido da loja online, como a API devolve (PedidoResponse).
class Pedido {
  final int pedidoID;
  final String pedidoCodigo;
  final DateTime pedidoData;
  final String pedidoStatus;
  final double pedidoValorTotal;
  final String pedidoTipoPagamento;
  final DateTime? pedidoDataSeparado;
  final DateTime? pedidoDataConcluido;
  final List<ItemPedido> itens;

  const Pedido({
    required this.pedidoID,
    required this.pedidoCodigo,
    required this.pedidoData,
    required this.pedidoStatus,
    required this.pedidoValorTotal,
    required this.pedidoTipoPagamento,
    required this.pedidoDataSeparado,
    required this.pedidoDataConcluido,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      pedidoID: json['pedidoID'] as int,
      pedidoCodigo: (json['pedidoCodigo'] ?? '') as String,
      pedidoData: _lerData(json['pedidoData']) ?? DateTime.now(),
      pedidoStatus: (json['pedidoStatus'] ?? '') as String,
      pedidoValorTotal: (json['pedidoValorTotal'] as num? ?? 0).toDouble(),
      pedidoTipoPagamento: (json['pedidoTipoPagamento'] ?? '') as String,
      pedidoDataSeparado: _lerData(json['pedidoDataSeparado']),
      pedidoDataConcluido: _lerData(json['pedidoDataConcluido']),
      itens: (json['itens'] as List? ?? const [])
          .map((item) => ItemPedido.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static DateTime? _lerData(dynamic valor) => valor is String ? DateTime.tryParse(valor)?.toLocal() : null;

  StatusPedido get status => StatusPedido.de(pedidoStatus);

  String get pagamentoTexto => switch (pedidoTipoPagamento) {
        TipoPagamento.cartao => 'Cartão',
        TipoPagamento.pix => 'Pix',
        _ => pedidoTipoPagamento,
      };

  int get quantidadeItens => itens.fold(0, (soma, item) => soma + item.itemPedidoQtd);

  /// O cliente pode cancelar até 24 horas após a compra, enquanto não retirou (regra da API).
  bool get podeCancelar =>
      status.emAndamento && DateTime.now().isBefore(pedidoData.add(const Duration(hours: 24)));

  /// Até quando dá para retirar um pedido separado.
  DateTime? get limiteRetirada => pedidoDataSeparado?.add(const Duration(hours: 24));
}

class ItemPedido {
  final int itemPedidoQtd;
  final double itemPedidoPreco;
  final String produtoNome;

  const ItemPedido({required this.itemPedidoQtd, required this.itemPedidoPreco, required this.produtoNome});

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    final produto = json['produto'];

    return ItemPedido(
      itemPedidoQtd: (json['itemPedidoQtd'] as num? ?? 0).toInt(),
      itemPedidoPreco: (json['itemPedidoPreco'] as num? ?? 0).toDouble(),
      produtoNome: produto is Map && produto['produtoNome'] is String ? produto['produtoNome'] as String : 'Produto',
    );
  }

  double get subtotal => itemPedidoPreco * itemPedidoQtd;
}

/// Valores aceitos pela API em "tipoPagamento" (sem acento, como no backend).
class TipoPagamento {
  static const cartao = 'Cartao';
  static const pix = 'Pix';
}

/// Status do pedido com o texto e as cores usados na loja web.
enum StatusPedido {
  aguardandoSeparacao('AguardandoSeparacao', 'Aguardando separação', CoresPolar.alertaTinta, CoresPolar.alerta),
  separado('Separado', 'Pronto para retirada', CoresPolar.azulTinta, CoresPolar.azulEscuro),
  concluido('Concluido', 'Retirado', CoresPolar.sucessoTinta, CoresPolar.sucesso),
  canceladoCliente('CanceladoCliente', 'Você cancelou', CoresPolar.erroTinta, CoresPolar.erro),
  canceladoNaoRetirado('CanceladoNaoRetirado', 'Expirado', CoresPolar.erroTinta, CoresPolar.erro),
  canceladoAdmin('CanceladoAdmin', 'Cancelado', CoresPolar.erroTinta, CoresPolar.erro),
  desconhecido('', 'Desconhecido', CoresPolar.fundoSuave, CoresPolar.textoSuave);

  final String valorApi;
  final String texto;
  final Color fundo;
  final Color cor;

  const StatusPedido(this.valorApi, this.texto, this.fundo, this.cor);

  static StatusPedido de(String valor) =>
      values.firstWhere((s) => s.valorApi == valor, orElse: () => StatusPedido.desconhecido);

  /// Ainda não foi retirado nem cancelado.
  bool get emAndamento => this == aguardandoSeparacao || this == separado;
}
