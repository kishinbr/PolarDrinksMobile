import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/pedido.dart';
import 'auth_service.dart';
import 'carrinho_service.dart';

/// Pedidos do cliente na API (/api/pedidos): finalizar compra, listar, ver detalhe e cancelar.
class PedidoService extends ChangeNotifier {
  PedidoService._() {
    AuthService.instance.addListener(_aoMudarSessao);
  }

  static final PedidoService instance = PedidoService._();

  final ApiClient _api = ApiClient.instance;

  List<Pedido> _pedidos = const [];
  bool _carregado = false;
  String? _erro;
  Future<void>? _carregamento;

  /// Pedidos do mais recente para o mais antigo (ordem da API).
  List<Pedido> get pedidos => _pedidos;
  List<Pedido> get emAndamento => _pedidos.where((p) => p.status.emAndamento).toList();
  List<Pedido> get finalizados => _pedidos.where((p) => !p.status.emAndamento).toList();

  bool get carregado => _carregado;
  bool get carregando => _carregamento != null;
  String? get erro => _erro;

  /// Busca a lista de pedidos. Chamadas repetidas enquanto uma está em andamento aproveitam a mesma.
  Future<void> carregar() {
    if (!AuthService.instance.estaLogado) return Future.value();

    final emCurso = _carregamento;
    if (emCurso != null) return emCurso;

    _erro = null;
    final busca = _buscar().whenComplete(() {
      _carregamento = null;
      notifyListeners();
    });

    _carregamento = busca;
    notifyListeners();
    return busca;
  }

  Future<void> _buscar() async {
    try {
      final dados = await _api.get('/api/pedidos');
      _pedidos = dados is List
          ? dados.map((p) => Pedido.fromJson(p as Map<String, dynamic>)).toList()
          : const [];
      _carregado = true;
    } on ApiException catch (e) {
      _erro = e.mensagem;
    }
  }

  /// Versão mais recente de um pedido (o status pode ter mudado na loja).
  Future<Pedido> obter(int pedidoId) async {
    final dados = await _api.get('/api/pedidos/$pedidoId');
    final pedido = Pedido.fromJson(dados as Map<String, dynamic>);
    _substituir(pedido);
    return pedido;
  }

  /// Transforma o carrinho do servidor em pedido. O servidor confere o estoque de novo,
  /// calcula o total, gera o código de retirada e esvazia o carrinho.
  Future<Pedido> finalizarCompra(String tipoPagamento) async {
    try {
      final dados = await _api.post('/api/pedidos/checkout', corpo: {'tipoPagamento': tipoPagamento});
      final pedido = Pedido.fromJson(dados as Map<String, dynamic>);

      CarrinhoService.instance.marcarComoVazio();
      _pedidos = [pedido, ..._pedidos];
      notifyListeners();

      return pedido;
    } on ApiException {
      // Algo mudou (estoque, produto desativado): atualiza o carrinho para o cliente ver.
      CarrinhoService.instance.carregar();
      rethrow;
    }
  }

  /// Cancela pelo cliente (até 24 horas após a compra, enquanto não foi retirado).
  /// O servidor devolve os produtos ao estoque.
  Future<Pedido> cancelar(int pedidoId) async {
    await _api.post('/api/pedidos/$pedidoId/cancelar');
    return obter(pedidoId);
  }

  void _substituir(Pedido pedido) {
    final indice = _pedidos.indexWhere((p) => p.pedidoID == pedido.pedidoID);
    if (indice < 0) return;

    _pedidos = [..._pedidos]..[indice] = pedido;
    notifyListeners();
  }

  void _aoMudarSessao() {
    if (AuthService.instance.estaLogado) return;

    _pedidos = const [];
    _carregado = false;
    _erro = null;
    notifyListeners();
  }
}
