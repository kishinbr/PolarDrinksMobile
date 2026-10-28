import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/produto.dart';

/// Card de produto igual ao da loja web: foto em fundo cinza, selos, botão "Adicionar",
/// categoria, nome em caixa alta e preço.
class ProdutoCard extends StatefulWidget {
  final Produto produto;
  final Future<bool> Function(Produto produto) aoAdicionar;

  const ProdutoCard({super.key, required this.produto, required this.aoAdicionar});

  /// Altura do bloco de texto abaixo da foto (usada para calcular a grade).
  static const alturaInfo = 108.0;

  @override
  State<ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<ProdutoCard> {
  bool _adicionando = false;
  bool _adicionado = false;

  Future<void> _adicionar() async {
    setState(() => _adicionando = true);

    final ok = await widget.aoAdicionar(widget.produto);

    if (!mounted) return;
    setState(() {
      _adicionando = false;
      _adicionado = ok;
    });

    if (ok) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) setState(() => _adicionado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final categoria = produto.categorias.isNotEmpty ? produto.categorias.first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TemaPolar.raio),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: CoresPolar.midia),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: _FotoProduto(produto: produto),
                ),
                Positioned(top: 8, left: 8, child: _Selos(produto: produto)),
                if (produto.disponivelOnline)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _BotaoAdicionar(
                      carregando: _adicionando,
                      adicionado: _adicionado,
                      aoPressionar: _adicionando ? null : _adicionar,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          categoria.isEmpty ? ' ' : categoria.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            color: CoresPolar.textoApagado,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          produto.produtoNome.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, height: 1.35, letterSpacing: 0.3),
        ),
        const SizedBox(height: 5),
        if (produto.temPromocao)
          Text(
            formatarPreco(produto.produtoPrecoVenda),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CoresPolar.textoApagado,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          formatarPreco(produto.precoFinal),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, height: 1.2),
        ),
      ],
    );
  }
}

class _FotoProduto extends StatelessWidget {
  final Produto produto;

  const _FotoProduto({required this.produto});

  static const _semCor = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.urlImagem(produto.produtoImagemUrl);

    // "multiply" com o cinza do fundo: fotos com fundo branco se misturam ao card, como no site.
    Widget imagem = url == null
        ? _reserva()
        : Image.network(
            url,
            fit: BoxFit.contain,
            color: CoresPolar.midia,
            colorBlendMode: BlendMode.multiply,
            errorBuilder: (_, __, ___) => _reserva(),
            loadingBuilder: (context, filho, progresso) => progresso == null
                ? filho
                : const Center(
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
          );

    if (!produto.disponivelOnline) {
      imagem = Opacity(opacity: 0.55, child: ColorFiltered(colorFilter: _semCor, child: imagem));
    }

    return imagem;
  }

  Widget _reserva() => Padding(
        padding: const EdgeInsets.all(14),
        child: Image.asset('assets/images/urso.png', fit: BoxFit.contain),
      );
}

class _Selos extends StatelessWidget {
  final Produto produto;

  const _Selos({required this.produto});

  @override
  Widget build(BuildContext context) {
    final selos = <Widget>[];

    if (produto.esgotado) {
      selos.add(const _Selo('Esgotado'));
    } else if (produto.somenteNaLoja) {
      selos.add(const _Selo('Só na loja'));
    } else if (produto.ultimasUnidades) {
      selos.add(_Selo('Últimas ${produto.estoqueDisponivelOnline}', cor: CoresPolar.alerta));
    }

    if (produto.temPromocao && produto.disponivelOnline) {
      selos.add(_Selo('-${produto.produtoPromocao.round()}%', cor: CoresPolar.azul));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final selo in selos) Padding(padding: const EdgeInsets.only(bottom: 4), child: selo),
      ],
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;
  final Color cor;

  const _Selo(this.texto, {this.cor = CoresPolar.selo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
          height: 1.2,
        ),
      ),
    );
  }
}

class _BotaoAdicionar extends StatelessWidget {
  final bool carregando;
  final bool adicionado;
  final VoidCallback? aoPressionar;

  const _BotaoAdicionar({required this.carregando, required this.adicionado, required this.aoPressionar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton(
        onPressed: aoPressionar,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: EdgeInsets.zero,
          backgroundColor: adicionado ? CoresPolar.sucesso : CoresPolar.texto,
          disabledBackgroundColor: adicionado ? CoresPolar.sucesso : CoresPolar.texto,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        child: carregando
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(adicionado ? Icons.check : Icons.add_shopping_cart, size: 15),
                  const SizedBox(width: 6),
                  Text(adicionado ? 'ADICIONADO' : 'ADICIONAR'),
                ],
              ),
      ),
    );
  }
}
