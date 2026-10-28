import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/carrinho_service.dart';
import '../services/pedido_service.dart';
import '../widgets/cabecalho_loja.dart';
import 'carrinho_screen.dart';
import 'catalogo_screen.dart';
import 'pedido_confirmado_screen.dart';
import 'perfil_screen.dart';

/// Tela principal depois do login: cabeçalho da loja + três abas (Início, Carrinho, Perfil).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _abaInicio = 0;
  static const _abaCarrinho = 1;
  static const _abaPerfil = 2;

  int _aba = 0;

  @override
  void initState() {
    super.initState();
    // Carrega o carrinho do servidor ao entrar (para o selo do ícone já mostrar a quantidade).
    // Depois do primeiro quadro, para não notificar telas no meio da montagem.
    WidgetsBinding.instance.addPostFrameCallback((_) => CarrinhoService.instance.carregar());
  }

  void _irPara(int aba) {
    // Ao abrir o carrinho ou o perfil, busca de novo: pode ter mudado pelo site ou na loja.
    if (aba != _aba) {
      if (aba == _abaCarrinho) {
        CarrinhoService.instance.carregar();
      } else if (aba == _abaPerfil) {
        PedidoService.instance.carregar();
      }
    }

    setState(() => _aba = aba);
  }

  /// Depois do checkout: abre a confirmação com o código e, ao fechar, vai para onde o cliente escolheu.
  Future<void> _mostrarPedido(Pedido pedido) async {
    final destino = await Navigator.of(context).push<DestinoAposPedido>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PedidoConfirmadoScreen(pedido: pedido),
      ),
    );

    if (!mounted) return;
    _irPara(destino == DestinoAposPedido.pedidos ? _abaPerfil : _abaInicio);
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
                const CatalogoScreen(),
                CarrinhoScreen(aoVerProdutos: () => _irPara(_abaInicio), aoFinalizar: _mostrarPedido),
                PerfilScreen(aoVerProdutos: () => _irPara(_abaInicio)),
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
