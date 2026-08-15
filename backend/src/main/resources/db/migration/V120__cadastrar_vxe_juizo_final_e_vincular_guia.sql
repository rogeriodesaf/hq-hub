-- Cadastra/reaproveita VXE: Juízo Final (Panini), cria ou atualiza as
-- quatro edições brasileiras com suas capas e as vincula ao guia mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'VXE: Juízo Final',
    'Minissérie em quatro edições publicada pela Panini.',
    2023,
    2023,
    1,
    'PANINI',
    'PANINI-VXE-JUIZO-FINAL-V1',
    'https://panini.com.br/vxe-juizo-final-01',
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
            lower('VXE: Juízo Final'),
            lower('V.X.E.: Juízo Final'),
            lower('VXE - Juízo Final')
        )
        AND coalesce(existente.volume, 1) = 1
  );

WITH referencias(numero, titulo, url_capa, id_externo, url_origem) AS (VALUES
    ('1', 'VXE: Juízo Final 01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lrschlj96p2pd7ihhfv8sdoe6d/-S265-FWEBP', 'AVXEJ001', 'https://panini.com.br/vxe-juizo-final-01'),
    ('2', 'VXE: Juízo Final 02', 'https://tavernadorei.com.br/cdn/shop/files/VXE--Juizo-Final---Vol02.jpg?v=1755883419', 'AVXEJ002', 'https://panini.com.br/vxe-juizo-final-02'),
    ('3', 'VXE: Juízo Final 03', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e2io65ikp55jt2g47qvkkad816/-S265-FWEBP', 'AVXEJ003', 'https://panini.com.br/vxe-juizo-final-03'),
    ('4', 'VXE: Juízo Final 04', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_332ghs5ukl6p37c6af0km5887f/-S265-FWEBP', 'AVXEJ004', 'https://panini.com.br/vxe-juizo-final-04')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('VXE: Juízo Final'),
          lower('V.X.E.: Juízo Final'),
          lower('VXE - Juízo Final')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('VXE: Juízo Final') THEN 0 ELSE 1 END, serie.id
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
    'PANINI',
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

WITH referencias(numero, titulo, url_capa, id_externo, url_origem) AS (VALUES
    ('1', 'VXE: Juízo Final 01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lrschlj96p2pd7ihhfv8sdoe6d/-S265-FWEBP', 'AVXEJ001', 'https://panini.com.br/vxe-juizo-final-01'),
    ('2', 'VXE: Juízo Final 02', 'https://tavernadorei.com.br/cdn/shop/files/VXE--Juizo-Final---Vol02.jpg?v=1755883419', 'AVXEJ002', 'https://panini.com.br/vxe-juizo-final-02'),
    ('3', 'VXE: Juízo Final 03', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e2io65ikp55jt2g47qvkkad816/-S265-FWEBP', 'AVXEJ003', 'https://panini.com.br/vxe-juizo-final-03'),
    ('4', 'VXE: Juízo Final 04', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_332ghs5ukl6p37c6af0km5887f/-S265-FWEBP', 'AVXEJ004', 'https://panini.com.br/vxe-juizo-final-04')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('VXE: Juízo Final'),
          lower('V.X.E.: Juízo Final'),
          lower('VXE - Juízo Final')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('VXE: Juízo Final') THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = referencia.titulo,
    url_capa = referencia.url_capa,
    fonte_externa = 'PANINI',
    id_externo = referencia.id_externo,
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH referencias(numero, url_capa) AS (VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lrschlj96p2pd7ihhfv8sdoe6d/-S265-FWEBP'),
    ('2', 'https://tavernadorei.com.br/cdn/shop/files/VXE--Juizo-Final---Vol02.jpg?v=1755883419'),
    ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e2io65ikp55jt2g47qvkkad816/-S265-FWEBP'),
    ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_332ghs5ukl6p37c6af0km5887f/-S265-FWEBP')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = referencia.url_capa
FROM referencias referencia
WHERE lower(trim(item.titulo_referencia)) IN (
        lower('VXE: Juízo Final'),
        lower('V.X.E.: Juízo Final'),
        lower('VXE - Juízo Final')
      )
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
          lower('VXE: Juízo Final'),
          lower('V.X.E.: Juízo Final'),
          lower('VXE - Juízo Final')
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0')
    WHERE lower(trim(item.titulo_referencia)) IN (
          lower('VXE: Juízo Final'),
          lower('V.X.E.: Juízo Final'),
          lower('VXE - Juízo Final')
      )
      AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
      AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer BETWEEN 1 AND 4
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
