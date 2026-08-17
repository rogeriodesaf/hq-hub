-- O item editorial "X-Men: Império Secreto" do guia referencia a edição
-- brasileira X-Men V3 #23. Mantém o item e sua posição, alterando apenas o
-- vínculo com o catálogo e a capa exibida.

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men')
      AND coalesce(serie.volume, 0) = 3
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('23')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    titulo_referencia = 'X-Men: Império Secreto',
    detalhe_referencia = 'V3 #23'
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 393;
