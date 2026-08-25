-- Vincula a edicao 39 da DC Comics - Colecao de Graphic Novels (Eaglemoss)
-- a posicao 38 do guia cronologico do Batman.

WITH edicao_alvo AS (
    SELECT edicao.id, coalesce(
        nullif(trim(edicao.url_capa), ''),
        'https://spider145hqs.wordpress.com/wp-content/uploads/2022/08/dccomics_colecaodegraphicnovels_vol39_eaglemoss_27082022.jpg'
    ) AS url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(serie.titulo) LIKE '%dc comics%'
      AND lower(serie.titulo) LIKE '%graphic novels%'
      AND lower(serie.titulo) NOT LIKE '%sagas definitivas%'
      AND lower(editora.nome) LIKE 'eaglemoss%'
      AND coalesce(serie.volume, 1) = 1
      AND coalesce(
          nullif(ltrim(substring(coalesce(edicao.numero, '') FROM '([0-9]+)'), '0'), ''),
          nullif(ltrim(substring(coalesce(edicao.nome_volume, '') FROM '([0-9]+)'), '0'), ''),
          nullif(ltrim(substring(coalesce(edicao.id_externo, '') FROM '([0-9]+)'), '0'), '')
      ) = '39'
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a DC Comics - Colecao de Graphic Novels nº 39, da Eaglemoss.'
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 38;
