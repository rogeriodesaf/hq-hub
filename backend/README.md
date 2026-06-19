# Backend HQ-HUB

Backend inicial do HQ-HUB, criado com Quarkus e focado em usuários, autenticação e base inicial do catálogo de quadrinhos.

Para visão de produto, roadmap, backlog, personas, histórias de usuário e modelagem conceitual, consulte a documentação principal em `../docs/planejamento`.

## Requisitos

- Java 21
- Maven
- PostgreSQL

## Banco de dados local

Crie o banco `hqhub` no PostgreSQL local:

```sql
CREATE DATABASE hqhub;
```

Configuração esperada:

- Host: `localhost`
- Porta: `5433`
- Banco: `hqhub`
- Usuário: `postgres`
- Senha: `postgres`

Também é possível subir um PostgreSQL local com Docker usando o `docker-compose.yml` da raiz do projeto:

```bash
docker compose up -d postgres
```

## Rodar o projeto

Na pasta `backend`, execute:

```bash
mvn quarkus:dev
```

Ao iniciar, o Flyway executa automaticamente a migration `V1__criar_tabela_usuarios.sql` e cria a tabela `usuarios`.

Se quiser sobrescrever a conexão sem mexer no arquivo de configuração, use estas variáveis:

- `HQHUB_DB_HOST`
- `HQHUB_DB_PORT`
- `HQHUB_DB_USUARIO`
- `HQHUB_DB_SENHA`

## Swagger

Com a aplicação em execução, acesse:

```text
http://localhost:8080/swagger
```

## Endpoints

### Cadastrar usuário

```text
POST /usuarios
```

Retorna `201 Created`.

### Listar usuários

```text
GET /usuarios
```

Retorna `200 OK`. Requer token JWT no cabeçalho `Authorization`.

### Buscar usuário por id

```text
GET /usuarios/{id}
```

Retorna `200 OK` quando encontrado ou `404 Not Found` quando o usuário não existe. Requer token JWT no cabeçalho `Authorization`.

### Login

```text
POST /auth/login
```

Retorna `200 OK` quando o e-mail e a senha são válidos. A resposta inclui um token JWT do tipo `Bearer`.

Use o token nas rotas protegidas:

```text
Authorization: Bearer seu-token
```

### Cadastrar editora

```text
POST /editoras
```

Retorna `201 Created`. Requer token JWT.

### Listar editoras

```text
GET /editoras
```

Retorna `200 OK`. Requer token JWT.

### Buscar editora por id

```text
GET /editoras/{id}
```

Retorna `200 OK` quando encontrada ou `404 Not Found` quando a editora não existe. Requer token JWT.

### Atualizar editora

```text
PUT /editoras/{id}
```

Retorna `200 OK`. Requer token JWT.

### Remover editora

```text
DELETE /editoras/{id}
```

Retorna `204 No Content`. Requer token JWT.

### Cadastrar série

```text
POST /series
```

Retorna `201 Created`. Requer token JWT.

### Listar séries

```text
GET /series
```

Retorna `200 OK`. Requer token JWT.

### Buscar série por id

```text
GET /series/{id}
```

Retorna `200 OK` quando encontrada ou `404 Not Found` quando a série não existe. Requer token JWT.

### Atualizar série

```text
PUT /series/{id}
```

Retorna `200 OK`. Requer token JWT.

### Remover série

```text
DELETE /series/{id}
```

Retorna `204 No Content`. Requer token JWT.

### Cadastrar edição

```text
POST /edicoes
```

Retorna `201 Created`. Requer token JWT.

### Listar edições

```text
GET /edicoes
GET /edicoes?serieId={id}
```

Retorna `200 OK`. Requer token JWT.

### Buscar edição por id

```text
GET /edicoes/{id}
```

Retorna `200 OK` quando encontrada ou `404 Not Found` quando a edição não existe. Requer token JWT.

### Atualizar edição

```text
PUT /edicoes/{id}
```

Retorna `200 OK`. Requer token JWT.

### Remover edição

```text
DELETE /edicoes/{id}
```

Retorna `204 No Content`. Requer token JWT.

### Adicionar item à coleção

```text
POST /colecao/itens
```

Retorna `201 Created`. Requer token JWT. O usuário é identificado pelo token.

### Listar itens da coleção

```text
GET /colecao/itens
```

Retorna `200 OK`. Requer token JWT.

### Buscar item da coleção por id

```text
GET /colecao/itens/{id}
```

Retorna `200 OK` quando encontrado ou `404 Not Found` quando o item não pertence ao usuário autenticado. Requer token JWT.

### Atualizar item da coleção

