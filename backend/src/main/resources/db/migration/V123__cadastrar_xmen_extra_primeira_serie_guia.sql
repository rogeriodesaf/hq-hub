-- Cadastra/reaproveita X-Men Extra (1ª série, Panini), adiciona as capas das
-- edições usadas pela ordem mutante e cria vínculos determinísticos no guia.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Men Extra',
    'Primeira série brasileira de X-Men Extra publicada pela Panini.',
    2002,
    2013,
    1,
    'RIKA',
    'RIKA-X-MEN-EXTRA-V1',
    'https://www.rika.com.br/x-men-extra--08315003434/p',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      WHERE existente.editora_id = editora.id
        AND lower(trim(existente.titulo)) = lower('X-Men Extra')
        AND coalesce(existente.volume, 1) = 1
  );

WITH referencias(numero, titulo, url_capa, fonte, id_externo, url_origem) AS (VALUES
    (
        '83', 'X-Men Extra nº 83',
        'https://rika.vtexassets.com/arquivos/ids/223240/-herois_panini-x-men-extra-083.jpg?v=635316273295900000',
        'RIKA', 'RIKA-X-MEN-EXTRA-083',
        'https://www.rika.com.br/x-men-extra--08315003434/p'
    ),
    (
        '84', 'X-Men Extra nº 84',
        'https://rika.vtexassets.com/arquivos/ids/223241/-herois_panini-x-men-extra-084.jpg?v=635316273316230000',
        'RIKA', 'RIKA-X-MEN-EXTRA-084',
        'https://www.rika.com.br/x-men-extra--08415003435/p'
    ),
    (
        '85', 'X-Men Extra nº 85',
        'https://rika.vtexassets.com/arquivos/ids/223242/-herois_panini-x-men-extra-085.jpg?v=635316273341330000',
        'RIKA', 'RIKA-X-MEN-EXTRA-085',
        'https://www.rika.com.br/x-men-extra--08515003436/p'
    ),
    (
        '126', 'X-Men Extra nº 126',
        'https://www.comix.com.br/media/catalog/product/p/a/panini_xmenextra_126.jpg',
        'COMIX', 'COMIX-X-MEN-EXTRA-126',
        'https://www.comix.com.br/x-men-extra-n-126.html'
    )
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) = lower('X-Men Extra')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    referencia.numero,
    referencia.titulo,
    referencia.url_capa,
    referencia.fonte,
    referencia.id_externo,
    referencia.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = referencia.numero
);

WITH referencias(numero, titulo, url_capa, fonte, id_externo, url_origem) AS (VALUES
    (
        '83', 'X-Men Extra nº 83',
        'https://rika.vtexassets.com/arquivos/ids/223240/-herois_panini-x-men-extra-083.jpg?v=635316273295900000',
        'RIKA', 'RIKA-X-MEN-EXTRA-083',
        'https://www.rika.com.br/x-men-extra--08315003434/p'
    ),
    (
        '84', 'X-Men Extra nº 84',
        'https://rika.vtexassets.com/arquivos/ids/223241/-herois_panini-x-men-extra-084.jpg?v=635316273316230000',
        'RIKA', 'RIKA-X-MEN-EXTRA-084',
        'https://www.rika.com.br/x-men-extra--08415003435/p'
    ),
    (
        '85', 'X-Men Extra nº 85',
        'https://rika.vtexassets.com/arquivos/ids/223242/-herois_panini-x-men-extra-085.jpg?v=635316273341330000',
        'RIKA', 'RIKA-X-MEN-EXTRA-085',
        'https://www.rika.com.br/x-men-extra--08515003436/p'
    ),
    (
        '126', 'X-Men Extra nº 126',
        'https://www.comix.com.br/media/catalog/product/p/a/panini_xmenextra_126.jpg',
        'COMIX', 'COMIX-X-MEN-EXTRA-126',
        'https://www.comix.com.br/x-men-extra-n-126.html'
    )
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) = lower('X-Men Extra')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = referencia.titulo,
    url_capa = referencia.url_capa,
    fonte_externa = referencia.fonte,
    id_externo = referencia.id_externo,
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH vinculos(posicao, id_externo, url_capa) AS (VALUES
    (178, 'RIKA-X-MEN-EXTRA-083', 'https://rika.vtexassets.com/arquivos/ids/223240/-herois_panini-x-men-extra-083.jpg?v=635316273295900000'),
    (179, 'RIKA-X-MEN-EXTRA-084', 'https://rika.vtexassets.com/arquivos/ids/223241/-herois_panini-x-men-extra-084.jpg?v=635316273316230000'),
    (180, 'RIKA-X-MEN-EXTRA-085', 'https://rika.vtexassets.com/arquivos/ids/223242/-herois_panini-x-men-extra-085.jpg?v=635316273341330000'),
    (203, 'COMIX-X-MEN-EXTRA-126', 'https://www.comix.com.br/media/catalog/product/p/a/panini_xmenextra_126.jpg')
), edicoes_alvo AS (
    SELECT
        vinculo.posicao,
        vinculo.url_capa,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON edicao.id_externo = vinculo.id_externo
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.edicao_id,
    url_capa_referencia = alvo.url_capa
FROM edicoes_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = alvo.posicao
  AND alvo.prioridade = 1;

-- Fallback de capa independente do vínculo com o catálogo.
WITH capas(posicao, url_capa) AS (VALUES
    (178, 'https://rika.vtexassets.com/arquivos/ids/223240/-herois_panini-x-men-extra-083.jpg?v=635316273295900000'),
    (179, 'https://rika.vtexassets.com/arquivos/ids/223241/-herois_panini-x-men-extra-084.jpg?v=635316273316230000'),
    (180, 'https://rika.vtexassets.com/arquivos/ids/223242/-herois_panini-x-men-extra-085.jpg?v=635316273341330000'),
    (203, 'https://www.comix.com.br/media/catalog/product/p/a/panini_xmenextra_126.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = capa.url_capa
FROM capas capa
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = capa.posicao;
