-- Vincula as edicoes de Selvagem Wolverine e Excepcionais X-Men da Ordem de
-- Leitura Mutante ao catalogo. O guia passa a exibir a capa da edicao
-- brasileira vinculada, sem duplicar URLs nos itens da ordem.

WITH referencias(titulo, volume, numero) AS (
    SELECT 'Selvagem Wolverine', 1, generate_series(1, 4)
    UNION ALL
    SELECT 'Excepcionais X-Men', 1, generate_series(1, 8)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
     AND substring(item.detalhe_referencia FROM 'V([0-9]+)')::integer = referencia.volume
     AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo)
     AND serie.volume = referencia.volume
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
