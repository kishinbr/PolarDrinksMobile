import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api_client.dart';

/// Login, cadastro e sessão do cliente.
/// O token JWT fica no armazenamento seguro do celular (Keychain no iOS, Keystore no Android).
class AuthService extends ChangeNotifier {
  AuthService._() {
    ApiClient.instance.aoExpirarSessao = () => sair(expirou: true);
  }

  static final AuthService instance = AuthService._();

  static const _chaveToken = 'polardrinks_token';
  final FlutterSecureStorage _armazenamento = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic> _dados = const {};

  /// Fica true quando a sessão acabou por expiração (para a tela de login avisar).
  bool sessaoExpirou = false;

  bool get estaLogado => _token != null;

  String get nome => _lerClaim(['unique_name', 'name', 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']) ?? '';

  String get email =>
      _lerClaim(['email', 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']) ?? '';

  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? '' : partes.first;
  }

  /// Lê o token salvo ao abrir o app. Token vencido é descartado.
  Future<void> carregar() async {
    String? salvo;

    try {
      salvo = await _armazenamento.read(key: _chaveToken);
    } catch (_) {
      salvo = null;
    }

    if (salvo == null) return;

    final dados = _decodificar(salvo);

    if (dados == null || _expirado(dados)) {
      await _apagarToken();
      return;
    }

    _aplicar(salvo, dados);
  }

  Future<void> entrar({required String email, required String senha}) async {
    final resposta = await ApiClient.instance.post(
      '/api/cliente/auth/login',
      corpo: {'email': email.trim(), 'senha': senha},
    );

    await _salvarSessao(resposta);
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmacaoSenha,
    required String telefone,
    required String cpf,
  }) async {
    final resposta = await ApiClient.instance.post(
      '/api/cliente/auth/cadastrar',
      corpo: {
        'nome': nome.trim(),
        'email': email.trim(),
        'senha': senha,
        'confirmacaoSenha': confirmacaoSenha,
        'telefone': telefone.trim(),
        'cpf': cpf.trim(),
      },
    );

    await _salvarSessao(resposta);
  }

  Future<void> sair({bool expirou = false}) async {
    if (!estaLogado) return;

    sessaoExpirou = expirou;
    _token = null;
    _dados = const {};
    ApiClient.instance.definirToken(null);
    await _apagarToken();
    notifyListeners();
  }

  // ===== internos =====

  Future<void> _salvarSessao(dynamic resposta) async {
    final token = resposta is Map ? resposta['token'] as String? : null;
    final dados = token == null ? null : _decodificar(token);

    if (token == null || dados == null) {
      throw const ApiException('Resposta inesperada do servidor ao entrar.');
    }

    try {
      await _armazenamento.write(key: _chaveToken, value: token);
    } catch (_) {
      // Sem armazenamento seguro a sessão vale só enquanto o app estiver aberto.
    }

    sessaoExpirou = false;
    _aplicar(token, dados);
  }

  void _aplicar(String token, Map<String, dynamic> dados) {
    _token = token;
    _dados = dados;
    ApiClient.instance.definirToken(token);
    notifyListeners();
  }

  Future<void> _apagarToken() async {
    try {
      await _armazenamento.delete(key: _chaveToken);
    } catch (_) {}
  }

  /// O JWT tem 3 partes separadas por ponto; a do meio é um JSON em base64 com os dados do cliente.
  Map<String, dynamic>? _decodificar(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;

      final json = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
      final dados = jsonDecode(json);
      return dados is Map<String, dynamic> ? dados : null;
    } catch (_) {
      return null;
    }
  }

  bool _expirado(Map<String, dynamic> dados) {
    final exp = dados['exp'];
    if (exp is! num) return false;

    final vence = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(vence.subtract(const Duration(minutes: 1)));
  }

  String? _lerClaim(List<String> chaves) {
    for (final chave in chaves) {
      final valor = _dados[chave];
      if (valor is String && valor.isNotEmpty) return valor;
    }
    return null;
  }
}
