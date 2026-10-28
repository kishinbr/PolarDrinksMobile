import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../services/catalogo_service.dart';
import '../services/lista_compras.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final CatalogoService _service = CatalogoService();

  List<Produto> _produtos = [];
  List<Categoria> _categorias = [];
  int? _categoriaSelecionada;

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final categorias = await _service.listarCategorias();
      final produtos = await _service.buscarProdutos(
        categoriaId: _categoriaSelecionada,
      );

      setState(() {
        _categorias = categorias;
        _produtos = produtos;
        _carregando = false;
      });
    } catch (erro) {
      setState(() {
        _erro = 'Não foi possível carregar o catálogo. Verifique sua conexão.';
        _carregando = false;
      });
    }
  }

  Future<void> _selecionarCategoria(int? categoriaId) async {
    setState(() {
      _categoriaSelecionada = categoriaId;
    });
    _carregarTudo();
  }

  String _tituloAppBar() {
    if (_categoriaSelecionada == null) return 'Catálogo';

    final categoria = _categorias.firstWhere(
      (c) => c.categoriaID == _categoriaSelecionada,
    );
    return 'Catálogo · ${categoria.categoriaNome}';
  }

  void _abrirSeletorCategorias() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Todos'),
                trailing: _categoriaSelecionada == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _selecionarCategoria(null);
                },
              ),
              ..._categorias.map((categoria) {
                return ListTile(
                  title: Text(categoria.categoriaNome),
                  trailing: _categoriaSelecionada == categoria.categoriaID
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _selecionarCategoria(categoria.categoriaID);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _abrirSeletorCategorias,
          ),
        ],
      ),
      body: _construirConteudo(),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(child: Text(_erro!));
    }

    if (_produtos.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: _produtos.length,
      itemBuilder: (context, index) => _cartaoProduto(_produtos[index]),
    );
  }

    Widget _cartaoProduto(Produto produto) {
    final temPromocao = produto.produtoPromocao > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: produto.produtoImagemUrl != null
                ? Image.network(
                    '${ApiConfig.baseUrl}/${produto.produtoImagemUrl}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.local_drink, size: 48),
                  )
                : const Center(child: Icon(Icons.local_drink, size: 48)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.produtoNome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (temPromocao)
                  Text(
                    'R\$ ${produto.produtoPrecoVenda.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${produto.precoFinal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _adicionarNaLista(produto),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adicionarNaLista(Produto produto) async {
    await ListaCompras.instance.adicionar(produto);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produto.produtoNome} adicionado à lista.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}