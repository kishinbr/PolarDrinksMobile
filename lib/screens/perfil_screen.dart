import 'package:flutter/material.dart';

import '../core/tema.dart';
import '../services/auth_service.dart';
import '../widgets/componentes.dart';

/// Aba do perfil: dados do cliente e "Sair". Os pedidos entram na fase 4.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final nome = auth.nome.isEmpty ? 'Cliente' : auth.nome;
    final inicial = nome.characters.first.toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      children: [
        Text('MEU PERFIL', style: TextosPolar.titulo),
        const SizedBox(height: 4),
        const Text('Acompanhe seus pedidos e consulte o código de retirada.', style: TextosPolar.subtitulo),
        const SizedBox(height: 24),

        Container(
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
                    Text(
                      nome.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextosPolar.secao,
                    ),
                    if (auth.email.isNotEmpty)
                      Text(
                        auth.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresPolar.textoFraco),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: CoresPolar.azul, size: 19),
            SizedBox(width: 10),
            Text('MEUS PEDIDOS', style: TextosPolar.secao),
          ],
        ),
        const SizedBox(height: 14),
        const EstadoVazio(
          icone: Icons.receipt_long_outlined,
          titulo: 'Em construção',
          texto: 'Em breve seus pedidos, o status de cada um e o código de retirada aparecem aqui.',
        ),

        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => _confirmarSaida(context),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('SAIR DA CONTA'),
        ),
      ],
    );
  }
}
