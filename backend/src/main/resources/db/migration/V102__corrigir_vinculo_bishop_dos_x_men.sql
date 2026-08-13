-- A vinculacao anterior exigia uma unica edicao na serie. Bishop possui mais de
-- um candidato no catalogo; prioriza a edicao numero 1 com capa disponivel.
WITH candidato AS (
    SELECT edicao.id AS edicao_id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(serie.titulo)) = lower('Bishop dos X-Men')
      AND coalesce(serie.volume, 1) = 1
      AND lower(trim(editora.nome)) IN (lower('Abril'), lower('Abri'))
    ORDER BY
        CASE
            WHEN ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1' THEN 0
            ELSE 1
        END,
        CASE
            WHEN edicao.url_capa IS NOT NULL AND trim(edicao.url_capa) <> '' THEN 0
            ELSE 1
        END,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidato
WHERE lower(trim(item.titulo_referencia)) = lower('Bishop dos X-Men');
