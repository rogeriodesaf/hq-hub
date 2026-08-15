-- Cadastra três publicações Panini, atualiza suas capas e vincula as
-- edições únicas às entradas correspondentes do guia mutante.

WITH referencias(
    titulo_serie, descricao, ano, volume, id_serie, url_origem,
    aliases_serie
) AS (VALUES
    (
        'X-Men: Carrascos',
        'Primeiro volume da fase dos Carrascos escrita por Steve Orlando.',
        2023, 1, 'PANINI-X-MEN-CARRASCOS-V1',
        'https://panini.com.br/x-men-carrascos-01',
        ARRAY[lower('X-Men: Carrascos'), lower('Carrascos')]
    ),
    (
        'A Vida de Wolverine',
        'Edição especial que apresenta cronologicamente a história de Logan.',
        2024, 1, 'PANINI-A-VIDA-DE-WOLVERINE-V1',
        'https://panini.com.br/a-vida-de-wolverine',
        ARRAY[lower('A Vida de Wolverine'), lower('A Vida do Wolverine')]
    ),
    (
        'Xavier: Caçado - Ômega',
        'Edição especial que conclui a saga Xavier: Caçado.',
        2026, 1, 'PANINI-XAVIER-CACADO-OMEGA-V1',
        'https://panini.com.br/xavier-cacado-omega',
        ARRAY[lower('Xavier: Caçado - Ômega'), lower('Xavier: Caçado Ômega')]
    )
)
INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    referencia.titulo_serie,
    referencia.descricao,
    referencia.ano,
    referencia.ano,
    referencia.volume,
    'PANINI',
    referencia.id_serie,
    referencia.url_origem,
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN editoras editora
WHERE lower(trim(editora.nome)) = lower('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      WHERE existente.editora_id = editora.id
        AND hqhub_normalizar_titulo_serie(existente.titulo) = ANY (
            ARRAY(
                SELECT hqhub_normalizar_titulo_serie(alias)
                FROM unnest(referencia.aliases_serie) AS alias
            )
        )
        AND coalesce(existente.volume, 1) = referencia.volume
  );

WITH referencias(
    titulo_serie, aliases_serie, numero, titulo_edicao, url_capa,
    id_edicao, url_origem
) AS (VALUES
    (
        'X-Men: Carrascos', ARRAY[lower('X-Men: Carrascos'), lower('Carrascos')],
        '1', 'X-Men: Carrascos 01',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdencqndc15r57fiqqdnlld126/-S265-FWEBP',
        'AXMCA001', 'https://panini.com.br/x-men-carrascos-01'
    ),
    (
        'A Vida de Wolverine', ARRAY[lower('A Vida de Wolverine'), lower('A Vida do Wolverine')],
        '1', 'A Vida de Wolverine',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0kp44d1n8l18v1jcj3guv16q7q/-S265-FWEBP',
        'AVWOL001', 'https://panini.com.br/a-vida-de-wolverine'
    ),
    (
        'Xavier: Caçado - Ômega', ARRAY[lower('Xavier: Caçado - Ômega'), lower('Xavier: Caçado Ômega')],
        '1', 'Xavier: Caçado - Ômega',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fe685752f11t91brcculec2214/-S265-FWEBP',
        'AXOME001', 'https://panini.com.br/xavier-cacado-omega'
    )
), series_alvo AS (
    SELECT referencia.*, serie.id AS serie_id,
           row_number() OVER (
               PARTITION BY referencia.id_edicao
               ORDER BY CASE
                            WHEN hqhub_normalizar_titulo_serie(serie.titulo) =
                                 hqhub_normalizar_titulo_serie(referencia.titulo_serie)
                            THEN 0 ELSE 1
                        END,
                        serie.id
           ) AS prioridade
    FROM referencias referencia
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = ANY (
         ARRAY(
             SELECT hqhub_normalizar_titulo_serie(alias)
             FROM unnest(referencia.aliases_serie) AS alias
         )
     )
     AND coalesce(serie.volume, 1) = 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    alvo.numero, alvo.titulo_edicao, alvo.url_capa, 'PANINI', alvo.id_edicao,
    alvo.url_origem, alvo.serie_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM series_alvo alvo
WHERE alvo.prioridade = 1
  AND NOT EXISTS (
      SELECT 1
      FROM edicoes existente
      WHERE existente.serie_id = alvo.serie_id
        AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = alvo.numero
  );

WITH referencias(aliases_serie, numero, titulo_edicao, url_capa, id_edicao, url_origem) AS (VALUES
    (
        ARRAY[lower('X-Men: Carrascos'), lower('Carrascos')], '1', 'X-Men: Carrascos 01',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdencqndc15r57fiqqdnlld126/-S265-FWEBP',
        'AXMCA001', 'https://panini.com.br/x-men-carrascos-01'
    ),
    (
        ARRAY[lower('A Vida de Wolverine'), lower('A Vida do Wolverine')], '1', 'A Vida de Wolverine',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0kp44d1n8l18v1jcj3guv16q7q/-S265-FWEBP',
        'AVWOL001', 'https://panini.com.br/a-vida-de-wolverine'
    ),
    (
        ARRAY[lower('Xavier: Caçado - Ômega'), lower('Xavier: Caçado Ômega')], '1', 'Xavier: Caçado - Ômega',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fe685752f11t91brcculec2214/-S265-FWEBP',
        'AXOME001', 'https://panini.com.br/xavier-cacado-omega'
    )
)
UPDATE edicoes edicao
SET titulo = referencia.titulo_edicao,
    url_capa = referencia.url_capa,
    fonte_externa = 'PANINI',
    id_externo = referencia.id_edicao,
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia
JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
JOIN series serie
  ON serie.editora_id = editora.id
 AND hqhub_normalizar_titulo_serie(serie.titulo) = ANY (
     ARRAY(
         SELECT hqhub_normalizar_titulo_serie(alias)
         FROM unnest(referencia.aliases_serie) AS alias
     )
 )
 AND coalesce(serie.volume, 1) = 1
WHERE edicao.serie_id = serie.id
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH referencias(titulo_guia, url_capa) AS (VALUES
    ('Carrascos', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdencqndc15r57fiqqdnlld126/-S265-FWEBP'),
    ('A Vida de Wolverine', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0kp44d1n8l18v1jcj3guv16q7q/-S265-FWEBP'),
    ('Xavier: Caçado Ômega', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fe685752f11t91brcculec2214/-S265-FWEBP')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = referencia.url_capa
FROM referencias referencia
WHERE lower(trim(item.titulo_referencia)) = lower(referencia.titulo_guia)
  AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
  AND ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = '1';

WITH referencias(titulo_guia, aliases_serie) AS (VALUES
    ('Carrascos', ARRAY[lower('X-Men: Carrascos'), lower('Carrascos')]),
    ('A Vida de Wolverine', ARRAY[lower('A Vida de Wolverine'), lower('A Vida do Wolverine')]),
    ('Xavier: Caçado Ômega', ARRAY[lower('Xavier: Caçado - Ômega'), lower('Xavier: Caçado Ômega')])
), candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_guia)
     AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
     AND ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = '1'
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = ANY (
         ARRAY(
             SELECT hqhub_normalizar_titulo_serie(alias)
             FROM unnest(referencia.aliases_serie) AS alias
         )
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1'
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
