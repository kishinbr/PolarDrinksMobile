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
      produtoID: json['produtoID'],
      produtoNome: json['produtoNome'],
      produtoDescricao: json['produtoDescricao'],
      produtoPrecoVenda: (json['produtoPrecoVenda'] as num).toDouble(),
      produtoPromocao: (json['produtoPromocao'] as num).toDouble(),
      produtoImagemUrl: json['produtoImagemUrl'],
      produtoQtdEstoque: json['produtoQtdEstoque'],
      estoqueDisponivelOnline: json['estoqueDisponivelOnline'],
      categorias: List<String>.from(json['categorias']),
    );
  }

  double get precoFinal {
    if (produtoPromocao > 0) {
      return produtoPrecoVenda - (produtoPrecoVenda * (produtoPromocao / 100));
    }
    return produtoPrecoVenda;
  }
}