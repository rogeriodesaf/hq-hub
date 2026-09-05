-- Vincula a capa principal da posição 64 e sua publicação alternativa.

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
      AND coalesce(serie.volume, 1) = 3
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero)
          = hqhub_normalizar_identidade('5')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    detalhe_referencia = 'Saga do Batman, A · Panini · V3 · #5',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 64;

WITH principal AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 3
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('5')
    ORDER BY edicao.id
    LIMIT 1
), alternativa AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 2
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('19')
    ORDER BY edicao.id
    LIMIT 1
)
INSERT INTO publicacoes_relacionadas (
    edicao_origem_id,
    edicao_destino_id,
    tipo,
    fonte_externa,
    observacoes,
    data_criacao,
    data_atualizacao
)
SELECT
    principal.id,
    alternativa.id,
    'REPUBLICADA_EM',
    'GUIA_BATMAN',
    'Publicação alternativa indicada para a posição 64 do guia do Batman.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM principal
CROSS JOIN alternativa
ON CONFLICT (edicao_origem_id, edicao_destino_id, tipo) DO UPDATE
SET fonte_externa = EXCLUDED.fonte_externa,
    observacoes = EXCLUDED.observacoes,
    data_atualizacao = CURRENT_TIMESTAMP;
