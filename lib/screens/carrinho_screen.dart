import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/api_client.dart';
import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/carrinho.dart';
import '../services/carrinho_service.dart';
import '../widgets/componentes.dart';

/// Aba do carrinho: itens com quantidade, remover, total e esvaziar.
/// Tudo vem da API, igual à página "Meu carrinho" da loja web.
class CarrinhoScreen extends StatelessWidget {
  final VoidCallback aoVerProdutos;

  const CarrinhoScreen({super.key, required this.aoVerProdutos});

  @override
  Widget build(BuildContext context) {
    final servico = CarrinhoService.instance;

    return ListenableBuilder(
      listenable: servico,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: servico.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
            children: [
              const Text('MEU CARRINHO', style: TextosPolar.titulo),
              const SizedBox(height: 4),
              const Text('Revise seus produtos antes de finalizar o pedido.', style: TextosPolar.subtitulo),
              const SizedBox(height: 24),
              ..._conteudo(context, servico),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _conteudo(BuildContext context, CarrinhoService servico) {
    // Primeira carga ainda em andamento
    if (!servico.carregado && servico.erro == null) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    // Não conseguiu carregar e não tem nada para mostrar
    if (!servico.carregado && servico.erro != null) {
      return [
        EstadoVazio(
          icone: Icons.wifi_off_rounded,
          titulo: 'Não foi possível carregar',
          texto: servico.erro!,
          acao: FilledButton(onPressed: servico.carregar, child: const Text('TENTAR NOVAMENTE')),
        ),
      ];
    }

    final carrinho = servico.carrinho;

    return [
      if (carrinho.avisosRemocao.isNotEmpty) ...[
        Aviso(carrinho.avisosRemocao.join('\n'), tipo: TipoAviso.alerta),
        const SizedBox(height: 16),
      ],
      if (carrinho.estaVazio)
        EstadoVazio(
          icone: Icons.shopping_bag_outlined,
          titulo: 'Seu carrinho está vazio',
          texto: 'Adicione alguns produtos para começar seu pedido.',
          acao: FilledButton(
            onPressed: aoVerProdutos,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('VER PRODUTOS'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)],
            ),
          ),
        )
      else ...[
        const Divider(height: 1),
        for (final item in carrinho.itens)
          _LinhaItem(
            key: ValueKey(item.produtoID),
            item: item,
            ocupado: servico.estaOcupado(item.produtoID),
          ),
        const SizedBox(height: 28),
        _Resumo(carrinho: carrinho, aoContinuar: aoVerProdutos),
      ],
    ];
  }
}

/// Executa uma ação do carrinho e mostra o erro da API, se houver.
Future<void> _executar(BuildContext context, Future<void> Function() acao) async {
  try {
    await acao();
  } on ApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.mensagem)));
  }
}

class _LinhaItem extends StatelessWidget {
  final ItemCarrinho item;
  final bool ocupado;

  const _LinhaItem({super.key, required this.item, required this.ocupado});

  @override
  Widget build(BuildContext context) {
    final servico = CarrinhoService.instance;
    final url = ApiConfig.urlImagem(item.produtoImagemUrl);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CoresPolar.borda)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CoresPolar.midia,
              borderRadius: BorderRadius.circular(TemaPolar.raio),
            ),
            child: url == null
                ? Image.asset('assets/images/urso.png')
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    color: CoresPolar.midia,
                    colorBlendMode: BlendMode.multiply,
                    errorBuilder: (_, __, ___) => Image.asset('assets/images/urso.png'),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.produtoNome.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, height: 1.35, letterSpacing: 0.2),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${formatarPreco(item.precoUnitario)} cada',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatarPreco(item.subtotal),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ControleQuantidade(
                      quantidade: item.quantidade,
                      ocupado: ocupado,
                      aoDiminuir: item.quantidade > 1
                          ? () => _executar(context, () => servico.alterarQuantidade(item.produtoID, item.quantidade - 1))
                          : null,
                      aoAumentar: () =>
                          _executar(context, () => servico.alterarQuantidade(item.produtoID, item.quantidade + 1)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: ocupado ? null : () => _executar(context, () => servico.remover(item.produtoID)),
                      style: TextButton.styleFrom(
                        foregroundColor: CoresPolar.textoFraco,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text(
                        'Remover',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControleQuantidade extends StatelessWidget {
  final int quantidade;
  final bool ocupado;
  final VoidCallback? aoDiminuir;
  final VoidCallback aoAumentar;

  const _ControleQuantidade({
    required this.quantidade,
    required this.ocupado,
    required this.aoDiminuir,
    required this.aoAumentar,
  });

  @override
  Widget build(BuildContext context) {
    Widget botao(IconData icone, VoidCallback? acao, String dica) => SizedBox(
          width: 38,
          height: 38,
          child: IconButton(
            onPressed: ocupado ? null : acao,
            tooltip: dica,
            padding: EdgeInsets.zero,
            iconSize: 18,
            color: CoresPolar.texto,
            disabledColor: const Color(0xFFC3C8CF),
            icon: Icon(icone),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CoresPolar.borda, width: 1.5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          botao(Icons.remove, aoDiminuir, 'Diminuir'),
          SizedBox(
            width: 30,
            child: Center(
              child: ocupado
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('$quantidade', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
          botao(Icons.add, aoAumentar, 'Aumentar'),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final Carrinho carrinho;
  final VoidCallback aoContinuar;

  const _Resumo({required this.carrinho, required this.aoContinuar});

  Future<void> _confirmarEsvaziar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Esvaziar carrinho?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Todos os itens serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('CANCELAR', style: TextStyle(color: CoresPolar.textoFraco)),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('ESVAZIAR', style: TextStyle(color: CoresPolar.erro)),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await _executar(context, CarrinhoService.instance.limpar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantidade = carrinho.quantidadeTotal;
    final limpando = CarrinhoService.instance.limpando;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: CoresPolar.fundoGelo,
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('RESUMO DO PEDIDO', style: TextosPolar.secao),
              const Spacer(),
              Text(
                quantidade == 1 ? '1 item' : '$quantidade itens',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: CoresPolar.textoFraco),
              ),
              const Spacer(),
              Text(
                formatarPreco(carrinho.total),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Aviso(
            'Na próxima etapa você escolhe Pix ou cartão e finaliza o pedido por aqui.',
            tipo: TipoAviso.info,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: aoContinuar,
            child: const Text('CONTINUAR COMPRANDO'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: limpando ? null : () => _confirmarEsvaziar(context),
            style: TextButton.styleFrom(foregroundColor: CoresPolar.textoFraco, minimumSize: const Size(0, 44)),
            icon: limpando
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline, size: 18),
            label: const Text('ESVAZIAR CARRINHO'),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_outlined, size: 14, color: CoresPolar.textoFraco),
              SizedBox(width: 6),
              Text(
                'Retirada na loja com código de 4 dígitos.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CoresPolar.textoFraco),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
