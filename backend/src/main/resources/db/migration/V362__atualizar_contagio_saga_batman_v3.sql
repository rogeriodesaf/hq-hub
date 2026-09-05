-- Atualiza a posição 64 para a capa oficial de A Saga do Batman V3 #5
-- e insere a edição seguinte (V3 #6), ambas identificadas como Contágio.

-- Usa deslocamento temporário para preservar a restrição de posição única.
UPDATE itens_ordem_leitura item
SET posicao = -item.posicao
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao >= 65;

UPDATE itens_ordem_leitura item
SET posicao = (-item.posicao) + 1
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.posicao <= -65;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa,
           coalesce(extract(year FROM edicao.data_publicacao)::integer,
                    extract(year FROM edicao.data_cobertura)::integer,
                    serie.ano_inicio) AS ano
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
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    detalhe_referencia = 'A Saga do Batman · Panini · V3 · #5',
    url_capa_referencia = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_a35k5s718t1hh0bp2gthfcmo3c/-S897-f.webp',
    status_identificacao = 'CONFIRMADO',
    observacao = 'Contágio; capa oficial da página da Panini para A Saga do Batman Vol. 5/61.',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 64;

WITH ordem_alvo AS (
    SELECT id FROM ordens_leitura WHERE slug = 'batman-ordem-cronologica'
), edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa,
           coalesce(extract(year FROM edicao.data_publicacao)::integer,
                    extract(year FROM edicao.data_cobertura)::integer,
                    serie.ano_inicio) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 3
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Saga do Batman, A'),
          hqhub_normalizar_titulo_serie('A Saga do Batman')
      )
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('6')
    ORDER BY edicao.id
    LIMIT 1
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT ordem.id, 65, anterior.secao, alvo.id,
       'Batman: Contágio',
       'A Saga do Batman · Panini · V3 · #6',
       'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9betu60sah51r77m2gn3u7o37l/-S897-f.webp',
       CASE WHEN alvo.id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       CASE WHEN alvo.id IS NULL
            THEN 'Contágio; edição Panini V3 #6 ainda não localizada no catálogo.'
            ELSE 'Contágio; capa oficial da página da Panini para A Saga do Batman Vol. 6/62.'
       END,
       alvo.ano
FROM ordem_alvo ordem
JOIN itens_ordem_leitura anterior
  ON anterior.ordem_leitura_id = ordem.id
 AND anterior.posicao = 64
LEFT JOIN edicao_alvo alvo ON TRUE;
