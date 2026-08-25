-- Cadastra Asa Noturna: Ano Um (Panini, 2024) e vincula a edicao
-- ao item correspondente do guia cronologico do Batman.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Asa Noturna: Ano Um',
    'Edicao brasileira de Nightwing: Year One, reunindo Nightwing (1996) #101-106.',
    2024, 2024, 1, 'PANINI', 'AANAU',
    'https://panini.com.br/asa-noturna-ano-um',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um')
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
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um')
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AANAU' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = 'Asa Noturna: Ano Um',
    descricao = 'Reune Nightwing (1996) #101-106.',
    nome_volume = 'Ano Um',
    data_publicacao = DATE '2024-07-30',
    url_capa = 'https://spider145hqs.wordpress.com/wp-content/uploads/2024/09/asanoturna_anoum_panini_03092024.jpg',
    codigo_barras = '9786525915364',
    quantidade_paginas = 152,
    formato = 'Capa cartao, 17 x 26 cm',
    fonte_externa = 'SPIDER145',
    id_externo = 'AANAU001',
    url_origem = 'https://spider145hqs.com/2024/09/03/asa-noturna-ano-um/',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND (
      upper(coalesce(edicao.id_externo, '')) = 'AANAU001'
      OR hqhub_normalizar_titulo_serie(edicao.titulo) =
          hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um')
  );

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um')
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AANAU' THEN 0 ELSE 1 END,
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
    'UNICA', 'Asa Noturna: Ano Um', 'Reune Nightwing (1996) #101-106.',
    'Ano Um', DATE '2024-07-30',
    'https://spider145hqs.wordpress.com/wp-content/uploads/2024/09/asanoturna_anoum_panini_03092024.jpg',
    '9786525915364', 152, 'Capa cartao, 17 x 26 cm', 'SPIDER145', 'AANAU001',
    'https://spider145hqs.com/2024/09/03/asa-noturna-ano-um/', serie.id,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND (
          upper(coalesce(existente.id_externo, '')) = 'AANAU001'
          OR hqhub_normalizar_titulo_serie(existente.titulo) =
              hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um')
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
    WHERE upper(coalesce(edicao.id_externo, '')) = 'AANAU001'
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a Asa Noturna: Ano Um da Panini (AANAU001).',
    ano_referencia = 2024
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Asa Noturna: Ano Um');