```text
PUT /colecao/itens/{id}
```

Retorna `200 OK`. Requer token JWT.

### Remover item da coleção

```text
DELETE /colecao/itens/{id}
```

Retorna `204 No Content`. Requer token JWT.

### Listar edições faltantes de uma série

```text
GET /colecao/faltantes/series/{serieId}
```

Retorna `200 OK` com as edições da série que ainda não estão na coleção do usuário autenticado. Requer token JWT.

### Resumo da coleção

```text
GET /colecao/resumo
```

Retorna `200 OK` com totais da coleção do usuário autenticado. Requer token JWT.

### Completude da coleção por série

```text
GET /colecao/resumo/series/{serieId}
```

Retorna `200 OK` com total de edições, edições possuídas, faltantes e percentual completo da série. Requer token JWT.

### Organizar status de série na coleção

```text
POST /colecao/series
GET /colecao/series
GET /colecao/series/{id}
PUT /colecao/series/{id}
DELETE /colecao/series/{id}
```

Permite marcar séries como `EM_ANDAMENTO`, `CONCLUIDA`, `PAUSADA`, `DESEJADA` ou `ABANDONADA`.

### Planejar compras

```text
POST /compras-planejadas
GET /compras-planejadas
GET /compras-planejadas?mes={mes}&ano={ano}
GET /compras-planejadas/{id}
PUT /compras-planejadas/{id}
DELETE /compras-planejadas/{id}
```

Permite organizar compras por mês e ano.

### Links externos de edição

```text
POST /links-edicoes
GET /links-edicoes/{id}
GET /links-edicoes/edicoes/{edicaoId}
PUT /links-edicoes/{id}
DELETE /links-edicoes/{id}
```

Permite cadastrar links de compra, referência, Wikipédia, Guia dos Quadrinhos e outros.

### Estante virtual

```text
GET /estante
```

Retorna a coleção do usuário agrupada por editora, série e edições.

### Criadores e créditos por edição

```text
POST /criadores
GET /criadores
GET /criadores?nome={nome}
GET /criadores/{id}
PUT /criadores/{id}
DELETE /criadores/{id}
POST /criadores/creditos
GET /criadores/{id}/edicoes
GET /criadores/{id}/edicoes?papel={papel}
DELETE /criadores/creditos/{id}
```

Permite cadastrar criadores, vincular créditos às edições e listar publicações de um criador em ordem cronológica.

### Relacionamentos entre séries

```text
POST /relacionamentos-series
GET /relacionamentos-series/series/{serieId}
DELETE /relacionamentos-series/{id}
```

Permite ligar séries por continuidade, reboot, relançamento, spin-off, crossover e outros relacionamentos. A série também possui campos `volume` e `ordemCronologica`.

### Publicações relacionadas

```text
POST /publicacoes-relacionadas
GET /publicacoes-relacionadas/edicoes/{edicaoId}
DELETE /publicacoes-relacionadas/{id}
```

Permite relacionar uma edição original com publicações brasileiras, reimpressões e republicações.

### Histórias e conteúdos de edição

```text
POST /historias
GET /historias
GET /historias/{id}
PUT /historias/{id}
POST /conteudos-edicoes
GET /conteudos-edicoes/edicoes/{edicaoId}
DELETE /conteudos-edicoes/{id}
POST /publicacoes-historias
POST /historias/{idHistoria}/publicacoes
GET /publicacoes-historias/historias/{historiaId}
DELETE /publicacoes-historias/{id}
GET /cruzamentos-edicoes?edicaoOriginalId={id}&edicaoComparadaId={id}
```

Permite cadastrar histórias e outros conteúdos dentro de uma edição, vincular histórias originais a edições brasileiras e comparar uma edição original com outra publicação para saber quais conteúdos foram incluídos e quais ficaram de fora.

O endpoint `POST /historias/{idHistoria}/publicacoes` permite que usuários sugiram em quais outras revistas uma história foi publicada ou republicada. Essas informações nascem com `statusValidacao=PENDENTE`, para futura moderação.

### Importações assíncronas

```text
POST /importacoes
GET /importacoes
GET /importacoes/{id}
POST /importacoes/{id}/processar
```

Registra pedidos de importação e permite processar a consulta em uma fonte externa.

### Integrações externas

```text
GET /integracoes-externas/fontes
GET /integracoes-externas/{fonteExterna}/buscar?termo={termo}
GET /integracoes-externas/COMICVINE/volumes?termo={termo}
GET /integracoes-externas/COMICVINE/volumes/{idVolume}/edicoes
GET /integracoes-externas/COMICVINE/volumes/{idVolume}/edicoes?idPessoa={idPessoa}&papel={papel}
GET /integracoes-externas/COMICVINE/edicoes/{idEdicao}/detalhes
GET /integracoes-externas/COMICVINE/pessoas?termo={termo}
GET /integracoes-externas/COMICVINE/pessoas/{idPessoa}/detalhes
```

