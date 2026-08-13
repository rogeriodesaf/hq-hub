-- O item sem numero da ordem mutante representa Wolverine: Arma X,
-- volume 12 da Colecao Oficial de Graphic Novels Marvel da Salvat.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) IN (
           lower('Coleção Oficial de Graphic Novels Marvel, A'),
           lower('A Coleção Oficial de Graphic Novels Marvel'),
           lower('Coleção Oficial de Graphic Novels Marvel')
         )
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Salvat')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '12'
    WHERE lower(trim(item.titulo_referencia)) =
          lower('Coleção Oficial de Graphic Novels Marvel — X-Men')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id,
    detalhe_referencia = 'V1 #12 — Wolverine: Arma X'
FROM candidatos
WHERE item.id = candidatos.item_id;
