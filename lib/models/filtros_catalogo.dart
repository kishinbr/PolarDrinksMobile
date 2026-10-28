import '../core/formatadores.dart';
import 'produto.dart';

enum OrdemCatalogo {
  destaques('Destaques'),
  menorPreco('Menor preço'),
  maiorPreco('Maior preço'),
  desconto('Maior desconto'),
  nome('Nome (A–Z)');

  final String rotulo;
  const OrdemCatalogo(this.rotulo);
}

/// Filtros do painel "Refinar" (os mesmos da loja web). Categoria e busca ficam na tela.
class FiltrosCatalogo {
  final OrdemCatalogo ordem;
  final double? precoMin;
  final double? precoMax;
  final bool somentePromocao;
  final bool somenteDisponivel;

  const FiltrosCatalogo({
    this.ordem = OrdemCatalogo.destaques,
    this.precoMin,
    this.precoMax,
    this.somentePromocao = false,
    this.somenteDisponivel = false,
  });

  /// Quantos filtros estão ligados (para o selo do botão "Filtros").
  int get quantidadeAtivos =>
      (precoMin != null ? 1 : 0) +
      (precoMax != null ? 1 : 0) +
      (somentePromocao ? 1 : 0) +
      (somenteDisponivel ? 1 : 0) +
      (ordem != OrdemCatalogo.destaques ? 1 : 0);

  FiltrosCatalogo copiar({
    OrdemCatalogo? ordem,
    double? Function()? precoMin,
    double? Function()? precoMax,
    bool? somentePromocao,
    bool? somenteDisponivel,
  }) {
    return FiltrosCatalogo(
      ordem: ordem ?? this.ordem,
      precoMin: precoMin != null ? precoMin() : this.precoMin,
      precoMax: precoMax != null ? precoMax() : this.precoMax,
      somentePromocao: somentePromocao ?? this.somentePromocao,
      somenteDisponivel: somenteDisponivel ?? this.somenteDisponivel,
    );
  }

  /// Aplica categoria, busca e estes filtros sobre o catálogo carregado.
  List<Produto> aplicar(List<Produto> produtos, {String? categoriaNome, String? termo}) {
    final busca = normalizarTexto(termo);

    final lista = produtos.where((p) {
      if (categoriaNome != null && !p.categorias.contains(categoriaNome)) return false;
      if (busca.isNotEmpty && !normalizarTexto(p.produtoNome).contains(busca)) return false;

      final preco = p.precoFinal;
      if (precoMin != null && preco < precoMin!) return false;
      if (precoMax != null && preco > precoMax!) return false;
      if (somentePromocao && !p.temPromocao) return false;
      if (somenteDisponivel && !p.disponivelOnline) return false;

      return true;
    }).toList();

    switch (ordem) {
      case OrdemCatalogo.menorPreco:
        lista.sort((a, b) => a.precoFinal.compareTo(b.precoFinal));
      case OrdemCatalogo.maiorPreco:
        lista.sort((a, b) => b.precoFinal.compareTo(a.precoFinal));
      case OrdemCatalogo.desconto:
        lista.sort((a, b) => b.produtoPromocao.compareTo(a.produtoPromocao));
      case OrdemCatalogo.nome:
        lista.sort((a, b) => normalizarTexto(a.produtoNome).compareTo(normalizarTexto(b.produtoNome)));
      case OrdemCatalogo.destaques:
        // Disponíveis primeiro, mantendo a ordem original entre eles.
        final disponiveis = lista.where((p) => p.disponivelOnline).toList();
        final indisponiveis = lista.where((p) => !p.disponivelOnline).toList();
        return [...disponiveis, ...indisponiveis];
    }

    return lista;
  }
}
