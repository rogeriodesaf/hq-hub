-- Completa o cadastro Panini de Legião de X e reafirma o vínculo no guia mutante.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Legião de X')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE series serie
SET descricao = 'Encadernado brasileiro que reúne a série Legion of X (2022) 1 a 10.',
    ano_inicio = 2023,
    ano_fim = 2023,
    fonte_externa = 'PANINI',
    id_externo = 'AXLEG001',
    url_origem = 'https://panini.com.br/x-men-legiao-de-x',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Legião de X')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = 'O Livro da Fagulha',
    descricao = 'A Legião de X protege a paz de Krakoa enquanto enfrenta possessões, deuses de Arakko e forças que transformam mutantes em versões monstruosas de si mesmos. Reúne Legion of X (2022) 1 a 10.',
    nome_volume = 'X-Men: Legião de X — O Livro da Fagulha',
    data_publicacao = DATE '2023-08-01',
    url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_oo4htahbed5ot8png8vk3klr70/-S897-f.webp',
    quantidade_paginas = 256,
    preco_capa = 79.90,
    formato = '17 x 26 cm, capa cartão',
    fonte_externa = 'PANINI',
    id_externo = 'AXLEG001',
    url_origem = 'https://panini.com.br/x-men-legiao-de-x',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA');

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Legião de X')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 529;
