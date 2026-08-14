-- Cadastra/reaproveita a colecao A Era do X-Man (Panini), cria ou atualiza
-- seus seis volumes com capas brasileiras e os vincula a Ordem de Leitura
-- Mutante. As URLs sem o segmento de cache do Magento sao mais estaveis.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'A Era do X-Man',
    'Colecao em seis volumes publicada pela Panini.',
    2020,
    2020,
    1,
    'COMIX',
    'COMIX-A-ERA-DO-X-MAN-V1',
    'https://www.comix.com.br/era-do-x-man-volume-1.html',
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
            lower('A Era do X-Man'),
            lower('Era do X-Man'),
            lower('Era do X-Man, A')
        )
        AND coalesce(existente.volume, 1) = 1
  );

WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
    ('1', 'A Era do X-Man Vol. 1', 'https://www.comix.com.br/media/catalog/product/1/9/191238_900x900eraexmen.jpg', 'https://www.comix.com.br/era-do-x-man-volume-1.html'),
    ('2', 'A Era do X-Man Vol. 2', 'https://www.comix.com.br/media/catalog/product/2/0/204546_900x900aera.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-02.html'),
    ('3', 'A Era do X-Man Vol. 3', 'https://www.comix.com.br/media/catalog/product/2/0/205845_900x900era3.jpeg', 'https://www.comix.com.br/a-era-do-x-man-vol-03.html'),
    ('4', 'A Era do X-Man Vol. 4', 'https://www.comix.com.br/media/catalog/product/2/0/209627_900x900aerax.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-04.html'),
    ('5', 'A Era do X-Man Vol. 5', 'https://www.comix.com.br/media/catalog/product/a/e/aeradoexmen.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-05.html'),
    ('6', 'A Era do X-Man Vol. 6', 'https://www.comix.com.br/media/catalog/product/2/2/220225_900x900aera.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-06.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('A Era do X-Man'),
          lower('Era do X-Man'),
          lower('Era do X-Man, A')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('A Era do X-Man') THEN 0 ELSE 1 END, serie.id
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
    'COMIX-A-ERA-DO-X-MAN-' || referencia.numero,
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
    ('1', 'A Era do X-Man Vol. 1', 'https://www.comix.com.br/media/catalog/product/1/9/191238_900x900eraexmen.jpg', 'https://www.comix.com.br/era-do-x-man-volume-1.html'),
    ('2', 'A Era do X-Man Vol. 2', 'https://www.comix.com.br/media/catalog/product/2/0/204546_900x900aera.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-02.html'),
    ('3', 'A Era do X-Man Vol. 3', 'https://www.comix.com.br/media/catalog/product/2/0/205845_900x900era3.jpeg', 'https://www.comix.com.br/a-era-do-x-man-vol-03.html'),
    ('4', 'A Era do X-Man Vol. 4', 'https://www.comix.com.br/media/catalog/product/2/0/209627_900x900aerax.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-04.html'),
    ('5', 'A Era do X-Man Vol. 5', 'https://www.comix.com.br/media/catalog/product/a/e/aeradoexmen.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-05.html'),
    ('6', 'A Era do X-Man Vol. 6', 'https://www.comix.com.br/media/catalog/product/2/2/220225_900x900aera.jpg', 'https://www.comix.com.br/a-era-do-x-man-vol-06.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('A Era do X-Man'),
          lower('Era do X-Man'),
          lower('Era do X-Man, A')
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY CASE WHEN lower(trim(serie.titulo)) = lower('A Era do X-Man') THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = referencia.titulo,
    url_capa = referencia.url_capa,
    fonte_externa = 'COMIX',
    id_externo = coalesce(edicao.id_externo, 'COMIX-A-ERA-DO-X-MAN-' || referencia.numero),
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH referencias(numero, url_capa) AS (VALUES
    ('1', 'https://www.comix.com.br/media/catalog/product/1/9/191238_900x900eraexmen.jpg'),
    ('2', 'https://www.comix.com.br/media/catalog/product/2/0/204546_900x900aera.jpg'),
    ('3', 'https://www.comix.com.br/media/catalog/product/2/0/205845_900x900era3.jpeg'),
    ('4', 'https://www.comix.com.br/media/catalog/product/2/0/209627_900x900aerax.jpg'),
    ('5', 'https://www.comix.com.br/media/catalog/product/a/e/aeradoexmen.jpg'),
    ('6', 'https://www.comix.com.br/media/catalog/product/2/2/220225_900x900aera.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = referencia.url_capa
FROM referencias referencia
WHERE lower(trim(item.titulo_referencia)) = lower('A Era do X-Man')
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
          lower('A Era do X-Man'),
          lower('Era do X-Man'),
          lower('Era do X-Man, A')
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0')
    WHERE lower(trim(item.titulo_referencia)) = lower('A Era do X-Man')
      AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '1'
      AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer BETWEEN 1 AND 6
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
