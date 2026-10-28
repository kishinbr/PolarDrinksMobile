import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/pedido.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';
import '../widgets/componentes.dart';
import '../widgets/selo_status.dart';
import 'pedido_detalhe_screen.dart';

/// Aba do perfil: dados do cliente com "Sair", e os pedidos em andamento e finalizados.
class PerfilScreen extends StatelessWidget {
  /// Leva para o catálogo (quando ainda não há pedidos).
  final VoidCallback aoVerProdutos;

  const PerfilScreen({super.key, required this.aoVerProdutos});

  Future<void> _confirmarSaida(BuildContext context) async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Sair da conta?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Você vai precisar entrar de novo para fazer pedidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('CANCELAR', style: TextStyle(color: CoresPolar.textoFraco)),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('SAIR', style: TextStyle(color: CoresPolar.erro)),
          ),
        ],
      ),
    );

    if (sair == true) {
      await AuthService.instance.sair();
    }
  }

  void _abrir(BuildContext context, Pedido pedido) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PedidoDetalheScreen(pedido: pedido)));
  }

  @override
  Widget build(BuildContext context) {
    final servico = PedidoService.instance;

    return ListenableBuilder(
      listenable: servico,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: servico.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
            children: [
              const Text('MEU PERFIL', style: TextosPolar.titulo),
              const SizedBox(height: 4),
              const Text('Acompanhe seus pedidos e consulte o código de retirada.', style: TextosPolar.subtitulo),
              const SizedBox(height: 24),
              _CartaoCliente(aoSair: () => _confirmarSaida(context)),
              ..._pedidos(context, servico),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _pedidos(BuildContext context, PedidoService servico) {
    if (!servico.carregado) {
      if (servico.erro != null) {
        return [
          const SizedBox(height: 32),
          EstadoVazio(
            icone: Icons.wifi_off_rounded,
            titulo: 'Não foi possível carregar',
            texto: servico.erro!,
            acao: FilledButton(onPressed: servico.carregar, child: const Text('TENTAR NOVAMENTE')),
          ),
        ];
      }

      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (servico.pedidos.isEmpty) {
      return [
        const SizedBox(height: 32),
        EstadoVazio(
          icone: Icons.receipt_long_outlined,
          titulo: 'Nenhum pedido ainda',
          texto: 'Seus pedidos, o status de cada um e o código de retirada aparecem aqui.',
          acao: FilledButton(onPressed: aoVerProdutos, child: const Text('VER PRODUTOS')),
        ),
      ];
    }

    return [
      _secao(context, Icons.schedule, 'Em andamento', servico.emAndamento, 'Nenhum pedido em andamento.'),
      _secao(context, Icons.check_circle_outline, 'Finalizados', servico.finalizados, 'Nenhum pedido finalizado ainda.'),
    ];
  }

  Widget _secao(BuildContext context, IconData icone, String titulo, List<Pedido> lista, String vazio) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, color: CoresPolar.azul, size: 19),
              const SizedBox(width: 10),
              Text(titulo.toUpperCase(), style: TextosPolar.secao),
              if (lista.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '${lista.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: CoresPolar.textoFraco),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: CoresPolar.fundoSuave,
                borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inbox_outlined, size: 18, color: CoresPolar.textoFraco),
                  const SizedBox(width: 10),
                  Text(vazio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco)),
                ],
              ),
            )
          else
            for (final pedido in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CardPedido(pedido: pedido, aoTocar: () => _abrir(context, pedido)),
              ),
        ],
      ),
    );
  }
}

/// Dados do cliente com o botão de sair logo abaixo do nome
/// (fica sempre à vista, mesmo com muitos pedidos na lista).
class _CartaoCliente extends StatelessWidget {
  final VoidCallback aoSair;

  const _CartaoCliente({required this.aoSair});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final nome = auth.nome.isEmpty ? 'Cliente' : auth.nome;
    final inicial = nome.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CoresPolar.fundoGelo,
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: CoresPolar.azul,
            child: Text(
              inicial,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextosPolar.secao),
                if (auth.email.isNotEmpty)
                  Text(
                    auth.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: aoSair,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CoresPolar.textoSuave,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: const BorderSide(color: CoresPolar.borda, width: 1.5),
                    textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                  ),
                  icon: const Icon(Icons.logout, size: 15),
                  label: const Text('SAIR DA CONTA'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de pedido na lista (igual ao "Meus pedidos" da loja web).
class _CardPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback aoTocar;

  const _CardPedido({required this.pedido, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final quantidade = pedido.quantidadeItens;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
        side: const BorderSide(color: CoresPolar.borda, width: 1.5),
      ),
      child: InkWell(
        onTap: aoTocar,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TemaPolar.raioGrande)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PEDIDO #${pedido.pedidoID}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CoresPolar.fundoSuave,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Código ${pedido.pedidoCodigo}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: CoresPolar.textoSuave,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SeloStatus(pedido.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${formatarData(pedido.pedidoData)} · $quantidade ${quantidade == 1 ? 'item' : 'itens'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                  ),
                  const Spacer(),
                  Text(formatarPreco(pedido.pedidoValorTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20, color: CoresPolar.textoFraco),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
