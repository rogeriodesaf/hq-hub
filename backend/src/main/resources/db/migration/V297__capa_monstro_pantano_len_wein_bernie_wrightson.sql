-- Cadastra/atualiza a edicao absoluta de Monstro do Pantano por Len Wein e Bernie Wrightson.
-- Capa e metadados obtidos no catalogo oficial da Panini.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta',
    'Edicao absoluta com a origem e as primeiras historias do Monstro do Pantano por Len Wein e Bernie Wrightson.',
    2023, 2023, 1, 'PANINI', 'AWEIN',
    'https://panini.com.br/monstro-do-pantano-por-lein-wein-e-bernie-wrightson-edicao-absoluta',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta')
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
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta')
    ORDER BY
        CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AWEIN' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE series serie
SET titulo = 'Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta',
    descricao = 'Edicao absoluta com a origem e as primeiras historias do Monstro do Pantano por Len Wein e Bernie Wrightson.',
    ano_inicio = 2023,
    ano_fim = 2023,
    fonte_externa = 'PANINI',
    id_externo = 'AWEIN',
    url_origem = 'https://panini.com.br/monstro-do-pantano-por-lein-wein-e-bernie-wrightson-edicao-absoluta',
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
          hqhub_normalizar_titulo_serie('Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta')
    ORDER BY CASE WHEN upper(coalesce(serie.id_externo, '')) = 'AWEIN' THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Monstro do Pântano por Len Wein e Bernie Wrightson - Edição Absoluta',
    'Reune House of Secrets #92 e Swamp Thing #1-13.',
    'Edição Absoluta',
    DATE '2023-09-08',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e75k0h2uu92pj7l1m3dak0s57h/-S897-FWEBP',
    '9786525907680',
    344,
    'Capa dura, 20,5 x 31 cm, colorido',
    'PANINI',
    'AWEIN001',
    'https://panini.com.br/monstro-do-pantano-por-lein-wein-e-bernie-wrightson-edicao-absoluta',
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
