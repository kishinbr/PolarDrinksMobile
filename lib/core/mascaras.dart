import 'package:flutter/services.dart';

/// Máscaras usadas nos campos do cadastro do cliente.
/// Aceitam só números e formatam enquanto o usuário digita.

String _digitos(String texto) => texto.replaceAll(RegExp(r'[^0-9]'), '');

/// Pega os dígitos da edição. Se o usuário apagou um separador (ponto, traço,
/// parêntese), apaga também o dígito anterior, para o campo não "travar".
String _digitosDaEdicao(TextEditingValue oldValue, TextEditingValue newValue, int maximo) {
  var digitos = _digitos(newValue.text);
  final apagou = newValue.text.length < oldValue.text.length;

  if (apagou && digitos.isNotEmpty && digitos.length == _digitos(oldValue.text).length) {
    digitos = digitos.substring(0, digitos.length - 1);
  }

  return digitos.length > maximo ? digitos.substring(0, maximo) : digitos;
}

TextEditingValue _valor(String texto) =>
    TextEditingValue(text: texto, selection: TextSelection.collapsed(offset: texto.length));

/// CPF: 000.000.000-00
class MascaraCpf extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final d = _digitosDaEdicao(oldValue, newValue, 11);
    final texto = StringBuffer();

    for (var i = 0; i < d.length; i++) {
      if (i == 3 || i == 6) texto.write('.');
      if (i == 9) texto.write('-');
      texto.write(d[i]);
    }

    return _valor(texto.toString());
  }
}

/// Telefone: (00) 0000-0000 (fixo) ou (00) 00000-0000 (celular)
class MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final d = _digitosDaEdicao(oldValue, newValue, 11);
    final posicaoTraco = d.length > 10 ? 7 : 6;
    final texto = StringBuffer();

    for (var i = 0; i < d.length; i++) {
      if (i == 0) texto.write('(');
      if (i == 2) texto.write(') ');
      if (i == posicaoTraco) texto.write('-');
      texto.write(d[i]);
    }

    return _valor(texto.toString());
  }
}
