# Assistente local do Guia dos Quadrinhos

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
- Somente uma coleta local pode ficar ativa por vez.

## Opção

Iniciar sem abrir o site automaticamente:

```powershell
powershell -ExecutionPolicy Bypass -File docs/importacao/ferramentas/iniciar_assistente_local.ps1 -NaoAbrirSite
```

O frontend do HQ-HUB usa a porta padrão `8765`.
