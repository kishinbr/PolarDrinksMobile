import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Erro devolvido pela API (ou de conexão), já com a mensagem pronta para mostrar na tela.
class ApiException implements Exception {
  final String mensagem;
  final int? status;

  /// Campo do formulário com problema, quando a API informa (ex.: "email", "cpf").
  final String? campo;

  const ApiException(this.mensagem, {this.status, this.campo});

  @override
  String toString() => mensagem;
}

/// Ponto único de acesso à API: monta a URL, envia o token e trata erros.
/// Todas as telas e serviços usam este cliente em vez de chamar o pacote http direto.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  /// Chamado quando a API responde 401 numa rota protegida (token vencido ou inválido).
  void Function()? aoExpirarSessao;

  void definirToken(String? token) => _token = token;

  Future<dynamic> get(String caminho, {Map<String, String>? query}) =>
      _enviar('GET', caminho, query: query);

  Future<dynamic> post(String caminho, {Object? corpo}) => _enviar('POST', caminho, corpo: corpo);

  Future<dynamic> put(String caminho, {Object? corpo}) => _enviar('PUT', caminho, corpo: corpo);

  Future<dynamic> delete(String caminho) => _enviar('DELETE', caminho);

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Map<String, String>? query,
    Object? corpo,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$caminho').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );

    final requisicao = http.Request(metodo, uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Content-Type'] = 'application/json; charset=utf-8';

    if (_token != null) {
      requisicao.headers['Authorization'] = 'Bearer $_token';
    }

    if (corpo != null) {
      requisicao.body = jsonEncode(corpo);
    }

    final resposta = await _executar(requisicao);
    final dados = _lerJson(resposta);

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return dados;
    }

    final rotaDeLogin = caminho.startsWith('/api/cliente/auth');

    if (resposta.statusCode == 401 && !rotaDeLogin) {
      aoExpirarSessao?.call();
      throw const ApiException('Sua sessão expirou. Entre novamente.', status: 401);
    }

    throw ApiException(
      _mensagemDeErro(dados, resposta.statusCode),
      status: resposta.statusCode,
      campo: dados is Map && dados['campo'] is String ? dados['campo'] as String : null,
    );
  }

  static const _mensagemSemConexao =
      'Não foi possível conectar ao servidor. Verifique sua conexão e se a API está rodando.';

  Future<http.Response> _executar(http.Request requisicao) async {
    try {
      final enviada = await requisicao.send().timeout(ApiConfig.tempoLimite);
      return await http.Response.fromStream(enviada);
    } on TimeoutException {
      throw const ApiException('O servidor demorou para responder. Tente novamente.');
    } on SocketException {
      throw const ApiException(_mensagemSemConexao);
    } on http.ClientException {
      throw const ApiException(_mensagemSemConexao);
    }
  }

  dynamic _lerJson(http.Response resposta) {
    if (resposta.bodyBytes.isEmpty) return null;

    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  String _mensagemDeErro(dynamic dados, int status) {
    if (dados is Map) {
      // Formato da API do PolarDrinks: { "mensagem": "..." }
      if (dados['mensagem'] is String) return dados['mensagem'] as String;

      // Erro de validação padrão do ASP.NET: { "title": "...", "errors": {...} }
      if (dados['title'] is String) return dados['title'] as String;
    }

    if (status == 404) return 'Não encontrado.';
    if (status >= 500) return 'O servidor encontrou um erro. Tente novamente em instantes.';

    return 'Não foi possível concluir a operação (erro $status).';
  }
}