Fontes disponíveis:

- `WIKIPEDIA`: busca pública sem chave.
- `WIKIDATA`: busca pública sem chave.
- `GCD`: busca pública pela API oficial do Grand Comics Database/comics.org.
- `MARVEL`: requer `HQHUB_MARVEL_CHAVE_PUBLICA` e `HQHUB_MARVEL_CHAVE_PRIVADA`.
- `COMICVINE`: requer `HQHUB_COMICVINE_CHAVE_API`.

A Comic Vine é usada como fonte externa para edições estrangeiras. A descrição original pode vir em inglês; o HQ-HUB preserva essa descrição em `descricaoOriginal` e também suporta `descricaoPortugues` para curadoria futura. A resposta de detalhe usa `descricaoExibicao`, priorizando português quando houver e caindo para a descrição original quando não houver.

O detalhe da edição da Comic Vine retorna volume, número, datas de cobertura e disponibilidade em loja, capa, URL da Comic Vine, ID externo e conteúdos internos quando a API fornece esses dados. A listagem cronológica de edições por volume continua separada e paginada.

Também é possível buscar pessoas na Comic Vine, abrir dados de biografia de autores, desenhistas, editores e outros créditos, e filtrar as edições de um volume por pessoa e papel. O filtro por pessoa/papel consulta os detalhes das edições do volume quando necessário e tem limite de segurança para evitar consultas excessivamente longas em volumes muito grandes.

O Guia dos Quadrinhos pode ser usado como link externo e fonte de contribuição manual assistida. Não há raspagem automática do Guia nesta fase.

### Contribuições de catálogo

```text
POST /contribuicoes-catalogo
GET /contribuicoes-catalogo/minhas
GET /contribuicoes-catalogo/pendentes
POST /contribuicoes-catalogo/{id}/aprovar
POST /contribuicoes-catalogo/{id}/recusar
```

Permite que usuários contribuam com capas, dados de edição, links do Guia dos Quadrinhos e informações sobre onde uma edição foi publicada no Brasil. As contribuições entram como pendentes e podem ser aprovadas/recusadas antes de alterar o catálogo oficial.

### Busca paginada

```text
GET /series?busca={termo}&pagina=0&tamanho=20
GET /edicoes?serieId={id}&busca={termo}&pagina=0&tamanho=50
```

As listagens principais de séries e edições usam paginação para evitar respostas grandes demais.

### Comunidade e amizades

```text
POST /amizades/solicitacoes
GET /amizades/solicitacoes/recebidas
GET /amizades/solicitacoes/enviadas
POST /amizades/solicitacoes/{id}/aceitar
POST /amizades/solicitacoes/{id}/recusar
GET /amizades/amigos
DELETE /amizades/amigos/{usuarioId}
POST /amizades/bloqueios
GET /amizades/bloqueios
DELETE /amizades/bloqueios/usuarios/{usuarioId}
```

Permite enviar e responder solicitações de amizade, listar amigos, remover amigos e bloquear usuários.

### Compartilhamento de coleção

```text
GET /colecao/configuracao
PUT /colecao/configuracao
GET /colecao/usuarios/{usuarioId}
```

Permite definir a visibilidade da coleção como `PRIVADA`, `AMIGOS` ou `PUBLICA`. Por padrão, a coleção é privada.

### Classificados de venda e troca

```text
POST /anuncios
GET /anuncios
GET /anuncios/meus
GET /anuncios/{id}
GET /anuncios/edicoes/{edicaoId}
GET /anuncios/edicoes/{edicaoId}?tipo={tipo}
GET /edicoes/{edicaoId}/anuncios
GET /edicoes/{edicaoId}/anuncios?tipo={tipo}
GET /anuncios/usuarios/{usuarioId}
PUT /anuncios/{id}
POST /anuncios/{id}/pausar
POST /anuncios/{id}/reativar
POST /anuncios/{id}/encerrar
DELETE /anuncios/{id}
POST /anuncios/{id}/fotos
GET /anuncios/{id}/fotos
DELETE /anuncios/{id}/fotos/{fotoId}
GET /anuncios/{id}/contato
```

Permite criar anúncios vinculados a itens da coleção para venda, troca ou venda e troca. O anúncio deve estar vinculado a uma HQ da coleção do usuário autenticado. O contato por WhatsApp só é retornado quando o anunciante permitir, junto com `linkContatoWhatsapp`.

