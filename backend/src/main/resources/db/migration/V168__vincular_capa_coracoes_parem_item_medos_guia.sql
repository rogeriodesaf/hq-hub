-- O nome de trabalho do item 415 diverge do título publicado pela Panini.
-- Reaproveita o cadastro existente de "Até que Nossos Corações Parem" e sua
-- capa, sem criar outra série ou edição.

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Surpreendentes X-Men: Até que Nossos Corações Parem')
      AND edicao.url_capa IS NOT NULL
      AND trim(edicao.url_capa) <> ''
    ORDER BY coalesce(serie.volume, 0), edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 415;
