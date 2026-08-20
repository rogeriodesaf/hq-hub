-- Cadastra os sete volumes publicados de X-Factor Epic Collection. A série
-- possui numeração descontínua: os volumes 5 e 6 ainda não existem e o volume
-- 2 está anunciado, mas não publicado. As capas vêm da Penguin Random House.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Marvel Comics', 'Editora original norte-americana da Marvel.', 'Estados Unidos', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Factor Epic Collection',
    'Coleção encadernada norte-americana que reúne cronologicamente as histórias clássicas de X-Factor.',
    2017, 1, 'MARVEL', 'X-FACTOR-EPIC-COLLECTION',
    'https://www.marvel.com/comics/series/21360/x-factor_epic_collection_genesis_apocalypse_2016',
    editora.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Marvel Comics')
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH dados(numero, subtitulo, descricao, data_publicacao, paginas, isbn) AS (VALUES
    ('1', 'Genesis & Apocalypse',
     'Reúne Avengers 263, Fantastic Four 286, X-Factor 1-9, X-Factor Annual 1, Iron Man Annual 8, Amazing Spider-Man 282 e material de Classic X-Men 8 e 43.',
     DATE '2017-03-01', 456, '9781302900687'),
    ('3', 'Angel of Death',
     'Reúne X-Factor 21-36, X-Factor Annual 3 e Power Pack 35.',
     DATE '2021-05-01', 488, '9781302927103'),
    ('4', 'Judgment War',
     'Reúne X-Factor 37-50, X-Factor Annual 4 e Uncanny X-Men 242-243.',
     DATE '2023-08-01', 496, '9781302953980'),
    ('7', 'All-New, All-Different X-Factor',
     'Reúne X-Factor 71-83, X-Factor Annual 7 e Incredible Hulk 390-392.',
     DATE '2018-12-01', 456, '9781302913861'),
    ('8', 'X-Aminations',
     'Reúne X-Factor 84-100 e X-Factor Annual 8.',
     DATE '2019-11-01', 504, '9781302920579'),
    ('9', 'Afterlives',
     'Reúne X-Factor 101-111, X-Factor Annual 9, Spider-Man & X-Factor: Shadowgames 1-3, X-Force 38 e Excalibur 82.',
     DATE '2022-04-01', 496, '9781302934514'),
    ('10', 'Wreaking Havok',
     'Reúne X-Factor 112-126, Sabretooth and Mystique 1-4, Marvel Fanfare 6 e material de X-Men Prime 1.',
     DATE '2025-01-28', 496, '9781302959708')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Marvel Comics')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Factor Epic Collection')
      AND coalesce(serie.volume, 1) = 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, fonte_externa, id_externo, url_origem,
    serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero,
    'X-Factor Epic Collection #' || dado.numero || ': ' || dado.subtitulo,
    dado.descricao,
    dado.subtitulo,
    dado.data_publicacao,
    'https://images1.penguinrandomhouse.com/smedia/' || dado.isbn,
    dado.isbn,
    dado.paginas,
    'PENGUIN_RANDOM_HOUSE',
    dado.isbn,
    'https://www.penguinrandomhouse.com/search/x-factor-epic-collection?isbn=' || dado.isbn,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN dados dado
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

-- Abre sete posições imediatamente antes de A Saga dos X-Men vol. 16.
WITH marco AS (
    SELECT item.posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #16'
)
UPDATE itens_ordem_leitura item SET posicao = item.posicao + 10000
FROM ordens_leitura ordem, marco
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.posicao;

UPDATE itens_ordem_leitura item SET posicao = item.posicao - 9993
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 10000;

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao - 7 AS inicio, item.secao
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #16'
), volumes(ordem_volume, numero, subtitulo, conteudo) AS (VALUES
    (1, '1', 'Genesis & Apocalypse', 'X-Factor 1-9 e histórias relacionadas'),
    (2, '3', 'Angel of Death', 'X-Factor 21-36 e histórias relacionadas'),
    (3, '4', 'Judgment War', 'X-Factor 37-50 e histórias relacionadas'),
    (4, '7', 'All-New, All-Different X-Factor', 'X-Factor 71-83 e histórias relacionadas'),
    (5, '8', 'X-Aminations', 'X-Factor 84-100 e X-Factor Annual 8'),
    (6, '9', 'Afterlives', 'X-Factor 101-111 e histórias relacionadas'),
    (7, '10', 'Wreaking Havok', 'X-Factor 112-126 e histórias relacionadas')
), serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Marvel Comics')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Factor Epic Collection')
      AND coalesce(serie.volume, 1) = 1
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, observacao,
    ano_referencia, secao
)
SELECT
    ordem.id,
    marco.inicio + volume.ordem_volume - 1,
    'X-Factor Epic Collection',
    'V1 #' || volume.numero || ' — ' || volume.subtitulo,
    edicao.id,
    edicao.url_capa,
    'CONFIRMADO',
    E'EDIÇÃO ORIGINAL EM INGLÊS\n' || volume.conteudo ||
        '. A numeração da Epic Collection é descontínua; os volumes 5 e 6 ainda não foram publicados.',
    extract(year FROM edicao.data_publicacao)::integer,
    marco.secao
FROM ordem CROSS JOIN marco CROSS JOIN volumes volume CROSS JOIN serie_alvo serie
JOIN edicoes edicao ON edicao.serie_id = serie.id AND edicao.numero = volume.numero;
