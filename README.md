# Polar Drinks (app)

App Flutter da loja online Polar Drinks. Usa a mesma API REST da loja web ([PolarDrink-v2](https://github.com/kishinbr/PolarDrink-v2)), publicada no Azure Container Apps.

## Como rodar

O app usa a API publicada na nuvem:

```
https://polardrinks-app.wittybeach-73617cd8.centralus.azurecontainerapps.io
```

O endereço fica em `lib/config/api_config.dart`. Não é preciso rodar a API no computador.

```bash
flutter pub get
flutter run
```

> **Primeiro acesso mais lento:** quando ninguém usa o sistema, o servidor e o banco de dados "dormem" para economizar. O primeiro acesso depois disso pode levar de 20 a 40 segundos; os seguintes são imediatos. Por isso o tempo limite das requisições é de 60 segundos.

### Gerar o APK (Android)

```bash
flutter build apk --release
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`.

## Estrutura

```
lib/
├── main.dart                 abre no login ou na loja, conforme a sessão
├── config/api_config.dart    endereço da API na nuvem, URL das imagens e tempo limite
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
├── screens/                  login, cadastro, abas Catálogo / Carrinho / Perfil, pedido confirmado e detalhe
└── widgets/                  cabeçalho, card de produto, filtros e componentes
```

## Etapas

- [x] **Fase 1:** login, cadastro, catálogo com busca, categorias e filtros, navegação e tema
- [x] **Fase 2:** carrinho pela API (adicionar, quantidade, remover, total)
- [x] **Fase 3:** checkout com Pix ou cartão e código de retirada
- [x] **Fase 4:** meus pedidos, detalhe e cancelamento
