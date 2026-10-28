import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/categoria.dart';
import '../models/produto.dart';

class CatalogoService {
  /// Muda de valor quando o estoque pode ter mudado (pedido feito, recusado ou cancelado).
  /// O catálogo escuta e recarrega sozinho, sem o cliente precisar puxar a tela.
  static final ValueNotifier<int> estoqueAlterado = ValueNotifier(0);

  static void avisarEstoqueAlterado() => estoqueAlterado.value++;

  final ApiClient _api = ApiClient.instance;

  /// Catálogo completo de produtos ativos. Os filtros da tela são aplicados no próprio app.
  Future<List<Produto>> buscarProdutos({String? termo, int? categoriaId}) async {
    final query = <String, String>{
      if (termo != null && termo.isNotEmpty) 'termo': termo,
      if (categoriaId != null) 'categoriaId': '$categoriaId',
    };

    final dados = await _api.get('/api/catalogo/produtos', query: query);

    if (dados is! List) return [];
    return dados.map((item) => Produto.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Categoria>> listarCategorias() async {
    final dados = await _api.get('/api/catalogo/categorias');

    if (dados is! List) return [];
    return dados.map((item) => Categoria.fromJson(item as Map<String, dynamic>)).toList();
  }
}
