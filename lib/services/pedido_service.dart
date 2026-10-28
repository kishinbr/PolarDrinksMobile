import '../core/api_client.dart';
import '../models/pedido.dart';
import 'carrinho_service.dart';

/// Pedidos do cliente na API (/api/pedidos).
class PedidoService {
  PedidoService._();
  static final PedidoService instance = PedidoService._();

  final ApiClient _api = ApiClient.instance;

  /// Transforma o carrinho do servidor em pedido. O servidor confere o estoque de novo,
  /// calcula o total, gera o código de retirada e esvazia o carrinho.
  Future<Pedido> finalizarCompra(String tipoPagamento) async {
    try {
      final dados = await _api.post('/api/pedidos/checkout', corpo: {'tipoPagamento': tipoPagamento});

      CarrinhoService.instance.marcarComoVazio();
      return Pedido.fromJson(dados as Map<String, dynamic>);
    } on ApiException {
      // Algo mudou (estoque, produto desativado): atualiza o carrinho para o cliente ver.
      CarrinhoService.instance.carregar();
      rethrow;
    }
  }
}
