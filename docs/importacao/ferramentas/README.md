# Robô importador de textos

Esta pasta contém ferramentas auxiliares para transformar textos copiados de páginas de referência em JSONs no padrão de importação do HQ-HUB.

## O que o robô faz agora

- Lê um arquivo `.txt` com uma ou várias edições copiadas manualmente.
- Também pode ler uma URL de edição, quando a página entregar HTML com os dados visíveis.
- Identifica edições, número, data de publicação, editora, preço, capa, descrição e histórias.
- Identifica a publicação original de cada história quando houver linha como `Publicada pela primeira vez em ...`.
- Gera um JSON revisável antes de qualquer carga no banco.

Ele ainda não raspa páginas automaticamente por URL. Essa etapa deve ser tratada com cuidado por causa de termos de uso, limite de acesso e risco de sobrecarregar sites externos.
O modo `--url` serve para extração assistida de uma página individual, gerando rascunho para revisão.
O modo `--seguir-galeria` segue os links de edições da mesma galeria e gera um JSON único para a coleção.

## Como executar

Exemplo com arquivo de texto:

```powershell
python docs/importacao/ferramentas/robo_importador_texto.py `
  --entrada "C:\Users\User\.codex\attachments\d5fbb862-0945-4caa-8b53-ec743c33135f\pasted-text.txt" `
  --saida docs/importacao/rascunhos/espetacular-edicao-definitiva-robo.json `
  --titulo-serie "Espetacular Homem-Aranha, O - Edição Definitiva" `
  --editora Panini `
  --volume 1
```

Exemplo com URL:

```powershell
python docs/importacao/ferramentas/robo_importador_texto.py `
  --url "http://www.guiadosquadrinhos.com/edicao/saga-do-batman-a-1-serie-n-2/sa011126/159263" `
  --saida docs/importacao/rascunhos/saga-do-batman-url-robo.json `
  --titulo-serie "Saga do Batman, A" `
  --fase "1ª Série" `
  --editora Panini `
  --volume 1
```

Exemplo seguindo a galeria da coleção:

```powershell
python docs/importacao/ferramentas/robo_importador_texto.py `
  --url "http://www.guiadosquadrinhos.com/edicao/saga-do-batman-a-1-serie-n-2/sa011126/159263" `
  --seguir-galeria `
  --maximo-edicoes 36 `
  --intervalo-segundos 0.5 `
  --tentativas 2 `
  --saida docs/importacao/rascunhos/saga-do-batman-1-serie-robo.json `
  --titulo-serie "Saga do Batman, A" `
  --fase "1ª Série" `
  --editora Panini `
  --volume 1
```

## Fluxo recomendado

1. Salvar o texto copiado em um arquivo `.txt`.
2. Rodar o robô para gerar um JSON em `docs/importacao/rascunhos`.
3. Revisar avisos, capas, datas e histórias.
4. Promover o JSON revisado para `docs/importacao`.
5. Rodar o importador do backend.

Esse fluxo evita que dados incompletos entrem direto no catálogo.

## Enriquecer capas pela Panini

Quando uma coleção da Panini tiver páginas públicas com imagens exibíveis, use o robô de capas para gerar uma nova versão do JSON com `urlCapa` substituída.

Exemplo testado com a Saga do Batman:

```powershell
python docs/importacao/ferramentas/robo_capas_panini.py `
  --entrada docs/importacao/rascunhos/saga-do-batman-1-serie-robo.json `
  --saida docs/importacao/rascunhos/saga-do-batman-1-serie-com-capas-panini.json `
  --slug-base a-saga-do-batman `
  --deslocamento-comercial 56 `
  --intervalo-segundos 0.3 `
  --tentativas 2
```

Esse teste encontrou capas Panini para as edições 1 a 9 da Saga do Batman. As demais não seguiram o mesmo padrão de URL no site atual da Panini e ficaram com aviso no JSON.
