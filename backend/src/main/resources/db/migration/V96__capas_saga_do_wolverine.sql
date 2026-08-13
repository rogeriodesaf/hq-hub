-- Capas conferidas da serie A Saga do Wolverine (Panini), volumes 1 a 11.
-- A capa do volume 12 ainda nao foi publicada corretamente pelos lojistas.
WITH referencias(numero, url_capa, url_origem) AS (VALUES
    ('1',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1618171/1089838.jpg?v=638452541052670000', 'https://panini.com.br/a-saga-do-wolverine-01-asawv001r'),
    ('2',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1631270/1098054.jpg?v=638503437154170000', 'https://panini.com.br/a-saga-do-wolverine-02'),
    ('3',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1643827/1105217.jpg?v=638558001222130000', 'https://panini.com.br/a-saga-do-wolverine-03'),
    ('4',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1656590/1113552.jpg?v=638615757158330000', 'https://panini.com.br/a-saga-do-wolverine-04'),
    ('5',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1667652/1120425.jpg?v=638666079176100000', 'https://panini.com.br/a-saga-do-wolverine-05'),
    ('6',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1678061/1127055.jpg?v=638725630358670000', 'https://panini.com.br/a-saga-do-wolverine-06'),
    ('7',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1688813/1133419.jpg?v=638773900335230000', 'https://panini.com.br/a-saga-do-wolverine-07'),
    ('8',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1700228/1140961.jpg?v=638823034462100000', 'https://panini.com.br/a-saga-do-wolverine-08'),
    ('9',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1716252/1152184.jpg?v=638887174374800000', 'https://panini.com.br/a-saga-do-wolverine-09'),
    ('10', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1732525/1163009.jpg?v=638941778668600000', 'https://panini.com.br/a-saga-do-wolverine-10'),
    ('11', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1761316/1186385.jpg?v=639002263961970000', 'https://panini.com.br/a-saga-do-wolverine-11')
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    referencia.numero,
    'A Saga do Wolverine ' || lpad(referencia.numero, 2, '0'),
    referencia.url_capa,
    'PANINI',
    referencia.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
JOIN series serie
  ON lower(trim(serie.titulo)) IN (
       lower('A Saga do Wolverine'),
       lower('Saga do Wolverine, A'),
       lower('Saga de Wolverine, A')
     )
 AND coalesce(serie.volume, 1) = 1
JOIN editoras editora
  ON editora.id = serie.editora_id
 AND lower(trim(editora.nome)) = lower('Panini')
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = referencia.numero
);

WITH referencias(numero, url_capa, url_origem) AS (VALUES
    ('1',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1618171/1089838.jpg?v=638452541052670000', 'https://panini.com.br/a-saga-do-wolverine-01-asawv001r'),
    ('2',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1631270/1098054.jpg?v=638503437154170000', 'https://panini.com.br/a-saga-do-wolverine-02'),
    ('3',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1643827/1105217.jpg?v=638558001222130000', 'https://panini.com.br/a-saga-do-wolverine-03'),
    ('4',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1656590/1113552.jpg?v=638615757158330000', 'https://panini.com.br/a-saga-do-wolverine-04'),
    ('5',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1667652/1120425.jpg?v=638666079176100000', 'https://panini.com.br/a-saga-do-wolverine-05'),
    ('6',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1678061/1127055.jpg?v=638725630358670000', 'https://panini.com.br/a-saga-do-wolverine-06'),
    ('7',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1688813/1133419.jpg?v=638773900335230000', 'https://panini.com.br/a-saga-do-wolverine-07'),
    ('8',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1700228/1140961.jpg?v=638823034462100000', 'https://panini.com.br/a-saga-do-wolverine-08'),
    ('9',  'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1716252/1152184.jpg?v=638887174374800000', 'https://panini.com.br/a-saga-do-wolverine-09'),
    ('10', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1732525/1163009.jpg?v=638941778668600000', 'https://panini.com.br/a-saga-do-wolverine-10'),
    ('11', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1761316/1186385.jpg?v=639002263961970000', 'https://panini.com.br/a-saga-do-wolverine-11')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'PANINI',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(serie.titulo)) IN (
       lower('A Saga do Wolverine'),
       lower('Saga do Wolverine, A'),
       lower('Saga de Wolverine, A')
      )
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) IN (
           lower('A Saga do Wolverine'),
           lower('Saga do Wolverine, A'),
           lower('Saga de Wolverine, A')
         )
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
