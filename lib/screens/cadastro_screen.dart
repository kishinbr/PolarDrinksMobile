import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/tema.dart';
import '../services/auth_service.dart';
import '../widgets/componentes.dart';
import 'conta_layout.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  final _telefone = TextEditingController();
  final _cpf = TextEditingController();

  bool _carregando = false;
  String? _erro;

  /// Campo apontado pela API como problema (ex.: "email", "cpf"), para marcar em vermelho.
  String? _campoErro;

  @override
  void dispose() {
    for (final c in [_nome, _email, _senha, _confirmacao, _telefone, _cpf]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _carregando = true;
      _erro = null;
      _campoErro = null;
    });

    try {
      await AuthService.instance.cadastrar(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
        confirmacaoSenha: _confirmacao.text,
        telefone: _telefone.text,
        cpf: _cpf.text,
      );

      // Conta criada e já logada: volta para a raiz, que agora mostra a loja.
      if (mounted) Navigator.of(context).popUntil((rota) => rota.isFirst);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.mensagem;
          _campoErro = e.campo;
        });
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Só para destacar o campo; a mensagem aparece no aviso do topo.
  String? _marcar(String campo) => _campoErro == campo ? '' : null;

  @override
  Widget build(BuildContext context) {
    return ContaLayout(
      titulo: 'Criar conta',
      subtitulo: 'Leva menos de um minuto.',
      mostrarVoltar: true,
      children: [
        if (_erro != null) ...[
          Aviso(_erro!),
          const SizedBox(height: 18),
        ],
        AutofillGroup(
          child: Column(
            children: [
              CampoFormulario(
                rotulo: 'Nome',
                controller: _nome,
                dica: 'Seu nome',
                icone: Icons.person_outline,
                teclado: TextInputType.name,
                autofill: const [AutofillHints.name],
                textoErro: _marcar('nome'),
              ),
              CampoFormulario(
                rotulo: 'E-mail',
                controller: _email,
                dica: 'seu@email.com',
                icone: Icons.mail_outline,
                teclado: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                textoErro: _marcar('email'),
              ),
              CampoFormulario(
                rotulo: 'Senha',
                controller: _senha,
                dica: 'Mínimo 6 caracteres',
                icone: Icons.lock_outline,
                senha: true,
                autofill: const [AutofillHints.newPassword],
                textoErro: _marcar('senha'),
              ),
              CampoFormulario(
                rotulo: 'Confirmar senha',
                controller: _confirmacao,
                dica: 'Repita a senha',
                icone: Icons.verified_user_outlined,
                senha: true,
                autofill: const [AutofillHints.newPassword],
                textoErro: _marcar('confirmacaoSenha'),
              ),
              CampoFormulario(
                rotulo: 'Telefone',
                controller: _telefone,
                dica: '(00) 00000-0000',
                icone: Icons.phone_outlined,
                teclado: TextInputType.phone,
                autofill: const [AutofillHints.telephoneNumber],
                textoErro: _marcar('telefone'),
              ),
              CampoFormulario(
                rotulo: 'CPF',
                controller: _cpf,
                dica: '000.000.000-00',
                icone: Icons.badge_outlined,
                teclado: TextInputType.number,
                acao: TextInputAction.done,
                aoEnviar: (_) => _cadastrar(),
                textoErro: _marcar('cpf'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        BotaoPrincipal(texto: 'Criar conta', carregando: _carregando, aoPressionar: _cadastrar),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Já tem conta?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
            ),
            TextButton(
              onPressed: _carregando ? null : () => Navigator.of(context).pop(),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ],
    );
  }
}
