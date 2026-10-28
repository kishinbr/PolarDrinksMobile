/// Item do carrinho como a API devolve (GET /api/carrinho).
/// O preço já vem calculado pelo servidor, com a promoção aplicada.
class ItemCarrinho {
  final int produtoID;
  final String produtoNome;
  final String? produtoImagemUrl;
  final double precoUnitario;
  final int quantidade;
  final double subtotal;

  const ItemCarrinho({
    required this.produtoID,
    required this.produtoNome,
    required this.produtoImagemUrl,
    required this.precoUnitario,
    required this.quantidade,
    required this.subtotal,
  });

  factory ItemCarrinho.fromJson(Map<String, dynamic> json) {
    final preco = (json['precoUnitario'] as num? ?? 0).toDouble();
    final quantidade = (json['quantidade'] as num? ?? 0).toInt();

    return ItemCarrinho(
      produtoID: json['produtoID'] as int,
      produtoNome: (json['produtoNome'] ?? '') as String,
      produtoImagemUrl: json['produtoImagemUrl'] as String?,
      precoUnitario: preco,
      quantidade: quantidade,
      subtotal: (json['subtotal'] as num? ?? preco * quantidade).toDouble(),
    );
  }
}

class Carrinho {
  final List<ItemCarrinho> itens;
  final double total;

  /// Produtos que saíram do carrinho porque foram desativados na loja.
  final List<String> avisosRemocao;

  const Carrinho({required this.itens, required this.total, required this.avisosRemocao});

  static const vazio = Carrinho(itens: [], total: 0, avisosRemocao: []);

  factory Carrinho.fromJson(Map<String, dynamic> json) {
    return Carrinho(
      itens: (json['itens'] as List? ?? const [])
          .map((item) => ItemCarrinho.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num? ?? 0).toDouble(),
      avisosRemocao: List<String>.from(json['avisosRemocao'] ?? const []),
    );
  }

  bool get estaVazio => itens.isEmpty;

  /// Soma das quantidades (selo do ícone do carrinho).
  int get quantidadeTotal => itens.fold(0, (soma, item) => soma + item.quantidade);

  int? quantidadeDe(int produtoId) {
    for (final item in itens) {
      if (item.produtoID == produtoId) return item.quantidade;
    }
    return null;
  }
}
