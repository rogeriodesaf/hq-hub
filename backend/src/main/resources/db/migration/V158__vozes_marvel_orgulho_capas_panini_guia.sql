-- Completa os quatro volumes de Vozes da Marvel: Orgulho com dados e capas
-- oficiais da Panini e vincula o volume 4 ao guia de leitura mutante.

WITH dados(numero, titulo, ano, mes, paginas, preco, formato, url_capa, id_externo, url_origem, conteudo) AS (VALUES
    ('1', 'Orgulho', 2022, 5, 160, 74.90, '17 x 26 cm, capa dura',
     'https://panini.com.br/media/catalog/product/A/V/AVOZE001_1.jpg',
     'AVOZE001', 'https://panini.com.br/vozes-da-marvel-orgulho',
     'Marvel''s Voices: Pride (2021); Alpha Flight (1983) 106; Astonishing X-Men (2004) 51; America Chavez: Made In The USA 1; The United States of Captain America 1; Marvel''s Voices (2020) 1.'),
    ('2', 'Orgulho Vol. 2', 2023, 6, 112, 59.90, '17 x 26 cm, capa cartão',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_94ipekp9b91q12sgt5lrp9fn2l/-S897-f.webp',
     'AVOZE002', 'https://panini.com.br/vozes-da-marvel-orgulho-vol-2',
     'Marvel''s Voices: Pride (2022) 1; Hulkling & Wiccan (2022) 1.'),
    ('3', 'Orgulho Vol. 3', 2024, 8, 96, 54.90, '17 x 26 cm, capa dura',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gji912r8it5g90pvnchcfppv31/-S897-f.webp',
     'AVOZE003', 'https://panini.com.br/vozes-da-marvel-orgulho-vol-3',
     'Marvel''s Voices: Pride (2023) 1.'),
    ('4', 'Orgulho Vol. 4', 2025, 8, 64, 28.90, '17 x 26 cm, capa cartão',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gq6mabl70h7lja7o8q4g2m2t0u/-S897-f.webp',
     'AVOZE004', 'https://panini.com.br/vozes-da-marvel-orgulho-vol-4',
     'X-Men: The Wedding Special (2024) 1.')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Vozes da Marvel')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    quantidade_paginas, preco_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero,
    dado.titulo,
    dado.conteudo,
    'Vozes da Marvel: ' || dado.titulo,
    make_date(dado.ano, dado.mes, 1),
    dado.url_capa,
    dado.paginas,
    dado.preco,
    dado.formato,
    'PANINI',
    dado.id_externo,
    dado.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM dados dado
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    preco_capa = EXCLUDED.preco_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Vozes da Marvel')
      AND coalesce(serie.volume, 0) = 1
)
UPDATE series
SET descricao = 'Série brasileira Vozes da Marvel: Orgulho, antologia dedicada a personagens e criadores LGBTQIA+ da Marvel.',
    ano_inicio = 2022,
    ano_fim = 2025,
    fonte_externa = 'PANINI',
    id_externo = 'PANINI-VOZES-MARVEL-ORGULHO',
    url_origem = 'https://panini.com.br/vozes-da-marvel-orgulho',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE id IN (SELECT id FROM serie_alvo);

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Vozes da Marvel')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('4')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 556;
