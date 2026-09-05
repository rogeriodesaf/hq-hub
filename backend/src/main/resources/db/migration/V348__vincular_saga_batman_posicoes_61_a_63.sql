-- Vincula as capas principais e as publicações alternativas solicitadas para
-- as posições 61 a 63 do guia cronológico do Batman.

WITH referencias(posicao, numero) AS (VALUES
    (61, '15'),
    (62, '17'),
    (63, '19')
), alvos AS (
    SELECT DISTINCT ON (referencia.posicao)
        referencia.posicao,
        referencia.numero,
        edicao.id,
        edicao.url_capa,
        coalesce(
            extract(year FROM edicao.data_publicacao)::integer,
            extract(year FROM edicao.data_cobertura)::integer,
            serie.ano_inicio
        ) AS ano
    FROM referencias referencia
    JOIN edicoes edicao ON TRUE
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 2
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero)
          = hqhub_normalizar_identidade(referencia.numero)
    ORDER BY referencia.posicao, edicao.id
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    detalhe_referencia = 'Saga do Batman, A · Panini · V2 · #' || alvo.numero,
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    ano_referencia = alvo.ano
FROM alvos alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = alvo.posicao;

WITH referencias(posicao, principal, alternativa) AS (VALUES
    (61, '15', '16'),
    (61, '15', '17'),
    (62, '17', '18'),
    (62, '17', '19'),
    (63, '19', '20')
), edicoes_saga AS (
    SELECT DISTINCT ON (hqhub_normalizar_identidade(edicao.numero))
        hqhub_normalizar_identidade(edicao.numero) AS numero,
        edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 2
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero) IN ('15', '16', '17', '18', '19', '20')
    ORDER BY hqhub_normalizar_identidade(edicao.numero), edicao.id
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
    'Publicação alternativa indicada para a posição ' || referencia.posicao || ' do guia do Batman.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
JOIN edicoes_saga principal
  ON principal.numero = hqhub_normalizar_identidade(referencia.principal)
JOIN edicoes_saga alternativa
  ON alternativa.numero = hqhub_normalizar_identidade(referencia.alternativa)
ON CONFLICT (edicao_origem_id, edicao_destino_id, tipo) DO UPDATE
SET fonte_externa = EXCLUDED.fonte_externa,
    observacoes = EXCLUDED.observacoes,
    data_atualizacao = CURRENT_TIMESTAMP;
