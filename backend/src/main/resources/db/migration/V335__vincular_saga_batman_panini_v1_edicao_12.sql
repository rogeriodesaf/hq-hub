-- Vincula A Saga do Batman, Panini V1 edição 12,
-- à posição 50 do guia cronológico do Batman.

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
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo)
          = hqhub_normalizar_titulo_serie('A Saga do Batman')
      AND hqhub_normalizar_identidade(edicao.numero)
          = hqhub_normalizar_identidade('12')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    titulo_referencia = 'A Saga do Batman',
    detalhe_referencia = 'Panini · V1 · Edição 12',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a A Saga do Batman, Panini, V1, edição 12.',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 50;
