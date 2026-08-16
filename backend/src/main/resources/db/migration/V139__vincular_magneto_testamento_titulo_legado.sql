-- Último fallback para o cadastro legado: ignora pontuação e metadados ausentes,
-- mantendo a seleção restrita aos termos Magneto e Testamento.

WITH candidato AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    WHERE lower(serie.titulo) LIKE '%magneto%'
      AND lower(serie.titulo) LIKE '%testamento%'
    ORDER BY
        CASE WHEN lower(trim(edicao.numero)) IN ('única', 'unica', '1') THEN 0 ELSE 1 END,
        edicao.id DESC
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 184;
