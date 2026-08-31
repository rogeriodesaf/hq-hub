-- Vincula DC Comics - Coleção de Graphic Novels: Sagas Definitivas #30
-- à posição 49 do guia cronológico do Batman.

WITH edicao_alvo AS (
    SELECT
        edicao.id,
        edicao.url_capa,
        coalesce(
            extract(year FROM edicao.data_publicacao)::integer,
            extract(year FROM edicao.data_cobertura)::integer,
            serie.ano_inicio
        ) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
      AND hqhub_normalizar_titulo_serie(serie.titulo)
          = hqhub_normalizar_titulo_serie('DC Comics - Coleção de Graphic Novels: Sagas Definitivas')
      AND hqhub_normalizar_identidade(edicao.numero)
          = hqhub_normalizar_identidade('30')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    titulo_referencia = 'DC Comics - Coleção de Graphic Novels: Sagas Definitivas',
    detalhe_referencia = '#30',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a DC Comics - Coleção de Graphic Novels: Sagas Definitivas #30.',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 49;
