import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/tema.dart';
import 'borda_tracejada.dart';

/// Caixa tracejada com o código de retirada em destaque.
/// Tocar copia o código; a confirmação aparece na própria caixa, sem mensagem flutuante.
class CaixaCodigo extends StatefulWidget {
  final String codigo;

  const CaixaCodigo({super.key, required this.codigo});

  @override
  State<CaixaCodigo> createState() => _CaixaCodigoState();
}

class _CaixaCodigoState extends State<CaixaCodigo> {
  bool _copiado = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: widget.codigo));
    HapticFeedback.selectionClick();
    if (!mounted) return;

    setState(() => _copiado = true);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BordaTracejada(
      cor: CoresPolar.azul,
      child: Material(
        color: CoresPolar.azulTinta,
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
        child: InkWell(
          borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
          onTap: _copiar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'CÓDIGO DE RETIRADA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: CoresPolar.azulEscuro),
                ),
                const SizedBox(height: 8),
                Padding(
                  // compensa o espaçamento após o último dígito, para centralizar
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    widget.codigo,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 14,
                      color: CoresPolar.azulNoite,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    key: ValueKey(_copiado),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copiado ? Icons.check_rounded : Icons.copy_rounded,
                        size: 13,
                        color: _copiado ? CoresPolar.sucesso : CoresPolar.azulEscuro,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _copiado ? 'Copiado' : 'Toque para copiar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _copiado ? CoresPolar.sucesso : CoresPolar.azulEscuro,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dois quadros lado a lado (rótulo pequeno + valor), como "Nº do pedido" e "Pagamento".
class QuadrosInfo extends StatelessWidget {
  final List<(String, String)> itens;

  const QuadrosInfo({super.key, required this.itens});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < itens.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: CoresPolar.fundoSuave,
                borderRadius: BorderRadius.circular(TemaPolar.raio),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itens[i].$1.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: CoresPolar.textoFraco),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    itens[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
