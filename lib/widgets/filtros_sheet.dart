import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../core/tema.dart';
import '../models/filtros_catalogo.dart';

/// Painel "Refinar / Filtros" aberto de baixo para cima.
/// Devolve os filtros escolhidos, ou null se o usuário fechar sem aplicar.
Future<FiltrosCatalogo?> abrirFiltros(
  BuildContext context, {
  required FiltrosCatalogo atuais,
  required int Function(FiltrosCatalogo filtros) contar,
  required double? menorPreco,
  required double? maiorPreco,
}) {
  return showModalBottomSheet<FiltrosCatalogo>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FiltrosSheet(
      iniciais: atuais,
      contar: contar,
      menorPreco: menorPreco,
      maiorPreco: maiorPreco,
    ),
  );
}

class _FiltrosSheet extends StatefulWidget {
  final FiltrosCatalogo iniciais;
  final int Function(FiltrosCatalogo filtros) contar;
  final double? menorPreco;
  final double? maiorPreco;

  const _FiltrosSheet({
    required this.iniciais,
    required this.contar,
    required this.menorPreco,
    required this.maiorPreco,
  });

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late FiltrosCatalogo _filtros = widget.iniciais;
  late final TextEditingController _min = TextEditingController(text: _textoPreco(widget.iniciais.precoMin));
  late final TextEditingController _max = TextEditingController(text: _textoPreco(widget.iniciais.precoMax));

  static String _textoPreco(double? valor) =>
      valor == null ? '' : valor.toStringAsFixed(2).replaceAll('.', ',');

  static double? _lerPreco(String texto) {
    final numero = double.tryParse(texto.trim().replaceAll(',', '.'));
    return (numero == null || numero < 0) ? null : numero;
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _limpar() {
    _min.clear();
    _max.clear();
    setState(() => _filtros = const FiltrosCatalogo());
  }

  @override
  Widget build(BuildContext context) {
    final quantidade = widget.contar(_filtros);
    final teclado = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: CoresPolar.azul,
                    borderRadius: BorderRadius.circular(TemaPolar.raio),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFINAR',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.8, color: CoresPolar.azul),
                    ),
                    Text('FILTROS', style: TextosPolar.secao),
                  ],
                ),
                const Spacer(),
                if (_filtros.quantidadeAtivos > 0)
                  TextButton(onPressed: _limpar, child: const Text('LIMPAR')),
              ],
            ),
            const SizedBox(height: 8),

            _Grupo(
              titulo: 'Ordenar por',
              icone: Icons.sort,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ordem in OrdemCatalogo.values)
                    _Opcao(
                      texto: ordem.rotulo,
                      ativo: _filtros.ordem == ordem,
                      aoTocar: () => setState(() => _filtros = _filtros.copiar(ordem: ordem)),
                    ),
                ],
              ),
            ),

            _Grupo(
              titulo: 'Faixa de preço',
              icone: Icons.payments_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.menorPreco != null && widget.maiorPreco != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'De ${formatarPreco(widget.menorPreco!)} a ${formatarPreco(widget.maiorPreco!)} nesta seleção',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _CampoPreco(
                          rotulo: 'De (R\$)',
                          controller: _min,
                          dica: widget.menorPreco?.floor().toString() ?? 'Mín.',
                          aoMudar: (texto) =>
                              setState(() => _filtros = _filtros.copiar(precoMin: () => _lerPreco(texto))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CampoPreco(
                          rotulo: 'Até (R\$)',
                          controller: _max,
                          dica: widget.maiorPreco?.ceil().toString() ?? 'Máx.',
                          aoMudar: (texto) =>
                              setState(() => _filtros = _filtros.copiar(precoMax: () => _lerPreco(texto))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _Grupo(
              titulo: 'Mostrar',
              icone: Icons.filter_alt_outlined,
              ultimo: true,
              child: Column(
                children: [
                  _Marcar(
                    texto: 'Só em promoção',
                    valor: _filtros.somentePromocao,
                    aoMudar: (v) => setState(() => _filtros = _filtros.copiar(somentePromocao: v)),
                  ),
                  _Marcar(
                    texto: 'Disponível para pedir online',
                    valor: _filtros.somenteDisponivel,
                    aoMudar: (v) => setState(() => _filtros = _filtros.copiar(somenteDisponivel: v)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_filtros),
                child: Text(quantidade == 1 ? 'VER 1 PRODUTO' : 'VER $quantidade PRODUTOS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Widget child;
  final bool ultimo;

  const _Grupo({required this.titulo, required this.icone, required this.child, this.ultimo = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: ultimo ? null : const Border(bottom: BorderSide(color: Color(0x0D000000))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 13, color: CoresPolar.textoApagado),
              const SizedBox(width: 6),
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: CoresPolar.textoApagado),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  const _Opcao({required this.texto, required this.ativo, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ativo ? CoresPolar.texto : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: ativo ? CoresPolar.texto : CoresPolar.borda, width: 1.5)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            texto.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: ativo ? Colors.white : CoresPolar.textoSuave,
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoPreco extends StatelessWidget {
  final String rotulo;
  final TextEditingController controller;
  final String dica;
  final ValueChanged<String> aoMudar;

  const _CampoPreco({required this.rotulo, required this.controller, required this.dica, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo.toUpperCase(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: CoresPolar.textoApagado),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: aoMudar,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: dica,
            isDense: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}

class _Marcar extends StatelessWidget {
  final String texto;
  final bool valor;
  final ValueChanged<bool> aoMudar;

  const _Marcar({required this.texto, required this.valor, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => aoMudar(!valor),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(value: valor, onChanged: (v) => aoMudar(v ?? false)),
            Text(texto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: CoresPolar.textoSuave)),
          ],
        ),
      ),
    );
  }
}
