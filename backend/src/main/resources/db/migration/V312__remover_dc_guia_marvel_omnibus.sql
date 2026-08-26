-- Remove falsos positivos da busca generica por Omnibus que pertencem a DC Comics.

WITH guia AS (
    SELECT id FROM ordens_leitura WHERE slug = 'marvel-omnibus'
)
DELETE FROM itens_ordem_leitura item
USING guia, edicoes edicao, series serie
WHERE item.ordem_leitura_id = guia.id
  AND edicao.id = item.edicao_id
  AND serie.id = edicao.serie_id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Aquaman Por Geoff Johns'),
      hqhub_normalizar_titulo_serie('Aquaman Por Peter David'),
      hqhub_normalizar_titulo_serie('Arqueiro Verde Por Mike Grell'),
      hqhub_normalizar_titulo_serie('Batman Por Jeph Loeb E Tim Sale'),
      hqhub_normalizar_titulo_serie('Batman Por Paul Dini')
  );

WITH itens AS (
    SELECT
        item.id,
        row_number() OVER (
            ORDER BY hqhub_normalizar_titulo_serie(item.titulo_referencia), item.id
        )::integer AS nova_posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia ON guia.id = item.ordem_leitura_id
    WHERE guia.slug = 'marvel-omnibus'
)
UPDATE itens_ordem_leitura item
SET posicao = 1000 + itens.nova_posicao
FROM itens
WHERE item.id = itens.id;

UPDATE itens_ordem_leitura item
SET posicao = item.posicao - 1000
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'marvel-omnibus';

UPDATE ordens_leitura
SET descricao = 'Os 24 titulos brasileiros da linha Marvel Omnibus cadastrados no HQ-HUB, organizados em ordem alfabetica.',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE slug = 'marvel-omnibus';
