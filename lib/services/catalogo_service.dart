import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/produto.dart';
import '../models/categoria.dart';

class CatalogoService {
  Future<List<Produto>> buscarProdutos({int? categoriaId}) async {
    final queryParams = <String, String>{};
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId.toString();
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/catalogo/produtos')
        .replace(queryParameters: queryParams);

    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível carregar o catálogo.');
    }

    final List<dynamic> dados = jsonDecode(resposta.body);
    return dados.map((item) => Produto.fromJson(item)).toList();
  }

  Future<List<Categoria>> listarCategorias() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/catalogo/categorias');
    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível carregar as categorias.');
    }

    final List<dynamic> dados = jsonDecode(resposta.body);
    return dados.map((item) => Categoria.fromJson(item)).toList();
  }
}