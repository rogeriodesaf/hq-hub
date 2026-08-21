-- Corrige o item recriado de Guerras Secretas II, escolhendo de forma
-- determinística a edição Panini e mantendo a capa oficial como fallback.

WITH edicoes_alvo AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Guerras Secretas II')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uqgv6h6nbl6f74vgn4f9ke7960/-S897-f.webp',
    fonte_externa = 'PANINI',
    url_origem = 'https://panini.com.br/guerras-secretas-ii',
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
WHERE edicao.id = alvo.id;

WITH candidatos AS (
    SELECT edicao.id AS edicao_id,
           row_number() OVER (
               ORDER BY
                   CASE WHEN lower(trim(edicao.id_externo)) = lower('AGSII001') THEN 0 ELSE 1 END,
                   CASE WHEN upper(trim(edicao.numero)) IN ('UNICA', 'ÚNICA') THEN 0 ELSE 1 END,
                   edicao.id
           ) AS prioridade
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Guerras Secretas II')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uqgv6h6nbl6f74vgn4f9ke7960/-S897-f.webp',
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Guerras Secretas II')
  AND item.detalhe_referencia = '#UNICA'
  AND candidato.prioridade = 1;
