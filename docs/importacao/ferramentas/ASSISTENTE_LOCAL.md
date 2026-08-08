# Assistente local do HQ-HUB

O assistente local permite que a página de importação do HQ-HUB use uma sessão
visível do Google Chrome. A verificação “Não sou um robô” é concluída pela
pessoa no próprio computador; cookies e dados da sessão não são enviados ao
backend do HQ-HUB.

## Iniciar

Na raiz do projeto, execute:

```powershell
powershell -ExecutionPolicy Bypass -File docs/importacao/ferramentas/iniciar_assistente_local.ps1
```

O inicializador:

1. localiza o Python 3;
2. instala o pacote `playwright` caso ele ainda não esteja disponível;
3. inicia a ponte em `http://127.0.0.1:8765`;
4. abre a página de importação do HQ-HUB.

Mantenha a janela do PowerShell aberta. Na aba **Coletar do Guia**, preencha a
URL, o título, a editora e o volume. Clique em **Abrir Chrome e gerar JSON**,
conclua a verificação no Chrome e aguarde.

O assistente continua automaticamente pela galeria. A cada dez edições ele
aguarda de 2 a 3 minutos, recarrega a próxima página e segue da edição 11, 21,
31 etc. Não é necessário digitar uma nova URL entre os lotes.

Ao final, o JSON aparece na página para revisão. A importação continua sendo
uma ação separada e explícita pelo botão **Importar JSON**. A aba **JSON / robô**
permanece disponível para selecionar ou colar um arquivo manualmente.

## Segurança

- O serviço escuta somente em `127.0.0.1`, nunca na rede externa.
- Apenas o domínio oficial do HQ-HUB e endereços locais de desenvolvimento são
  aceitos pelo navegador.
- A coleta pode ser interrompida pela página ou com `Ctrl+C` no PowerShell.
- A coleta do Guia é exclusiva. Para capas do Telegram, até dois robôs podem
  trabalhar ao mesmo tempo em intervalos diferentes.

## Opção

Iniciar sem abrir o site automaticamente:

```powershell
powershell -ExecutionPolicy Bypass -File docs/importacao/ferramentas/iniciar_assistente_local.ps1 -NaoAbrirSite
```

O frontend do HQ-HUB usa a porta padrão `8765`.

## Capas do Telegram

A aba **Capas do Telegram** usa a mesma ponte local. Configure
`TELEGRAM_API_ID` e `TELEGRAM_API_HASH` antes de iniciar o assistente. A
aplicação envia ao processo local somente o token temporário da sessão atual do
HQ-HUB; ele não é salvo em arquivo nem retornado pelos endpoints locais.

O robô usa a maior miniatura do CBZ/PDF como capa quando ela estiver disponível.
Se o documento não possuir miniatura, baixa o arquivo em uma pasta temporária,
extrai a primeira página e descarta tudo após o upload. A tela permite escolher
a série, o intervalo, acompanhar sucessos/falhas e interromper a tarefa.

Para usar dois robôs, inicie a primeira faixa em uma aba e abra uma nova aba do
HQ-HUB para iniciar a segunda. O assistente reserva os slots **Robô 1** e
**Robô 2**, usa arquivos de sessão separados e bloqueia intervalos sobrepostos
da mesma série. Na primeira inicialização da versão 1.2, a autorização local já
existente é copiada para a sessão independente do segundo robô.
