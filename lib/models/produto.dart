class Produto {
  final int produtoID;
  final String produtoNome;
  final String? produtoDescricao;
  final double produtoPrecoVenda;
  final double produtoPromocao;
  final String? produtoImagemUrl;
  final int produtoQtdEstoque;
  final int estoqueDisponivelOnline;
  final List<String> categorias;

  Produto({
    required this.produtoID,
    required this.produtoNome,
    this.produtoDescricao,
    required this.produtoPrecoVenda,
    required this.produtoPromocao,
    this.produtoImagemUrl,
    required this.produtoQtdEstoque,
    required this.estoqueDisponivelOnline,
    required this.categorias,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      produtoID: json['produtoID'] as int,
      produtoNome: (json['produtoNome'] ?? '') as String,
      produtoDescricao: json['produtoDescricao'] as String?,
      produtoPrecoVenda: (json['produtoPrecoVenda'] as num? ?? 0).toDouble(),
      produtoPromocao: (json['produtoPromocao'] as num? ?? 0).toDouble(),
      produtoImagemUrl: json['produtoImagemUrl'] as String?,
      produtoQtdEstoque: (json['produtoQtdEstoque'] as num? ?? 0).toInt(),
      estoqueDisponivelOnline: (json['estoqueDisponivelOnline'] as num? ?? 0).toInt(),
      categorias: List<String>.from(json['categorias'] ?? const []),
    );
  }

  bool get temPromocao => produtoPromocao > 0 && produtoPromocao <= 100;

  /// Preço com promoção, com o mesmo arredondamento do servidor (2 casas).
  /// É só para exibir: o valor cobrado é sempre o calculado pela API.
  double get precoFinal {
    final base = produtoPrecoVenda < 0 ? 0.0 : produtoPrecoVenda;
    final valor = temPromocao ? base - base * (produtoPromocao / 100) : base;
    return (valor * 100).round() / 100;
  }

  bool get esgotado => produtoQtdEstoque <= 0;

  /// Tem na loja física, mas a parte reservada para o online acabou.
  bool get somenteNaLoja => !esgotado && estoqueDisponivelOnline <= 0;

  bool get disponivelOnline => !esgotado && !somenteNaLoja;

  /// Poucas unidades para pedir online (mostra o selo "Últimas N").
  bool get ultimasUnidades => disponivelOnline && estoqueDisponivelOnline <= 3;
}
