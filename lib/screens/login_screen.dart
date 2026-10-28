import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/tema.dart';
import '../services/auth_service.dart';
import '../widgets/componentes.dart';
import 'cadastro_screen.dart';
import 'conta_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();

    if (AuthService.instance.sessaoExpirou) {
      _erro = 'Sua sessão expirou. Entre novamente.';
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();

    if (_email.text.trim().isEmpty || _senha.text.isEmpty) {
      setState(() => _erro = 'Informe seu e-mail e sua senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.instance.entrar(email: _email.text, senha: _senha.text);
      // Ao entrar, o app troca sozinho para a tela inicial (ver main.dart).
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContaLayout(
      titulo: 'Entrar',
      subtitulo: 'Acesse sua conta para pedir e acompanhar seus pedidos.',
      children: [
        if (_erro != null) ...[
          Aviso(_erro!),
          const SizedBox(height: 18),
        ],
        AutofillGroup(
          child: Column(
            children: [
              CampoFormulario(
                rotulo: 'E-mail',
                controller: _email,
                dica: 'seu@email.com',
                icone: Icons.mail_outline,
                teclado: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
              ),
              CampoFormulario(
                rotulo: 'Senha',
                controller: _senha,
                dica: 'Digite sua senha',
                icone: Icons.lock_outline,
                senha: true,
                acao: TextInputAction.done,
                autofill: const [AutofillHints.password],
                aoEnviar: (_) => _entrar(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        BotaoPrincipal(texto: 'Entrar', carregando: _carregando, aoPressionar: _entrar),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não tem conta?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
            ),
            TextButton(
              onPressed: _carregando
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CadastroScreen()),
                      ),
              child: const Text('Criar uma agora'),
            ),
          ],
        ),
      ],
    );
  }
}
