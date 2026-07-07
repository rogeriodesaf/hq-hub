# Fluxo essencial de importacao HQ-HUB

Esta pasta separa os robos principais para montar um JSON pronto para importar no HQ-HUB.

## Fluxo em um comando

Use este robo quando voce ja sabe:

- a URL do Guia dos Quadrinhos, de preferencia a pagina `/capas/`;
- a URL inicial da sequencia da Panini;
- a quantidade de edicoes.

Ele roda o Guia, coleta as capas Panini e aplica as capas no JSON final.

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_gerar_importacao_guia_panini.py `
  --url-guia "https://www.guiadosquadrinhos.com/capas/saga-do-lanterna-verde-a/sa011149" `
  --url-panini-inicial "https://panini.com.br/a-saga-do-lanterna-verde-01" `
  --quantidade 7 `
  --saida "docs/importacao/rascunhos/saga-do-lanterna-verde/saga-do-lanterna-verde-1-serie-com-capas-panini.json" `
  --titulo-serie "Saga do Lanterna Verde, A" `
  --fase "Primeira temporada" `
  --editora Panini `
  --volume 1
```

O robo tambem gera arquivos intermediarios ao lado do JSON final:

- `*-base-guia.json`
- `*-capas-panini.txt`

## 1. Gerar JSON base pelo Guia dos Quadrinhos

Use quando voce tem a URL de uma edicao no Guia dos Quadrinhos e quer gerar o JSON base da colecao.

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_importador_texto.py `
  --url "URL_DA_EDICAO_NO_GUIA" `
  --seguir-galeria `
  --maximo-edicoes 36 `
  --saida "docs/importacao/rascunhos/NOME-DA-PASTA/arquivo-base.json" `
  --titulo-serie "Titulo da Serie" `
  --fase "1a Serie" `
  --editora Panini `
  --volume 1
```

## 2. Coletar capas da Panini por padrao sequencial

Use quando as paginas da Panini seguem um padrao numerico, como:

```text
https://panini.com.br/a-saga-da-mulher-maravilha-01
https://panini.com.br/a-saga-da-mulher-maravilha-02
https://panini.com.br/a-saga-da-mulher-maravilha-03
```

Tambem funciona com dois numeros no fim:

```text
https://panini.com.br/a-saga-da-mulher-maravilha-01-08
https://panini.com.br/a-saga-da-mulher-maravilha-02-09
https://panini.com.br/a-saga-da-mulher-maravilha-03-10
```

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_coletar_capas_panini_sequencial.py `
  --url-inicial "https://panini.com.br/a-saga-da-mulher-maravilha-01" `
  --quantidade 7 `
  --saida "docs/importacao/rascunhos/NOME-DA-PASTA/capas-panini.txt" `
  --intervalo-segundos 0.5 `
  --tentativas 2
```

O TXT gerado tera uma URL de capa por linha, na ordem das edicoes.

## 3. Descobrir URLs de produto da Amazon

Use quando voce quer tentar encontrar automaticamente as paginas de produto da Amazon a partir do JSON base.

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_descobrir_urls_produto_amazon_playwright.py `
  --entradas-json "docs/importacao/rascunhos/NOME-DA-PASTA/arquivo-base.json" `
  --saida-urls "docs/importacao/rascunhos/NOME-DA-PASTA/urls-produto-amazon.txt" `
  --saida-relatorio "docs/importacao/rascunhos/NOME-DA-PASTA/urls-produto-amazon-relatorio.json" `
  --intervalo-segundos 1.0
```

O relatorio tambem tenta registrar `precoCompraAmazon` e `dataCapturacaoPrecoCompraAmazon`, que podem ser copiados para `publicacaoOriginal` no JSON final.

## 4. Coletar URLs diretas das capas da Amazon

Use quando voce ja tem um TXT com URLs de produto da Amazon e quer gerar outro TXT com uma URL de capa por linha.

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_coletar_capas_amazon_playwright.py `
  --entrada-urls "docs/importacao/rascunhos/NOME-DA-PASTA/urls-produto-amazon.txt" `
  --saida-urls "docs/importacao/rascunhos/NOME-DA-PASTA/capas-amazon.txt" `
  --saida-relatorio "docs/importacao/rascunhos/NOME-DA-PASTA/capas-amazon-relatorio.json" `
  --intervalo-segundos 1.0
```

## 5. Aplicar capas no JSON

Use quando voce ja tem um TXT com uma URL de capa por linha, na mesma ordem das edicoes do JSON.

```powershell
python docs/importacao/ferramentas/fluxo-essencial-hqhub/robo_aplicar_url_capa.py `
  --entrada "docs/importacao/rascunhos/NOME-DA-PASTA/arquivo-base.json" `
  --urls "docs/importacao/rascunhos/NOME-DA-PASTA/capas-amazon.txt" `
  --saida "docs/importacao/rascunhos/NOME-DA-PASTA/arquivo-pronto-para-importar.json" `
  --estrito
```

## Atalho quando o TXT de capas ja esta pronto

Se voce ja tiver o TXT com as capas, use apenas:

1. `robo_importador_texto.py`
2. `robo_aplicar_url_capa.py`

Se a Panini tiver padrao sequencial, use:

1. `robo_importador_texto.py`
2. `robo_coletar_capas_panini_sequencial.py`
3. `robo_aplicar_url_capa.py`

O parametro `--estrito` e recomendado porque faz o robo falhar se a quantidade de URLs for diferente da quantidade de edicoes.
