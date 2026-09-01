-- Divide a antiga posição 51 em duas posições consecutivas, preservando
-- os itens seguintes do guia cronológico do Batman.

UPDATE itens_ordem_leitura item
SET posicao = -item.posicao
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao >= 52;

UPDATE itens_ordem_leitura item
SET posicao = (-item.posicao) + 1
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao < 0;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa,
           coalesce(extract(year FROM edicao.data_publicacao)::integer,
                    extract(year FROM edicao.data_cobertura)::integer,
                    serie.ano_inicio) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('A Saga do Batman')
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('10')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    titulo_referencia = 'A Saga do Batman',
    detalhe_referencia = 'Panini · V1 · Edição 10',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a A Saga do Batman, Panini, V1, edição 10.',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 51;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa,
           coalesce(extract(year FROM edicao.data_publicacao)::integer,
                    extract(year FROM edicao.data_cobertura)::integer,
                    serie.ano_inicio) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND (
          hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman - As Muitas Mortes de Batman e Outras Histórias')
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) = hqhub_normalizar_titulo_serie('Batman - As Muitas Mortes de Batman e Outras Histórias')
      )
    ORDER BY edicao.id
    LIMIT 1
), ordem_alvo AS (
    SELECT id FROM ordens_leitura WHERE slug = 'batman-ordem-cronologica'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT ordem.id, 52, item.secao, alvo.id,
       'Batman - As Muitas Mortes de Batman e Outras Histórias',
       'Panini · V1', alvo.url_capa, 'CONFIRMADO',
       'Vinculada a Batman - As Muitas Mortes de Batman e Outras Histórias, Panini, V1.', alvo.ano
FROM ordem_alvo ordem
JOIN itens_ordem_leitura item ON item.ordem_leitura_id = ordem.id AND item.posicao = 51
JOIN edicao_alvo alvo ON TRUE;
