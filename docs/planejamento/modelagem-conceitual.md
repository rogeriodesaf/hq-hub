# Modelagem Conceitual

## Entidades Planejadas

### Amizade

- id
- solicitante
- solicitado
- status
- dataSolicitacao
- dataResposta

### BloqueioUsuario

- id
- usuario
- usuarioBloqueado
- dataBloqueio
- motivo

### ConfiguracaoColecao

- id
- usuario
- visibilidadeColecao

### Anuncio

- id
- anunciante
- itemColecao
- tipoAnuncio
- preco
- estadoConservacao
- descricao
- cidade
- estado
- contatoWhatsapp
- exibirWhatsapp
- status
- dataCriacao
- dataAtualizacao

### FotoAnuncio

- id
- anuncio
- urlImagem
- principal
- dataCriacao

## Enums Planejados

### StatusAmizade

- PENDENTE
- ACEITA
- RECUSADA
- BLOQUEADA

### VisibilidadeColecao

- PRIVADA
- AMIGOS
- PUBLICA

### TipoAnuncio

- VENDA
- TROCA
- VENDA_E_TROCA

### StatusAnuncio

- ATIVO
- PAUSADO
- ENCERRADO
- REMOVIDO

### EstadoConservacao

- NOVO
- EXCELENTE
- MUITO_BOM
- BOM
- REGULAR
- RUIM

## Observações de Modelagem

- `Anuncio` deve estar vinculado a um `ItemColecao`, garantindo que o usuário anuncie uma HQ da própria coleção.
- `ConfiguracaoColecao` deve controlar a visibilidade geral da coleção do usuário.
- A visibilidade padrão da coleção deve ser `PRIVADA`.
- `BloqueioUsuario` deve impedir novas solicitações de amizade e interações futuras entre usuários bloqueados.
- `FotoAnuncio` permite múltiplas imagens por anúncio, com uma imagem principal.
- A negociação de anúncios acontece fora do HQ-HUB.
