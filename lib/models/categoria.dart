class Categoria {
  final int categoriaID;
  final String categoriaNome;

  Categoria({
    required this.categoriaID,
    required this.categoriaNome,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      categoriaID: json['categoriaID'],
      categoriaNome: json['categoriaNome'],
    );
  }
}