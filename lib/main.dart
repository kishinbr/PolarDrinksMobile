import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/tema.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/lista_compras.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initializeDateFormatting('pt_BR'),
    AuthService.instance.carregar(),
    ListaCompras.instance.carregar(),
  ]);

  runApp(const PolarDrinksApp());
}

class PolarDrinksApp extends StatefulWidget {
  const PolarDrinksApp({super.key});

  @override
  State<PolarDrinksApp> createState() => _PolarDrinksAppState();
}

class _PolarDrinksAppState extends State<PolarDrinksApp> {
  final _navegador = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_aoMudarSessao);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_aoMudarSessao);
    super.dispose();
  }

  /// Ao entrar ou sair, fecha qualquer tela aberta por cima (cadastro, detalhes...)
  /// para a raiz trocar entre login e loja.
  void _aoMudarSessao() {
    _navegador.currentState?.popUntil((rota) => rota.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polar Drinks',
      debugShowCheckedModeBanner: false,
      theme: TemaPolar.tema,
      navigatorKey: _navegador,
      home: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) =>
            AuthService.instance.estaLogado ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
