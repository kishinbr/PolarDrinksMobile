# Polar Drinks (app)

App Flutter da loja online Polar Drinks. Usa a mesma API REST da loja web ([PolarDrink-v2](https://github.com/kishinbr/PolarDrink-v2)), sem nenhuma mudança no backend.

## Como rodar

1. Suba a API do PolarDrink-v2 (`dotnet run --project PolarDrinks`, em `http://localhost:5153`).
2. Neste projeto:

```bash
flutter pub get
flutter run
```

O endereço da API é escolhido sozinho:

| Onde o app roda | Endereço usado |
|---|---|
| Emulador Android | `http://10.0.2.2:5153` |
| Simulador iOS / desktop | `http://localhost:5153` |

Para usar outro servidor (por exemplo, o Azure), não precisa mudar código:

```bash
flutter run --dart-define=API_URL=https://seu-app.azurewebsites.net
```

## Estrutura

```
lib/
├── main.dart                 abre no login ou na loja, conforme a sessão
├── config/api_config.dart    endereço da API e URL das imagens
├── core/
│   ├── api_client.dart       todas as chamadas HTTP: token, erros e sessão expirada
│   ├── tema.dart             cores, fontes e estilos (iguais aos da loja web)
│   └── formatadores.dart     preço em reais e busca sem acento
├── models/                   Produto, Categoria, Carrinho, Pedido, filtros do catálogo
├── services/
│   ├── auth_service.dart     login, cadastro e token (armazenamento seguro)
│   ├── catalogo_service.dart produtos e categorias
│   ├── carrinho_service.dart carrinho do cliente na API (o mesmo da loja web)
│   └── pedido_service.dart   finalizar compra, listar, detalhar e cancelar pedidos
├── screens/                  login, cadastro, abas Início / Carrinho / Perfil, pedido confirmado e detalhe
└── widgets/                  cabeçalho, card de produto, filtros e componentes
```

## Etapas

- [x] **Fase 1:** login, cadastro, catálogo com busca, categorias e filtros, navegação e tema
- [x] **Fase 2:** carrinho pela API (adicionar, quantidade, remover, total)
- [x] **Fase 3:** checkout com Pix ou cartão e código de retirada
- [x] **Fase 4:** meus pedidos, detalhe e cancelamento
