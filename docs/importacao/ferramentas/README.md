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

## Coletar capas Panini por sequência de URL

Quando os produtos seguem um padrão incremental de URL, use o robô abaixo para coletar as capas e salvar em TXT.

Padrões suportados:
- Contador único: `...produto-25`, `...produto-26`, `...produto-27`
- Contador duplo: `...vol-1-25`, `...vol-2-26`, `...vol-3-27`

Exemplo para 18 edições a partir de `vol-1-25`:

```powershell
python docs/importacao/ferramentas/robo_coletar_capas_panini_sequencial.py `
  --url-inicial "https://panini.com.br/a-saga-do-superman-vol-1-25" `
  --quantidade 18 `
  --saida docs/importacao/rascunhos/a-saga-do-superman/capas-panini-vol-1-25-a-42.txt `
  --intervalo-segundos 0.5 `
  --tentativas 2
```

Saída: arquivo TXT com uma URL de capa por linha. Se alguma página falhar ou não tiver capa, a linha correspondente é gravada como `null`.

## Coletar capas da Amazon por URL de produto

Quando você já tiver as URLs dos produtos na Amazon, use o robô abaixo para extrair:
- `#productTitle` (título da página)
- URL da capa principal (preferindo alta resolução quando disponível)

Entrada esperada:
- Um arquivo `.txt` com uma URL de produto por linha.

Exemplo:

```powershell
python docs/importacao/ferramentas/robo_coletar_capas_amazon.py `
  --entrada-urls docs/importacao/rascunhos/a-saga-do-batman/urls-amazon.txt `
  --saida-urls docs/importacao/rascunhos/a-saga-do-batman/capas-amazon.txt `
  --saida-relatorio docs/importacao/rascunhos/a-saga-do-batman/capas-amazon-relatorio.json `
  --intervalo-segundos 1.0 `
  --tentativas 2
```

Saídas:
- `capas-amazon.txt`: uma URL de capa por linha (ou `null`)
- `capas-amazon-relatorio.json`: detalhes por URL (título, capa, erro)

Observação:
- A Amazon pode bloquear requisições automatizadas. Use intervalos maiores se necessário e revise os resultados antes de aplicar no JSON final.

## Aplicar lista manual de URLs de capa

Quando você já tiver uma lista de URLs pronta (uma por edição, em ordem), use este robô para preencher `edicoes[].urlCapa` automaticamente.

1. Crie um arquivo `.txt` com uma URL por linha.
2. Execute o comando abaixo.

```powershell
python docs/importacao/ferramentas/robo_aplicar_url_capa.py `
  --entrada docs/importacao/rascunhos/a-saga-do-superman/a-saga-do-superman-1-a-18.json `
  --urls docs/importacao/rascunhos/a-saga-do-superman/capas-amazon.txt `
  --saida docs/importacao/rascunhos/a-saga-do-superman/a-saga-do-superman-1-a-18-com-capas.json
```

Se a quantidade de URLs não bater com a quantidade de edições, o script aplica até onde for possível e registra aviso no JSON. Para exigir quantidade exata, adicione `--estrito`.
Linhas `null` no TXT viram `urlCapa: null` no JSON final.
