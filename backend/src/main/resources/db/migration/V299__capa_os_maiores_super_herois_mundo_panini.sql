-- Cadastra Os Maiores Super-Herois do Mundo - Edicao Absoluta (Panini, 2022).
-- A capa veio da Comix; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Os Maiores Super-Heróis do Mundo - Edição Absoluta',
    'Edicao absoluta que reune as seis graphic novels de Paul Dini e Alex Ross sobre os herois da DC.',
    2022, 2022, 1, 'COMIX', 'AMAIO',
    'https://www.comix.com.br/os-maiores-super-herois-do-mundo-edicao-absoluta.html',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) IN (
            hqhub_normalizar_titulo_serie('Os Maiores Super-Heróis do Mundo - Edição Absoluta'),
            hqhub_normalizar_titulo_serie('Os Maiores Super-Heróis do Mundo')
        )
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Os Maiores Super-Heróis do Mundo - Edição Absoluta'),
          hqhub_normalizar_titulo_serie('Os Maiores Super-Heróis do Mundo')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AMAIO' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE series serie
SET titulo = 'Os Maiores Super-Heróis do Mundo - Edição Absoluta',
    descricao = 'Edicao absoluta que reune as seis graphic novels de Paul Dini e Alex Ross sobre os herois da DC.',
    ano_inicio = 2022,
    ano_fim = 2022,
    fonte_externa = 'COMIX',
    id_externo = 'AMAIO',
    url_origem = 'https://www.comix.com.br/os-maiores-super-herois-do-mundo-edicao-absoluta.html',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Os Maiores Super-Heróis do Mundo - Edição Absoluta')
    ORDER BY CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AMAIO' THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Os Maiores Super-Heróis do Mundo - Edição Absoluta',
    'Reune seis graphic novels de Paul Dini e Alex Ross estreladas pelos maiores herois da DC.',
    'Edição Absoluta',
    DATE '2022-11-01',
    'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/a/b/absoluta1.jpg',
    '9786525900339',
    396,
    'Capa dura, 20,5 x 31 cm, colorido',
    'COMIX',
    'AMAIO001',
    'https://www.comix.com.br/os-maiores-super-herois-do-mundo-edicao-absoluta.html',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
