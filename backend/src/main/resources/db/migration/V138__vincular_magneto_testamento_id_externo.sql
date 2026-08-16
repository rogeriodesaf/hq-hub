-- O nome da série no cadastro legado diverge do título exibido no guia.
-- Usa a chave externa estável da importação Panini para concluir o vínculo.

WITH candidato AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa
    FROM edicoes edicao
    WHERE lower(trim(edicao.id_externo)) LIKE 'panini|magneto%testamento|1|%'
    ORDER BY
        CASE WHEN lower(trim(edicao.numero)) IN ('única', 'unica', '1') THEN 0 ELSE 1 END,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 184;
