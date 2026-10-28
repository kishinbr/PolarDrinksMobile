import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Campo de formulário no estilo da loja: rótulo pequeno em caixa alta + campo cinza com ícone.
class CampoFormulario extends StatefulWidget {
  final String rotulo;
  final TextEditingController controller;
  final String? dica;
  final IconData icone;
  final bool senha;
  final TextInputType? teclado;
  final TextInputAction acao;
  final Iterable<String>? autofill;
  final ValueChanged<String>? aoEnviar;
  final String? textoErro;

  const CampoFormulario({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.icone,
    this.dica,
    this.senha = false,
    this.teclado,
    this.acao = TextInputAction.next,
    this.autofill,
    this.aoEnviar,
    this.textoErro,
  });

  @override
  State<CampoFormulario> createState() => _CampoFormularioState();
}

class _CampoFormularioState extends State<CampoFormulario> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.rotulo.toUpperCase(), style: TextosPolar.rotulo),
          const SizedBox(height: 6),
          TextField(
            controller: widget.controller,
            obscureText: widget.senha && _ocultar,
            keyboardType: widget.teclado,
            textInputAction: widget.acao,
            autofillHints: widget.autofill,
            onSubmitted: widget.aoEnviar,
            autocorrect: false,
            enableSuggestions: !widget.senha,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CoresPolar.texto),
            decoration: InputDecoration(
              hintText: widget.dica,
              errorText: widget.textoErro,
              prefixIcon: Icon(widget.icone, size: 20),
              suffixIcon: widget.senha
                  ? IconButton(
                      tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

enum TipoAviso { erro, alerta, info, sucesso }

/// Caixa de aviso colorida (equivalente ao .aviso da loja web).
class Aviso extends StatelessWidget {
  final String mensagem;
  final TipoAviso tipo;

  const Aviso(this.mensagem, {super.key, this.tipo = TipoAviso.erro});

  @override
  Widget build(BuildContext context) {
    final (fundo, cor, icone) = switch (tipo) {
      TipoAviso.erro => (CoresPolar.erroTinta, CoresPolar.erro, Icons.error_outline),
      TipoAviso.alerta => (CoresPolar.alertaTinta, CoresPolar.alerta, Icons.warning_amber_rounded),
      TipoAviso.info => (CoresPolar.azulTinta, CoresPolar.azulEscuro, Icons.info_outline),
      TipoAviso.sucesso => (CoresPolar.sucessoTinta, CoresPolar.sucesso, Icons.check_circle_outline),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(TemaPolar.raio)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(color: cor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão principal com ícone opcional e estado "carregando".
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? aoPressionar;
  final bool carregando;
  final IconData? icone;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.carregando = false,
    this.icone = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: carregando ? null : aoPressionar,
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(texto.toUpperCase()),
                  if (icone != null) ...[
                    const SizedBox(width: 8),
                    Icon(icone, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Estado vazio com ícone em círculo, título e texto (carrinho vazio, sem pedidos etc.).
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  final Widget? acao;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: CoresPolar.fundoSuave,
        borderRadius: BorderRadius.circular(TemaPolar.raioGrande),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icone, size: 30, color: CoresPolar.azul),
          ),
          const SizedBox(height: 18),
          Text(
            titulo.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: CoresPolar.textoFraco),
          ),
          if (acao != null) ...[
            const SizedBox(height: 22),
            acao!,
          ],
        ],
      ),
    );
  }
}
