-- Vincula os encadernados da fase de Grant Morrison às referências da
-- Ordem de Leitura Mutante. As edições já possuem capas no Cloudinary.
WITH referencias(titulo_ordem, titulo_catalogo) AS (VALUES
    ('Novos X-Men: E de Extinção', 'Novos X-Men: e de Extinção'),
    ('Novos X-Men: Ecos do Amanhã', 'Novos X-Men: Ecos do Amanhã'),
    ('Novos X-Men: Novos Mundos', 'Novos X-Men: Novos Mundos'),
    ('Novos X-Men: Planeta X', 'Novos X-Men: Planeta X'),
    ('Novos X-Men: Rebelião no Instituto Xavier', 'Novos X-Men: Rebelião No Instituto Xavier'),
    ('X-Men: Imperial', 'Novos X-Men: Imperial')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND upper(trim(edicao.numero)) = 'UNICA'
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
