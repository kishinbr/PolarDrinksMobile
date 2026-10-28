import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_lista.dart';
import '../models/produto.dart';

class ListaCompras extends ChangeNotifier {
  ListaCompras._interno();
  static final ListaCompras instance = ListaCompras._interno();

  static const _chaveStorage = 'lista_compras';

  final List<ItemLista> _itens = [];

  List<ItemLista> get itens => List.unmodifiable(_itens);

  double get total => _itens.fold(0, (soma, item) => soma + item.subtotal);

  bool get estaVazia => _itens.isEmpty;

  ItemLista? _buscarItem(int produtoID) {
    for (final item in _itens) {
      if (item.produtoID == produtoID) return item;
    }
    return null;
  }

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveStorage);

    if (dados != null) {
      final List<dynamic> lista = jsonDecode(dados);
      _itens.clear();
      _itens.addAll(lista.map((item) => ItemLista.fromJson(item)));
      notifyListeners();
    }
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = jsonEncode(_itens.map((item) => item.toJson()).toList());
    await prefs.setString(_chaveStorage, dados);
  }

  Future<void> adicionar(Produto produto) async {
    final existente = _buscarItem(produto.produtoID);

    if (existente != null) {
      existente.quantidade++;
    } else {
      _itens.add(ItemLista(
        produtoID: produto.produtoID,
        produtoNome: produto.produtoNome,
        precoUnitario: produto.precoFinal,
        quantidade: 1,
      ));
    }

    notifyListeners();
    await _salvar();
  }

  Future<void> alterarQuantidade(int produtoID, int delta) async {
    final item = _buscarItem(produtoID);
    if (item == null) return;

    item.quantidade += delta;

    if (item.quantidade <= 0) {
      _itens.remove(item);
    }

    notifyListeners();
    await _salvar();
  }

  Future<void> remover(int produtoID) async {
    _itens.removeWhere((item) => item.produtoID == produtoID);
    notifyListeners();
    await _salvar();
  }

  Future<void> limpar() async {
    _itens.clear();
    notifyListeners();
    await _salvar();
  }
}