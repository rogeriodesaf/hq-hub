-- Vincula especiais mutantes a edicoes que ja existem no catalogo.

-- Minisséries com o numero da edicao indicado na ordem de leitura.
WITH referencias(titulo, editora_nome, volume, numero) AS (VALUES
    ('As Novas Aventuras de Ciclope e Fênix', 'Abril', 1, '1'),
    ('As Novas Aventuras de Ciclope e Fênix', 'Abril', 1, '2'),
    ('A Ascensão do Apocalipse', 'Abril', 1, '1'),
    ('A Ascensão do Apocalipse', 'Abril', 1, '2')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
     AND substring(item.detalhe_referencia FROM '#([0-9]+)') = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower(referencia.editora_nome)
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo)
     AND coalesce(serie.volume, 1) = referencia.volume
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

-- Especiais de edicao unica. Bishop aceita "Abril" e "Abri", conforme o cadastro.
WITH referencias(titulo, editora_nome, volume) AS (VALUES
    ('Tempestade dos X-Men', 'Abril', 1),
    ('Bishop dos X-Men', 'Abril', 1),
    ('Bishop dos X-Men', 'Abri', 1)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower(referencia.editora_nome)
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo)
     AND coalesce(serie.volume, 1) = referencia.volume
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
