import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/carrinho.dart';
import 'auth_service.dart';

/// Carrinho do cliente, guardado no servidor (o mesmo carrinho da loja web).
///
/// Toda ação chama a API e a resposta já é o carrinho atualizado, então a tela
/// sempre mostra o preço, o estoque e o total calculados pelo servidor.
/// Erros (ex.: "Apenas 2 unidades disponíveis") chegam como [ApiException].
class CarrinhoService extends ChangeNotifier {
  CarrinhoService._() {
    AuthService.instance.addListener(_aoMudarSessao);
  }

  static final CarrinhoService instance = CarrinhoService._();

  /// Chave da lista local usada antes da fase 2 (migrada para o servidor no primeiro uso).
  static const _chaveListaAntiga = 'lista_compras';

  final ApiClient _api = ApiClient.instance;

  Carrinho _carrinho = Carrinho.vazio;
  bool _carregado = false;
  String? _erro;
  bool _limpando = false;
  Future<void>? _carregamento;

  /// Produtos com uma alteração em andamento (os botões deles ficam desativados).
  final Set<int> _ocupados = {};

  Carrinho get carrinho => _carrinho;
  List<ItemCarrinho> get itens => _carrinho.itens;
  double get total => _carrinho.total;
  int get quantidadeTotal => _carrinho.quantidadeTotal;
  bool get estaVazio => _carrinho.estaVazio;

  /// Já recebeu o carrinho do servidor pelo menos uma vez nesta sessão.
  bool get carregado => _carregado;
  bool get carregando => _carregamento != null;
  bool get limpando => _limpando;
  String? get erro => _erro;

  bool estaOcupado(int produtoId) => _ocupados.contains(produtoId);

  /// Busca o carrinho no servidor. Chamadas repetidas enquanto uma está em andamento aproveitam a mesma.
  Future<void> carregar() {
    if (!AuthService.instance.estaLogado) return Future.value();

    final emAndamento = _carregamento;
    if (emAndamento != null) return emAndamento;

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
      await _migrarListaAntiga();
      _aplicar(await _api.get('/api/carrinho'));
      _carregado = true;
    } on ApiException catch (e) {
      _erro = e.mensagem;
    }
  }

  Future<void> adicionar(int produtoId, {int quantidade = 1}) => _alterarItem(
        produtoId,
        () => _api.post('/api/carrinho/itens', corpo: {'produtoID': produtoId, 'quantidade': quantidade}),
      );

  /// Quantidade 0 ou menor remove o item (regra da API).
  Future<void> alterarQuantidade(int produtoId, int novaQuantidade) => _alterarItem(
        produtoId,
        () => _api.put('/api/carrinho/itens/$produtoId', corpo: {'quantidade': novaQuantidade}),
      );

  Future<void> remover(int produtoId) =>
      _alterarItem(produtoId, () => _api.delete('/api/carrinho/itens/$produtoId'));

  Future<void> limpar() async {
    _limpando = true;
    notifyListeners();

    try {
      await _api.delete('/api/carrinho');
      _carrinho = Carrinho.vazio;
    } finally {
      _limpando = false;
      notifyListeners();
    }
  }

  /// Depois que um pedido é finalizado o servidor esvazia o carrinho; aqui só acompanha.
  void marcarComoVazio() {
    _carrinho = Carrinho.vazio;
    notifyListeners();
  }

  // ===== internos =====

  Future<void> _alterarItem(int produtoId, Future<dynamic> Function() chamada) async {
    if (_ocupados.contains(produtoId)) return;

    _ocupados.add(produtoId);
    notifyListeners();

    try {
      _aplicar(await chamada());
      _carregado = true;
      _erro = null;
    } finally {
      _ocupados.remove(produtoId);
      notifyListeners();
    }
  }

  void _aplicar(dynamic dados) {
    if (dados is Map<String, dynamic>) {
      _carrinho = Carrinho.fromJson(dados);
    }
  }

  /// Leva para o servidor os itens que estavam na lista local da fase 1 (uma vez só).
  Future<void> _migrarListaAntiga() async {
    SharedPreferences? prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      prefs = null;
    }

    if (prefs == null) return;

    final salvo = prefs.getString(_chaveListaAntiga);
    if (salvo == null) return;

    List<Map<String, dynamic>> itens;

    try {
      itens = (jsonDecode(salvo) as List)
          .whereType<Map<String, dynamic>>()
          .where((i) => i['produtoID'] is int && i['quantidade'] is int && (i['quantidade'] as int) > 0)
          .map((i) => {'produtoID': i['produtoID'], 'quantidade': i['quantidade']})
          .toList();
    } catch (_) {
      itens = [];
    }

    if (itens.isNotEmpty) {
      // Se falhar (sem conexão), a lista fica guardada e tenta de novo no próximo carregamento.
      await _api.post('/api/carrinho/mesclar', corpo: itens);
    }

    await prefs.remove(_chaveListaAntiga);
  }

  void _aoMudarSessao() {
    if (AuthService.instance.estaLogado) return;

    _carrinho = Carrinho.vazio;
    _carregado = false;
    _erro = null;
    _ocupados.clear();
    notifyListeners();
  }
}
