-- Cadastra Robin & Batman (Panini, 2022), aplica a capa oficial e vincula a
-- edicao ao guia cronologico do Batman.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Robin & Batman',
    'Minisserie de Jeff Lemire e Dustin Nguyen sobre os primeiros dias de Dick Grayson como Robin.',
    2022,
    2022,
    1,
    'PANINI',
    'ASPER',
    'https://panini.com.br/robin-e-batman',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) IN (
            hqhub_normalizar_titulo_serie('Robin & Batman'),
            hqhub_normalizar_titulo_serie('Robin E Batman')
        )
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Robin & Batman'),
          hqhub_normalizar_titulo_serie('Robin E Batman')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'ASPER' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = 'Robin & Batman',
    descricao = 'Edicao brasileira que reune Robin & Batman (2022) 1 a 3.',
    nome_volume = 'Volume Unico',
    data_publicacao = DATE '2022-09-01',
    url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_l2tn980sd947n3fmg6umd91g54/-S897-f.webp',
    codigo_barras = '9786525900209',
    quantidade_paginas = 144,
    formato = 'Capa dura, formato americano (17 x 26 cm)',
    fonte_externa = 'PANINI',
    id_externo = 'ASPER001',
    url_origem = 'https://panini.com.br/robin-e-batman',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND (
      upper(coalesce(edicao.id_externo, '')) = 'ASPER001'
      OR hqhub_normalizar_titulo_serie(edicao.titulo) IN (
          hqhub_normalizar_titulo_serie('Robin & Batman'),
          hqhub_normalizar_titulo_serie('Robin E Batman')
      )
  );

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Robin & Batman'),
          hqhub_normalizar_titulo_serie('Robin E Batman')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'ASPER' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Robin & Batman',
    'Edicao brasileira que reune Robin & Batman (2022) 1 a 3.',
    'Volume Unico',
    DATE '2022-09-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_l2tn980sd947n3fmg6umd91g54/-S897-f.webp',
    '9786525900209',
    144,
    'Capa dura, formato americano (17 x 26 cm)',
    'PANINI',
    'ASPER001',
    'https://panini.com.br/robin-e-batman',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND (
          upper(coalesce(existente.id_externo, '')) = 'ASPER001'
          OR hqhub_normalizar_titulo_serie(existente.titulo) IN (
              hqhub_normalizar_titulo_serie('Robin & Batman'),
              hqhub_normalizar_titulo_serie('Robin E Batman')
          )
      )
)
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

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    WHERE upper(coalesce(edicao.id_externo, '')) = 'ASPER001'
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a edicao brasileira Robin & Batman da Panini (referencia ASPER001).',
    ano_referencia = 2022
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Robin & Batman');
