-- Cadastra Batman: Trilogia do Demonio - Edicao de Luxo (Panini, 2024)
-- e vincula a edicao ao guia cronologico do Batman.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Batman: Trilogia do Demônio - Edição de Luxo',
    'Edicao de luxo que reune O Filho do Demonio, A Noiva do Demonio e O Nascimento do Demonio.',
    2024, 2024, 1, 'PANINI', 'ADDDE',
    'https://panini.com.br/batman-trilogia-do-demonio',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) IN (
            hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio - Edição de Luxo'),
            hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio'),
            hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio')
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
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio - Edição de Luxo'),
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio'),
          hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'ADDDE' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = 'Batman: Trilogia do Demônio - Edição de Luxo',
    descricao = 'Reune Batman: Son of the Demon, Bride of the Demon e Birth of the Demon.',
    nome_volume = 'Edição de Luxo',
    data_publicacao = DATE '2024-04-01',
    url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_d02n3cuda96kvamk2n1ourr728/-S897-f.webp',
    codigo_barras = '9786525918150',
    quantidade_paginas = 304,
    formato = 'Capa dura, edição de luxo',
    fonte_externa = 'PANINI',
    id_externo = 'ADDDE001',
    url_origem = 'https://panini.com.br/batman-trilogia-do-demonio',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND (
      upper(coalesce(edicao.id_externo, '')) = 'ADDDE001'
      OR hqhub_normalizar_titulo_serie(edicao.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio - Edição de Luxo'),
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio'),
          hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio')
      )
  );

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio - Edição de Luxo'),
          hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio'),
          hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'ADDDE' THEN 0 ELSE 1 END,
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
    'UNICA', 'Batman: Trilogia do Demônio - Edição de Luxo',
    'Reune Batman: Son of the Demon, Bride of the Demon e Birth of the Demon.',
    'Edição de Luxo', DATE '2024-04-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_d02n3cuda96kvamk2n1ourr728/-S897-f.webp',
    '9786525918150', 304, 'Capa dura, edição de luxo', 'PANINI', 'ADDDE001',
    'https://panini.com.br/batman-trilogia-do-demonio', serie.id,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE NOT EXISTS (
    SELECT 1 FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND (
          upper(coalesce(existente.id_externo, '')) = 'ADDDE001'
          OR hqhub_normalizar_titulo_serie(existente.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio - Edição de Luxo'),
              hqhub_normalizar_titulo_serie('Batman: Trilogia do Demônio'),
              hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio')
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
    WHERE upper(coalesce(edicao.id_externo, '')) = 'ADDDE001'
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a Batman: Trilogia do Demonio - Edicao de Luxo da Panini (ADDDE001).',
    ano_referencia = 2024
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Batman: A Trilogia do Demônio');
