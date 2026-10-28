import 'package:flutter/material.dart';

import '../services/carrinho_service.dart';
import '../widgets/cabecalho_loja.dart';
import 'carrinho_screen.dart';
import 'catalogo_screen.dart';
import 'perfil_screen.dart';

/// Tela principal depois do login: cabeçalho da loja + três abas (Início, Carrinho, Perfil).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _abaCarrinho = 1;

  int _aba = 0;

  @override
  void initState() {
    super.initState();
    // Carrega o carrinho do servidor ao entrar (para o selo do ícone já mostrar a quantidade).
    // Depois do primeiro quadro, para não notificar telas no meio da montagem.
    WidgetsBinding.instance.addPostFrameCallback((_) => CarrinhoService.instance.carregar());
  }

  void _irPara(int aba) {
    // Ao abrir o carrinho, busca de novo: ele pode ter mudado pelo site.
    if (aba == _abaCarrinho && aba != _aba) {
      CarrinhoService.instance.carregar();
    }

    setState(() => _aba = aba);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoLoja(),
          Expanded(
            // IndexedStack mantém cada aba viva: ao voltar ao catálogo, a rolagem e os filtros continuam.
            child: IndexedStack(
              index: _aba,
              children: [
                CatalogoScreen(aoVerCarrinho: () => _irPara(_abaCarrinho)),
                CarrinhoScreen(aoVerProdutos: () => _irPara(0)),
                const PerfilScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: ListenableBuilder(
          listenable: CarrinhoService.instance,
          builder: (context, _) {
            final quantidade = CarrinhoService.instance.quantidadeTotal;
            final rotulo = quantidade > 99 ? '99+' : '$quantidade';

            return NavigationBar(
              selectedIndex: _aba,
              onDestinationSelected: _irPara,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: quantidade > 0,
                    label: Text(rotulo),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: quantidade > 0,
                    label: Text(rotulo),
                    child: const Icon(Icons.shopping_bag),
                  ),
                  label: 'Carrinho',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
