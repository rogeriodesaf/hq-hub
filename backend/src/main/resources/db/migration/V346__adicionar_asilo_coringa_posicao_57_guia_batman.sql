-- Insere Batman: O Asilo do Coringa, Panini V1, na posição 57 do guia
-- cronológico do Batman e preserva os itens seguintes.

UPDATE itens_ordem_leitura item
SET posicao = -item.posicao
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao >= 57;

UPDATE itens_ordem_leitura item
SET posicao = (-item.posicao) + 1
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao <= -57;

WITH ordem_alvo AS (
    SELECT id
    FROM ordens_leitura
    WHERE slug = 'batman-ordem-cronologica'
), edicao_alvo AS (
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
      AND (
          hqhub_normalizar_titulo_serie(serie.titulo)
              = hqhub_normalizar_titulo_serie('Batman: O Asilo do Coringa')
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, ''))
              = hqhub_normalizar_titulo_serie('Batman: O Asilo do Coringa')
      )
    ORDER BY
        CASE
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1') THEN 0
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA') THEN 1
            ELSE 2
        END,
        edicao.id
    LIMIT 1
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id,
    posicao,
    secao,
    edicao_id,
    titulo_referencia,
    detalhe_referencia,
    url_capa_referencia,
    status_identificacao,
    observacao,
    ano_referencia
)
SELECT
    ordem.id,
    57,
    proximo.secao,
    alvo.id,
    'Batman: O Asilo do Coringa',
    'Panini · V1',
    alvo.url_capa,
    CASE WHEN alvo.id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
    CASE
        WHEN alvo.id IS NULL THEN 'Edição Panini V1 não localizada automaticamente no catálogo.'
        ELSE 'Vinculada a Batman: O Asilo do Coringa, Panini, V1.'
    END,
    alvo.ano
FROM ordem_alvo ordem
JOIN itens_ordem_leitura proximo
  ON proximo.ordem_leitura_id = ordem.id
 AND proximo.posicao = 58
LEFT JOIN edicao_alvo alvo ON TRUE;
