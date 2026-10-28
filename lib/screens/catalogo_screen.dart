import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/tema.dart';
import '../models/categoria.dart';
import '../models/filtros_catalogo.dart';
import '../models/produto.dart';
import '../services/catalogo_service.dart';
import '../services/carrinho_service.dart';
import '../widgets/componentes.dart';
import '../widgets/filtros_sheet.dart';
import '../widgets/produto_card.dart';

/// Catálogo da loja: menu de categorias, busca e produtos com filtros.
///
/// O catálogo é carregado uma vez e filtrado no próprio app.
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  static const _alturaMenu = 46.0;

  final CatalogoService _service = CatalogoService();
  final ScrollController _rolagem = ScrollController();
  final TextEditingController _busca = TextEditingController();

  List<Produto> _todos = [];
  List<Categoria> _categorias = [];

  int? _categoriaId;
  String _termo = '';
  FiltrosCatalogo _filtros = const FiltrosCatalogo();

  bool _carregando = true;
  String? _erro;
  Timer? _atrasoBusca;

  @override
  void initState() {
    super.initState();
    _carregar();
    CatalogoService.estoqueAlterado.addListener(_carregar);
  }

  @override
  void dispose() {
    CatalogoService.estoqueAlterado.removeListener(_carregar);
    _atrasoBusca?.cancel();
    _rolagem.dispose();
    _busca.dispose();
    super.dispose();
  }

  // ===== dados =====

  Future<void> _carregar() async {
    setState(() {
      _carregando = _todos.isEmpty;
      _erro = null;
    });

    try {
      final resultados = await Future.wait([
        _service.listarCategorias(),
        _service.buscarProdutos(),
      ]);

      if (!mounted) return;
      setState(() {
        _categorias = resultados[0] as List<Categoria>;
        _todos = resultados[1] as List<Produto>;
        _carregando = false;

        // A categoria escolhida pode ter sido desativada entre um carregamento e outro.
        if (_categoriaId != null && !_categorias.any((c) => c.categoriaID == _categoriaId)) {
          _categoriaId = null;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      // Se já havia produtos na tela (ex.: puxar para atualizar), mantém e só avisa.
      if (_todos.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
        setState(() => _carregando = false);
        return;
      }

      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  String? get _categoriaNome =>
      _categorias.where((c) => c.categoriaID == _categoriaId).firstOrNull?.categoriaNome;

  /// Categoria + busca, sem os filtros do painel (base para a faixa de preço).
  List<Produto> get _escopo =>
      const FiltrosCatalogo().aplicar(_todos, categoriaNome: _categoriaNome, termo: _termo);

  List<Produto> get _visiveis => _filtros.aplicar(_todos, categoriaNome: _categoriaNome, termo: _termo);

  /// Sem categoria e sem busca: mostra "Nossos produtos" (com categoria ou busca, o título muda).
  bool get _modoVitrine => _categoriaId == null && _termo.isEmpty;

  // ===== ações =====

  void _selecionarCategoria(int? id) {
    _atrasoBusca?.cancel();
    FocusScope.of(context).unfocus();

    setState(() {
      _categoriaId = id;
      _termo = '';
      _busca.clear();
      _filtros = _filtros.copiar(precoMin: () => null, precoMax: () => null);
    });

    _rolarParaTopo();
  }

  void _aoDigitar(String texto) {
    _atrasoBusca?.cancel();
    _atrasoBusca = Timer(const Duration(milliseconds: 300), () => _buscar(texto));
    setState(() {}); // atualiza o botão de limpar
  }

  void _buscar(String texto) {
    _atrasoBusca?.cancel();
    if (!mounted) return;
    setState(() => _termo = texto.trim());
  }

  void _limparBusca() {
    _busca.clear();
    _buscar('');
  }

  void _verTodos() {
    _busca.clear();
    _selecionarCategoria(null);
  }

  Future<void> _abrirFiltros() async {
    final precos = _escopo.map((p) => p.precoFinal).toList()..sort();

    final escolhidos = await abrirFiltros(
      context,
      atuais: _filtros,
      contar: (f) => f.aplicar(_todos, categoriaNome: _categoriaNome, termo: _termo).length,
      menorPreco: precos.isEmpty ? null : precos.first,
      maiorPreco: precos.isEmpty ? null : precos.last,
    );

    if (escolhidos != null && mounted) {
      setState(() => _filtros = escolhidos);
    }
  }

  void _rolarParaTopo() {
    if (_rolagem.hasClients) {
      _rolagem.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  /// Adiciona 1 unidade ao carrinho da API. O servidor confere o estoque e,
  /// se não der, devolve a mensagem (ex.: "Apenas 2 unidade(s) de ... disponíveis.").
  Future<bool> _adicionar(Produto produto) async {
    try {
      await CarrinhoService.instance.adicionar(produto.produtoID);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
      return false;
    }

    // Sem aviso de sucesso: o próprio botão vira "Adicionado" e o selo do carrinho atualiza.
    return true;
  }

  // ===== tela =====

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregar,
      edgeOffset: _alturaMenu,
      child: CustomScrollView(
        controller: _rolagem,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _MenuCategorias(
              altura: _alturaMenu,
              categorias: _categorias,
              selecionada: _termo.isEmpty ? _categoriaId : -1,
              aoSelecionar: _selecionarCategoria,
            ),
          ),
          SliverToBoxAdapter(child: _campoBusca()),
          ..._conteudo(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _campoBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _busca,
        onChanged: _aoDigitar,
        onSubmitted: _buscar,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'O que você procura?',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _busca.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _limparBusca,
                ),
        ),
      ),
    );
  }

  List<Widget> _conteudo() {
    if (_carregando) {
      return [_gradeEsqueleto()];
    }

    if (_erro != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: EstadoVazio(
                icone: Icons.wifi_off_rounded,
                titulo: 'Sem conexão',
                texto: _erro!,
                acao: FilledButton(onPressed: _carregar, child: const Text('TENTAR NOVAMENTE')),
              ),
            ),
          ),
        ),
      ];
    }

    final visiveis = _visiveis;

    return [
      SliverToBoxAdapter(child: _cabecalhoProdutos(visiveis.length)),
      if (visiveis.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EstadoVazio(
              icone: Icons.search_off,
              titulo: 'Nenhum produto encontrado',
              texto: 'Ajuste os filtros ou escolha outra categoria.',
              acao: _filtros.quantidadeAtivos > 0 || !_modoVitrine
                  ? OutlinedButton(
                      onPressed: () {
                        setState(() => _filtros = const FiltrosCatalogo());
                        _verTodos();
                      },
                      child: const Text('LIMPAR FILTROS'),
                    )
                  : null,
            ),
          ),
        )
      else
        _gradeProdutos(visiveis),
    ];
  }

  Widget _cabecalhoProdutos(int quantidade) {
    final textoQuantidade = quantidade == 1 ? '1 produto' : '$quantidade produtos';

    final String titulo;
    if (_termo.isNotEmpty) {
      titulo = 'Resultados para "$_termo"';
    } else if (_categoriaNome != null) {
      titulo = _categoriaNome!;
    } else {
      titulo = 'Nossos produtos';
    }

    final subtitulo = (_modoVitrine && _filtros.quantidadeAtivos == 0)
        ? 'Preços com promoção já aplicada.'
        : textoQuantidade;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_modoVitrine)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _verTodos,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 15, color: CoresPolar.textoFraco),
                      SizedBox(width: 8),
                      Text(
                        'VER TODOS OS PRODUTOS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: CoresPolar.textoFraco),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Text(titulo.toUpperCase(), style: TextosPolar.titulo),
          const SizedBox(height: 4),
          Text(subtitulo, style: TextosPolar.subtitulo),
          const SizedBox(height: 18),
          _BotaoFiltros(
            resumo: textoQuantidade,
            ativos: _filtros.quantidadeAtivos,
            aoTocar: _abrirFiltros,
          ),
        ],
      ),
    );
  }

  /// Número de colunas conforme a largura (2 no celular, mais em tablet).
  int _colunas(double largura) {
    if (largura >= 900) return 4;
    if (largura >= 600) return 3;
    return 2;
  }

  Widget _gradeProdutos(List<Produto> produtos) {
    final escala = MediaQuery.textScalerOf(context).scale(14) / 14;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverLayoutBuilder(
        builder: (context, restricoes) {
          const espaco = 12.0;
          final colunas = _colunas(restricoes.crossAxisExtent);
          final largura = (restricoes.crossAxisExtent - espaco * (colunas - 1)) / colunas;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
              crossAxisSpacing: espaco,
              mainAxisSpacing: 22,
              mainAxisExtent: largura + ProdutoCard.alturaInfo * escala,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => ProdutoCard(
                key: ValueKey(produtos[i].produtoID),
                produto: produtos[i],
                aoAdicionar: _adicionar,
              ),
              childCount: produtos.length,
            ),
          );
        },
      ),
    );
  }

  Widget _gradeEsqueleto() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      sliver: SliverLayoutBuilder(
        builder: (context, restricoes) {
          final colunas = _colunas(restricoes.crossAxisExtent);
          final largura = (restricoes.crossAxisExtent - 12.0 * (colunas - 1)) / colunas;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
              crossAxisSpacing: 12,
              mainAxisSpacing: 22,
              mainAxisExtent: largura + 60,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => const _CardEsqueleto(),
              childCount: colunas * 3,
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// Peças da tela
// =====================================================================

/// Menu horizontal de categorias fixo no topo (como o menu abaixo do logo no site).
class _MenuCategorias extends SliverPersistentHeaderDelegate {
  final double altura;
  final List<Categoria> categorias;
  final int? selecionada;
  final ValueChanged<int?> aoSelecionar;

  _MenuCategorias({
    required this.altura,
    required this.categorias,
    required this.selecionada,
    required this.aoSelecionar,
  });

  @override
  double get minExtent => altura;

  @override
  double get maxExtent => altura;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final itens = <(int?, String)>[
      (null, 'Início'),
      for (final c in categorias) (c.categoriaID, c.categoriaNome),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CoresPolar.borda)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemCount: itens.length,
        itemBuilder: (context, i) {
          final (id, nome) = itens[i];
          final ativo = id == selecionada;

          return InkWell(
            onTap: () => aoSelecionar(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    nome.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: ativo ? CoresPolar.texto : const Color(0x73000000),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: ativo ? 28 : 0,
                    decoration: BoxDecoration(
                      color: CoresPolar.azul,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MenuCategorias antigo) =>
      antigo.selecionada != selecionada || antigo.categorias != categorias || antigo.altura != altura;
}

/// Botão no lugar do painel lateral do site: "Refinar / Filtros".
class _BotaoFiltros extends StatelessWidget {
  final String resumo;
  final int ativos;
  final VoidCallback aoTocar;

  const _BotaoFiltros({required this.resumo, required this.ativos, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
            border: Border.all(color: const Color(0x0F000000)),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 30, offset: Offset(0, 8), spreadRadius: -12),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CoresPolar.azul,
                  borderRadius: BorderRadius.circular(TemaPolar.raio),
                  boxShadow: [
                    BoxShadow(color: CoresPolar.azul.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REFINAR',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.8, color: CoresPolar.azul),
                    ),
                    const Text('FILTROS', style: TextosPolar.secao),
                    Text(
                      resumo,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                    ),
                  ],
                ),
              ),
              if (ativos > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: CoresPolar.azul, borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    '$ativos',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              const Icon(Icons.keyboard_arrow_up_rounded, color: CoresPolar.textoFraco),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardEsqueleto extends StatelessWidget {
  const _CardEsqueleto();

  @override
  Widget build(BuildContext context) {
    Widget barra(double largura) => Container(
          height: 11,
          width: largura,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(color: CoresPolar.midia, borderRadius: BorderRadius.circular(6)),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(color: CoresPolar.midia, borderRadius: BorderRadius.circular(TemaPolar.raio)),
          ),
        ),
        barra(double.infinity),
        barra(60),
      ],
    );
  }
}
