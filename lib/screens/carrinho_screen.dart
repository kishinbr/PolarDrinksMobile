import 'package:flutter/material.dart';

import '../core/tema.dart';
import '../widgets/componentes.dart';

/// Aba do carrinho. Na fase 2 passa a listar os itens do carrinho da API e a finalizar o pedido.
class CarrinhoScreen extends StatelessWidget {
  final VoidCallback aoVerProdutos;

  const CarrinhoScreen({super.key, required this.aoVerProdutos});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Text('MEU CARRINHO', style: TextosPolar.titulo),
        const SizedBox(height: 4),
        const Text('Revise seus produtos antes de finalizar o pedido.', style: TextosPolar.subtitulo),
        const SizedBox(height: 24),
        EstadoVazio(
          icone: Icons.shopping_bag_outlined,
          titulo: 'Em construção',
          texto: 'Na próxima etapa você vai revisar os itens, escolher Pix ou cartão e finalizar o pedido por aqui.',
          acao: FilledButton(
            onPressed: aoVerProdutos,
            child: const Text('VER PRODUTOS'),
          ),
        ),
      ],
    );
  }
}
