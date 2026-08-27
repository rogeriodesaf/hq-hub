-- Vincula as capas diretamente às séries Panini V1 já existentes no catálogo.

WITH capas(titulo_serie, titulo_edicao, url_capa, isbn, paginas, formato, data_publicacao, id_externo, url_origem) AS (VALUES
    ('Justiça - Edição Definitiva', 'Justiça - Edição Definitiva',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/4/147258369-CAPA-INDOUG_1.png',
     '9788565484336', 492, '19,5 x 30,5 cm, colorido, capa dura', DATE '2017-10-01',
     'justica-edicao-definitiva-panini-v1',
     'https://www.comix.com.br/justica-edic-o-definitiva-30576.html'),
    ('Reino do Amanhã - Edição Definitiva', 'Reino do Amanhã - Edição Definitiva',
     'https://rika.vtexassets.com/arquivos/ids/271133/reino-do-amanha-ed-definitiva.jpg?v=635658307802270000',
     '9788565484640', 336, '19,5 x 30 cm, papel couché, colorido, capa dura', DATE '2013-10-01',
     'reino-do-amanha-edicao-definitiva-panini-v1',
     'https://www.rika.com.br/reino-do-amanha---edicao-definitiva15003992/p')
), series_alvo AS (
    SELECT DISTINCT ON (hqhub_normalizar_titulo_serie(capa.titulo_serie))
        serie.id, capa.*
    FROM capas capa
    JOIN series serie
      ON hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(capa.titulo_serie)
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
    ORDER BY
        hqhub_normalizar_titulo_serie(capa.titulo_serie),
        (SELECT count(*) FROM edicoes existente WHERE existente.serie_id = serie.id) DESC,
        serie.id
), edicoes_alvo AS (
    SELECT DISTINCT ON (serie.id)
        edicao.id AS edicao_id, serie.*
    FROM series_alvo serie
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    ORDER BY
        serie.id,
        CASE
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA') THEN 0
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1') THEN 1
            ELSE 2
        END,
        edicao.id
)
UPDATE edicoes edicao
SET titulo = alvo.titulo_edicao,
    descricao = CASE
        WHEN hqhub_normalizar_titulo_serie(alvo.titulo_serie) = hqhub_normalizar_titulo_serie('Justiça - Edição Definitiva')
            THEN 'Reúne Justice (2005) #1-12, de Alex Ross, Jim Krueger e Doug Braithwaite.'
        ELSE 'Reúne Kingdom Come #1-4 e material adicional, por Mark Waid e Alex Ross.'
    END,
    nome_volume = 'Edição Definitiva',
    data_publicacao = alvo.data_publicacao,
    url_capa = alvo.url_capa,
    codigo_barras = alvo.isbn,
    quantidade_paginas = alvo.paginas,
    formato = alvo.formato,
    fonte_externa = 'LOJISTAS_BRASILEIROS',
    id_externo = alvo.id_externo,
    url_origem = alvo.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
WHERE edicao.id = alvo.edicao_id;

WITH capas(titulo_serie, titulo_edicao, url_capa, isbn, paginas, formato, data_publicacao, id_externo, url_origem) AS (VALUES
    ('Justiça - Edição Definitiva', 'Justiça - Edição Definitiva',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/4/147258369-CAPA-INDOUG_1.png',
     '9788565484336', 492, '19,5 x 30,5 cm, colorido, capa dura', DATE '2017-10-01',
     'justica-edicao-definitiva-panini-v1',
     'https://www.comix.com.br/justica-edic-o-definitiva-30576.html'),
    ('Reino do Amanhã - Edição Definitiva', 'Reino do Amanhã - Edição Definitiva',
     'https://rika.vtexassets.com/arquivos/ids/271133/reino-do-amanha-ed-definitiva.jpg?v=635658307802270000',
     '9788565484640', 336, '19,5 x 30 cm, papel couché, colorido, capa dura', DATE '2013-10-01',
     'reino-do-amanha-edicao-definitiva-panini-v1',
     'https://www.rika.com.br/reino-do-amanha---edicao-definitiva15003992/p')
), series_alvo AS (
    SELECT DISTINCT ON (hqhub_normalizar_titulo_serie(capa.titulo_serie))
        serie.id, capa.*
    FROM capas capa
    JOIN series serie
      ON hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(capa.titulo_serie)
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
    ORDER BY
        hqhub_normalizar_titulo_serie(capa.titulo_serie),
        (SELECT count(*) FROM edicoes existente WHERE existente.serie_id = serie.id) DESC,
        serie.id
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA', serie.titulo_edicao,
    CASE
        WHEN hqhub_normalizar_titulo_serie(serie.titulo_serie) = hqhub_normalizar_titulo_serie('Justiça - Edição Definitiva')
            THEN 'Reúne Justice (2005) #1-12, de Alex Ross, Jim Krueger e Doug Braithwaite.'
        ELSE 'Reúne Kingdom Come #1-4 e material adicional, por Mark Waid e Alex Ross.'
    END,
    'Edição Definitiva', serie.data_publicacao, serie.url_capa, serie.isbn,
    serie.paginas, serie.formato, 'LOJISTAS_BRASILEIROS', serie.id_externo,
    serie.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM series_alvo serie
WHERE NOT EXISTS (
    SELECT 1 FROM edicoes existente WHERE existente.serie_id = serie.id
)
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
