import 'package:intl/intl.dart';

final NumberFormat _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);

/// 1234.5 -> "R$ 1.234,50"
String formatarPreco(num valor) => _moeda.format(valor);

/// Remove acentos e deixa em minúsculas, para buscas como "agua" encontrarem "Água".
String normalizarTexto(String? texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  final minusculo = (texto ?? '').toLowerCase().trim();
  final buffer = StringBuffer();

  for (final letra in minusculo.split('')) {
    final indice = comAcento.indexOf(letra);
    buffer.write(indice >= 0 ? semAcento[indice] : letra);
  }

  return buffer.toString();
}

/// 28/10/2026
String formatarData(DateTime data) => DateFormat('dd/MM/yyyy', 'pt_BR').format(data);

/// 28/10/2026 às 12:15
String formatarDataHora(DateTime data) => DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(data);
