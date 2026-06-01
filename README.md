# VideoGameLibraryApp

## Contexto

VideoGameLibraryApp é um aplicativo iOS para explorar jogos, pesquisar títulos, visualizar detalhes e salvar seus jogos favoritos.

## Solução Proposta

A aplicação consome a API da IGDB para exibir uma lista de jogos, suporta busca, permite favoritar jogos localmente e apresenta uma tela de detalhes com as principais informações disponíveis para cada título.

Principais fluxos do usuário:

- navegar por uma lista de jogos carregada da API
- buscar jogos por nome
- continuar navegando com scroll infinito e carregamento paginado
- visualizar detalhes do jogo
- adicionar e remover favoritos
- persistir favoritos localmente entre execuções

## Visão Técnica

O projeto está estruturado com separação clara de camadas:

- `AppSetupFiles`: composição da aplicação, injeção de dependência, coordinators e ciclo de vida
- `Data`: requests da API, mapeamento de responses, repositories e persistência local
- `Domain`: entidades, contratos de repository, use cases e store compartilhada de favoritos
- `Presentation`: view controllers, view models, views reutilizáveis e helpers de UI

Principais decisões de arquitetura:

- uso de `Coordinator` para navegação
- injeção de dependência através de `AppDependencyContainer`
- padrão de repository para isolar API e persistência
- `FavoriteGamesStore` como fonte compartilhada de verdade para o estado de favoritos
- `SwiftData` para persistência local
- UIKit com interface criada por código(viewcode)
- paginação explícita com `GamesPage`, `offset` e `limit`
- dependência local [`NetworkingKit`](./NetworkingKit) para isolar as responsabilidades de rede
- testes com Swift Testing

## Funcionalidades Implementadas

- Tela de listagem de jogos
- Busca com debounce
- Scroll infinito com paginação via múltiplas requests para a IGDB
- Favoritar e desfavoritar pela listagem e pela tela de favoritos
- Persistência de favoritos com SwiftData
- Tela de detalhes do jogo
- Estados de loading, vazio, sucesso e erro
- Strings visíveis ao usuário centralizadas em `Localizable.strings`
- Testes unitários para pontos importantes de domínio, dados e apresentação

## Como Executar o Projeto

### Requisitos

- Xcode
- Simulador iOS
- Credenciais da API da IGDB

### Configuração

1. Abra o projeto no Xcode.
2. Crie uma conta na Twitch e siga o fluxo de autenticação da IGDB para obter as credenciais da API.

Resumo do processo:

- criar uma conta na Twitch
- ativar `Two-Factor Authentication`
- registrar uma aplicação no portal de desenvolvedor da Twitch
- gerar o `Client Secret`
- usar `Client ID` + `Client Secret` para gerar o `Access Token`

Links úteis:

- Documentação da IGDB: https://api-docs.igdb.com/
- Getting Started / Authentication: https://api-docs.igdb.com/?trk=public_post-text

3. Configure suas credenciais da IGDB em:

`VideoGameLibraryApp/VideoGameLibraryApp/AppSetupFiles/Config.xcconfig`

Chaves necessárias:

- `CLIENT_ID`
- `ACCESS_TOKEN`

4. Faça o build e execute a aplicação no simulador.

## Testes

O projeto inclui testes unitários para:

- fluxo de busca e carregamento de jogos
- paginação da listagem
- mapeamento do repository da IGDB
- persistência de favoritos
- comportamento da store de favoritos
- view models da listagem e dos favoritos

Também existe o pacote separado [`NetworkingKit`](./NetworkingKit), com seus próprios testes.

## Evoluções Futuras

- adicionar testes de UI para os fluxos principais
- melhorar comportamento offline e estratégia de cache
- evoluir a paginação com prefetch
- adicionar acessibilidade
- adicionar mais dados relevantes na tela de detalhes
- melhorar UX de estados de lista e busca