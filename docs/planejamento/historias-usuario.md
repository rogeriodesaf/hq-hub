# Histórias de Usuário

## História: Enviar Solicitação de Amizade

Como usuário, quero enviar solicitação de amizade para outro colecionador para acompanhar sua coleção quando ele permitir.

Critérios de aceite:

- O usuário deve conseguir localizar outro usuário.
- O usuário deve conseguir enviar uma solicitação.
- Não deve ser possível enviar solicitação para si mesmo.
- Não deve ser possível enviar solicitação duplicada.
- A solicitação deve ficar com status pendente.

## História: Aceitar Solicitação de Amizade

Como usuário, quero aceitar uma solicitação de amizade para permitir uma relação de amizade dentro do HQ-HUB.

Critérios de aceite:

- O usuário deve visualizar solicitações pendentes.
- O usuário deve aceitar uma solicitação.
- Após aceitar, os usuários devem ser considerados amigos.
- A coleção poderá ser visualizada conforme a configuração de visibilidade.

## História: Definir Visibilidade da Coleção

Como usuário, quero definir quem pode visualizar minha coleção para controlar minha privacidade.

Critérios de aceite:

- O usuário deve poder escolher entre `PRIVADA`, `AMIGOS` e `PUBLICA`.
- Por padrão, a coleção deve ser `PRIVADA`.
- Se estiver como `AMIGOS`, apenas amigos aceitos podem visualizar.
- Se estiver como `PUBLICA`, qualquer usuário autenticado pode visualizar.

## História: Criar Anúncio de Venda ou Troca

Como usuário, quero criar anúncio para uma HQ da minha coleção para encontrar outros colecionadores interessados em comprar ou trocar.

Critérios de aceite:

- O anúncio deve estar vinculado a um item da coleção do usuário.
- O usuário deve escolher entre `VENDA`, `TROCA` ou `VENDA_E_TROCA`.
- Se for `VENDA` ou `VENDA_E_TROCA`, o preço pode ser informado.
- O usuário deve informar o estado de conservação.
- O anúncio deve ter status `ATIVO` ao ser criado.
- O anúncio deve exibir aviso de que o HQ-HUB não intermedeia a negociação.

## História: Contato Externo por WhatsApp

Como usuário interessado, quero entrar em contato com o anunciante por WhatsApp para negociar fora da plataforma.

Critérios de aceite:

- O usuário interessado deve clicar em um botão de contato.
- O sistema deve gerar uma mensagem pré-preenchida.
- A mensagem deve citar o título da HQ e o HQ-HUB.
- O contato deve acontecer fora da plataforma.
- O número do WhatsApp só deve aparecer se o anunciante permitir.