O HQ-HUB não intermedeia pagamentos, entregas, trocas ou negociações. Os anúncios funcionam como classificados entre colecionadores. Toda negociação deve ser combinada diretamente entre os usuários, por canais externos, como WhatsApp. O sistema apenas organiza e divulga os anúncios.

### Denúncias e moderação básica

```text
POST /denuncias/anuncios
GET /denuncias/anuncios
POST /denuncias/usuarios
GET /denuncias/usuarios
```

Permite registrar denúncias de anúncios e usuários. As denúncias nascem com status `PENDENTE` para análise futura.

### Assistente interno

```text
POST /assistente/conversas
GET /assistente/conversas
GET /assistente/conversas/{id}
POST /assistente/conversas/{id}/mensagens
POST /assistente/perguntar
```

Permite criar conversas, consultar histórico e enviar perguntas para o assistente. Nesta primeira versão, o assistente responde usando apenas o banco da aplicação, sem integração com Google, IA externa ou scraping.

O endpoint `POST /assistente/perguntar` continua disponível como atalho sem histórico.

Exemplos de perguntas:

```text
Qual é o resumo da minha coleção?
Quais edições faltam na serieId=1?
Quais compras tenho planejadas para junho de 2026?
Quais publicações do criador Alan Moore existem no catálogo?
A serieId=1 continua em alguma v2 ou relançamento?
```

## Exemplos de requisição

Os exemplos estão em:

```text
docs/testes-api/usuarios.http
docs/testes-api/editoras.http
docs/testes-api/series.http
docs/testes-api/edicoes.http
docs/testes-api/colecao.http
docs/testes-api/organizacao.http
docs/testes-api/criadores.http
docs/testes-api/cronologia-series.http
docs/testes-api/performance-importacao.http
docs/testes-api/assistente.http
docs/testes-api/comunidade-classificados.http
docs/testes-api/integracoes-externas.http
docs/testes-api/contribuicoes-catalogo.http
docs/testes-api/historias-conteudos.http
docs/testes-api/anuncios.http
```

## Observações

- A senha não é retornada nas respostas.
- A senha é salva com criptografia BCrypt.
- O cadastro impede e-mails repetidos.
- Autenticação por login com JWT já existe.
- O cadastro de editoras já existe e impede nomes repetidos.
- O cadastro de séries já existe e impede título repetido dentro da mesma editora.
- O cadastro de edições já existe e impede número repetido dentro da mesma série.
- A coleção do usuário já existe e impede a mesma edição duplicada para o mesmo usuário.
- A consulta de faltantes por série já existe.
- A coleção já possui resumo geral e completude por série.
- Séries podem ser marcadas como em andamento, concluídas, pausadas, desejadas ou abandonadas.
- Compras podem ser planejadas por mês e ano.
- Edições podem ter links externos para compra e referência.
- A estante virtual já retorna a coleção agrupada por editora e série.
- Criadores e créditos por edição já existem, com consulta cronológica por criador.
- Séries já possuem volume, ordem cronológica e relacionamentos entre séries.
- Publicações relacionadas já permitem mapear onde uma edição foi publicada ou republicada.
- Histórias e conteúdos de edição já permitem cruzar publicações e identificar o que foi incluído ou ficou de fora em outra edição.
- Histórias e edições preservam descrição original e possuem campos para descrição em português por curadoria.
- Séries e edições já possuem busca paginada.
- Solicitações de importação já podem ser registradas para processamento assíncrono.
- Integrações externas já consultam Wikipédia, Wikidata, Grand Comics Database, Marvel API e ComicVine API.
- Usuários já podem sugerir capas, links de referência e informações de publicações brasileiras por contribuições revisáveis.
- O assistente interno já possui conversas, histórico de mensagens e respostas sobre coleção, faltantes, compras planejadas, criadores e relacionamentos entre séries com base no banco local.
- Editoras, séries e edições já possuem campos para origem externa: `fonteExterna`, `idExterno` e `urlOrigem`.
- O segredo JWT de desenvolvimento pode ser sobrescrito pela variável de ambiente `HQHUB_JWT_SEGREDO`.
- Integrações com APIs externas ainda não foram implementadas.
- Comunidade, amizades, compartilhamento de coleção e classificados de venda/troca já possuem endpoints iniciais.
- Denúncias de anúncios e usuários já possuem endpoints iniciais.
- O HQ-HUB não intermedeia pagamentos, entregas, trocas ou negociações. Os anúncios funcionam apenas como classificados entre colecionadores.
