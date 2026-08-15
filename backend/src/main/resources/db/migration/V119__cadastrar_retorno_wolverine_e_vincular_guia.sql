-- Cadastra/reaproveita O Retorno de Wolverine (Panini), cria ou atualiza as
-- seis edicoes brasileiras com suas capas e as vincula ao guia mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'O Retorno de Wolverine',
    'Minisserie em seis edicoes publicada pela Panini.',
    2019,
    2019,
    1,
    'COMIX',
    'COMIX-O-RETORNO-DE-WOLVERINE-V1',
    'https://www.comix.com.br/o-retorno-de-wolverine-n-1.html',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      WHERE existente.editora_id = editora.id
        AND lower(trim(existente.titulo)) IN (
            lower('O Retorno de Wolverine'),
            lower('Retorno de Wolverine, O'),
            lower('Retorno de Wolverine')
        )
        AND coalesce(existente.volume, 1) = 1
  );

WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
    ('1', 'O Retorno de Wolverine nº 1', 'https://www.comix.com.br/media/catalog/product/w/o/wolverine_1.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-1.html'),
    ('2', 'O Retorno de Wolverine nº 2', 'https://www.comix.com.br/media/catalog/product/r/e/retorno2.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-2.html'),
    ('3', 'O Retorno de Wolverine nº 3', 'https://www.comix.com.br/media/catalog/product/r/e/retorno3.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-3.html'),
    ('4', 'O Retorno de Wolverine nº 4', 'https://www.comix.com.br/media/catalog/product/r/e/retorno4.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-4.html'),
    ('5', 'O Retorno de Wolverine nº 5', 'https://www.comix.com.br/media/catalog/product/9/1/91akoal_ojl.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-5.html'),
    ('6', 'O Retorno de Wolverine nº 6', 'https://www.comix.com.br/media/catalog/product/1/7/177836_900x900.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-6.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('O Retorno de Wolverine'),
          lower('Retorno de Wolverine, O'),
          lower('Retorno de Wolverine')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('O Retorno de Wolverine') THEN 0 ELSE 1 END, serie.id
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
    'COMIX',
    'COMIX-O-RETORNO-DE-WOLVERINE-' || referencia.numero,
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

WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
    ('1', 'O Retorno de Wolverine nº 1', 'https://www.comix.com.br/media/catalog/product/w/o/wolverine_1.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-1.html'),
    ('2', 'O Retorno de Wolverine nº 2', 'https://www.comix.com.br/media/catalog/product/r/e/retorno2.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-2.html'),
    ('3', 'O Retorno de Wolverine nº 3', 'https://www.comix.com.br/media/catalog/product/r/e/retorno3.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-3.html'),
    ('4', 'O Retorno de Wolverine nº 4', 'https://www.comix.com.br/media/catalog/product/r/e/retorno4.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-4.html'),
    ('5', 'O Retorno de Wolverine nº 5', 'https://www.comix.com.br/media/catalog/product/9/1/91akoal_ojl.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-5.html'),
    ('6', 'O Retorno de Wolverine nº 6', 'https://www.comix.com.br/media/catalog/product/1/7/177836_900x900.jpg', 'https://www.comix.com.br/o-retorno-de-wolverine-n-6.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('O Retorno de Wolverine'),
          lower('Retorno de Wolverine, O'),
          lower('Retorno de Wolverine')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('O Retorno de Wolverine') THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = referencia.titulo,
    url_capa = referencia.url_capa,
    fonte_externa = 'COMIX',
    id_externo = 'COMIX-O-RETORNO-DE-WOLVERINE-' || referencia.numero,
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH referencias(numero, url_capa) AS (VALUES
    ('1', 'https://www.comix.com.br/media/catalog/product/w/o/wolverine_1.jpg'),
    ('2', 'https://www.comix.com.br/media/catalog/product/r/e/retorno2.jpg'),
    ('3', 'https://www.comix.com.br/media/catalog/product/r/e/retorno3.jpg'),
    ('4', 'https://www.comix.com.br/media/catalog/product/r/e/retorno4.jpg'),
    ('5', 'https://www.comix.com.br/media/catalog/product/9/1/91akoal_ojl.jpg'),
    ('6', 'https://www.comix.com.br/media/catalog/product/1/7/177836_900x900.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = referencia.url_capa
FROM referencias referencia
WHERE lower(trim(item.titulo_referencia)) = lower('O Retorno de Wolverine')
  AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
  AND ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = referencia.numero;

WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM itens_ordem_leitura item
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) IN (
          lower('O Retorno de Wolverine'),
          lower('Retorno de Wolverine, O'),
          lower('Retorno de Wolverine')
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0')
    WHERE lower(trim(item.titulo_referencia)) = lower('O Retorno de Wolverine')
      AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
      AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer BETWEEN 1 AND 6
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
