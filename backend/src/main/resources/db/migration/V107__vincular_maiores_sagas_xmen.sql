-- Vincula as referências "As Maiores Sagas dos X-Men" às edições Panini
-- equivalentes que já possuem capas armazenadas no catálogo.
WITH referencias(titulo_ordem, titulo_catalogo, numero) AS (VALUES
    ('As Maiores Sagas dos X-Men: Operação Tolerância Zero', 'X-Men: Operação Tolerância Zero', 'UNICA'),
    ('As Maiores Sagas dos X-Men: A Guerra Magnética', 'X-Men: A Guerra Magnética', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Amanhecer Violento', 'X-Men: Amanhecer Violento', '1'),
    ('As Maiores Sagas dos X-Men: Amanhecer Violento', 'X-Men: Amanhecer Violento', '2'),
    ('As Maiores Sagas dos X-Men: Gênese Mortal', 'X-Men: Gênese Mortal', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Complexo de Messias', 'X-Men: Complexo de Messias', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Guerra Messiânica', 'X-Men: Guerra Messiânica', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Utopia', 'X-Men/Vingadores: Utopia', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Necrosha', 'X-Men: Necrosha', 'UNICA'),
    ('As Maiores Sagas dos X-Men: Segundo Advento', 'X-Men: Segundo Advento', 'UNICA'),
    ('As Maiores Sagas dos X-Men: O Cisma', 'X-Men: O Cisma', 'UNICA')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
     AND (
          referencia.numero = 'UNICA'
          OR ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = referencia.numero
     )
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND upper(trim(edicao.numero)) = referencia.numero
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
