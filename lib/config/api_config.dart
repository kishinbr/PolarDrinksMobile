import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Endereço da API do PolarDrinks.
///
/// - Emulador Android: http://10.0.2.2:5153 (o "localhost" do computador visto de dentro do emulador)
/// - Simulador iOS / desktop: http://localhost:5153
/// - Outro servidor (ex.: Azure): passe na hora de rodar ou compilar, sem mexer no código:
///     flutter run --dart-define=API_URL=https://seu-app.azurewebsites.net
class ApiConfig {
  static const String _urlDefinida = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5153';
    return 'http://localhost:5153';
  }

  /// A API devolve o caminho da imagem relativo (ex.: "uploads/produtos/1.webp").
  static String? urlImagem(String? caminho) {
    if (caminho == null || caminho.isEmpty) return null;
    if (caminho.startsWith('http')) return caminho;
    return '$baseUrl/$caminho';
  }

  static const Duration tempoLimite = Duration(seconds: 15);
}
