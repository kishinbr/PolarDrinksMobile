/// Endereço da API do PolarDrinks, publicada no Azure Container Apps.
class ApiConfig {
  static const String baseUrl =
      'https://polardrinks-app.wittybeach-73617cd8.centralus.azurecontainerapps.io';

  /// As imagens dos produtos ficam no Azure Blob Storage e a API já devolve
  /// o link completo (https://...). Caminhos relativos continuam funcionando.
  static String? urlImagem(String? caminho) {
    if (caminho == null || caminho.isEmpty) return null;
    if (caminho.startsWith('http')) return caminho;
    return '$baseUrl/$caminho';
  }

  /// Tempo máximo de espera por uma resposta da API.
  /// É alto de propósito: quando ninguém usa o sistema, o servidor e o banco
  /// "dormem" para economizar, e o primeiro acesso leva alguns segundos para acordá-los.
  static const Duration tempoLimite = Duration(seconds: 60);
}