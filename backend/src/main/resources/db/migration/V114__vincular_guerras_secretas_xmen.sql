-- Vincula as nove etapas da ordem as seis edicoes brasileiras da serie
-- mensal Guerras Secretas: X-Men. As edicoes 1 a 3 possuem duas etapas cada.

WITH referencias(titulo, numero) AS (VALUES
    ('Guerras Secretas: X-Men — A Era do Apocalipse', 1),
    ('Guerras Secretas: X-Men — Dinastia M', 2),
    ('Guerras Secretas: X-Men — E de Extinção', 3),
    ('Guerras Secretas: X-Men — Programa de Extermínio', 4),
    ('Guerras Secretas: X-Men — Dias de um Futuro Esquecido', 5),
    ('Guerras Secretas: X-Men — Inferno', 6)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) IN (
           lower('Guerras Secretas: X-Men'),
           lower('Guerras Secretas - X-Men')
         )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)')::integer = referencia.numero
     AND edicao.url_capa IS NOT NULL
     AND trim(edicao.url_capa) <> ''
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
