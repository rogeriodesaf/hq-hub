-- Cadastra Monstro do Pantano por Alan Moore - Edicao Absoluta (Panini), em tres volumes.
-- Capas e metadados obtidos no catalogo oficial da Panini.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Monstro do Pântano por Alan Moore - Edição Absoluta',
    'Colecao completa em tres volumes da fase de Alan Moore em Swamp Thing, publicada pela Panini.',
    2021, 2023, 1, 'PANINI', 'AMOPA',
    'https://panini.com.br/monstro-do-pantano-por-alan-moore-vol-1-edicao-absoluta-amopa001r',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) IN (
            hqhub_normalizar_titulo_serie('Monstro do Pântano por Alan Moore - Edição Absoluta'),
            hqhub_normalizar_titulo_serie('Monstro do Pântano por Alan Moore')
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
          hqhub_normalizar_titulo_serie('Monstro do Pântano por Alan Moore - Edição Absoluta'),
          hqhub_normalizar_titulo_serie('Monstro do Pântano por Alan Moore')
      )
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AMOPA' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE series serie
SET titulo = 'Monstro do Pântano por Alan Moore - Edição Absoluta',
    descricao = 'Colecao completa em tres volumes da fase de Alan Moore em Swamp Thing, publicada pela Panini.',
    ano_inicio = 2021,
    ano_fim = 2023,
    fonte_externa = 'PANINI',
    id_externo = 'AMOPA',
    url_origem = 'https://panini.com.br/monstro-do-pantano-por-alan-moore-vol-1-edicao-absoluta-amopa001r',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH volumes(numero, subtitulo, data_publicacao, isbn, paginas, id_externo, url_origem, url_capa) AS (VALUES
    ('1', 'Edição Absoluta', DATE '2023-07-01', '9786555128390', 448, 'AMOPA001R',
     'https://panini.com.br/monstro-do-pantano-por-alan-moore-vol-1-edicao-absoluta-amopa001r',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_mlr3q4uadl14jb0niga579lu0g/-S897-FWEBP'),
    ('2', 'Edição Absoluta', DATE '2021-11-01', '9786559607594', 464, 'AMOPA002',
     'https://panini.com.br/monstro-do-pantano-por-alan-moore-vol-2-edicao-absoluta',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rh2a7a6qa53ulce660kpuop10t/-S897-FWEBP'),
    ('3', 'Edição Absoluta', DATE '2022-08-01', '9786525902821', 416, 'AMOPA003',
     'https://panini.com.br/monstro-do-pantano-por-alan-moore-vol-3-edicao-absoluta',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fh7a33gol11lt40u6170sqla13/-S897-FWEBP')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Monstro do Pântano por Alan Moore - Edição Absoluta')
    ORDER BY CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AMOPA' THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    volume.numero,
    'Monstro do Pântano por Alan Moore Vol. ' || volume.numero || ' - Edição Absoluta',
    'Volume ' || volume.numero || ' da edicao absoluta da fase de Alan Moore em Monstro do Pantano.',
    volume.subtitulo,
    volume.data_publicacao,
    volume.url_capa,
    volume.isbn,
    volume.paginas,
    'Capa dura, formato absoluto, colorido',
    'PANINI',
    volume.id_externo,
    volume.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
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
