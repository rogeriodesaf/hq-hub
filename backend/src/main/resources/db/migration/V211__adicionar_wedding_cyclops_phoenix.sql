-- Adiciona The Wedding of Cyclops & Phoenix à etapa de Laços de Sangue,
-- antes de As Aventuras de Ciclope e Fênix.

WITH marco AS (
    SELECT item.posicao + 1 AS posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('Capitão América')
      AND item.detalhe_referencia = 'V1 #208'
)
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 10000
FROM ordens_leitura ordem, marco
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.posicao;

UPDATE itens_ordem_leitura item
SET posicao = item.posicao - 9999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 10000;

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao + 1 AS posicao
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('Capitão América')
      AND item.detalhe_referencia = 'V1 #208'
), candidatos AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (
               ORDER BY CASE WHEN upper(trim(edicao.numero)) IN ('UNICA', 'ÚNICA') THEN 0 ELSE 1 END,
                        edicao.id
           ) AS prioridade
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('X-Men: The Wedding of Cyclops & Phoenix (2018)')
      AND coalesce(serie.volume, 1) = 1
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, secao
)
SELECT ordem.id, marco.posicao,
       'X-Men: The Wedding of Cyclops & Phoenix (2018)', 'V1',
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       'X-Men e Vingadores: Laços de Sangue e Aliança Falange'
FROM ordem CROSS JOIN marco
LEFT JOIN candidatos candidato ON candidato.prioridade = 1;
