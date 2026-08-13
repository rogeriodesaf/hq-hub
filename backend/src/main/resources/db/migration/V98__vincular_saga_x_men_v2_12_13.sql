-- As edicoes 12 e 13 do volume 2 foram adicionadas ao catalogo depois da
-- vinculacao inicial da ordem mutante. Reaproveita os registros e capas atuais.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) IN (
           lower('Saga dos X-Men, A'),
           lower('A Saga dos X-Men')
         )
     AND serie.volume = 2
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia IN ('V2 #12', 'V2 #13')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
