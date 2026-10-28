class ItemLista {
  final int produtoID;
  final String produtoNome;
  final double precoUnitario;
  int quantidade;

  ItemLista({
    required this.produtoID,
    required this.produtoNome,
    required this.precoUnitario,
    required this.quantidade,
  });

  double get subtotal => precoUnitario * quantidade;

  Map<String, dynamic> toJson() => {
        'produtoID': produtoID,
        'produtoNome': produtoNome,
        'precoUnitario': precoUnitario,
        'quantidade': quantidade,
      };

  factory ItemLista.fromJson(Map<String, dynamic> json) {
    return ItemLista(
      produtoID: json['produtoID'],
      produtoNome: json['produtoNome'],
      precoUnitario: (json['precoUnitario'] as num).toDouble(),
      quantidade: json['quantidade'],
    );
  }
}