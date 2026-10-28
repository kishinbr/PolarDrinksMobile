import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';
import 'services/lista_compras.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ListaCompras.instance.carregar();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CatalogoScreen(),
    );
  }
}