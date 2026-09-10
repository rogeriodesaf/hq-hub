-- Corrige edicoes preexistentes da colecao que usam formatos de numero como
-- "01" ou "n. 1". A V397 cadastrou as 79 capas, mas a identidade textual do
-- catalogo nao considera esses formatos equivalentes a "1".
--
-- Tambem cobre cadastros legados cuja editora se chama "Eaglemoss Collections".

WITH capas_por_numero AS (
    SELECT DISTINCT ON (numero_numerico)
           numero_numerico,
           capa.url_capa
    FROM (
        SELECT
            edicao.url_capa,
            substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
        FROM edicoes edicao
        JOIN series serie ON serie.id = edicao.serie_id
        JOIN editoras editora ON editora.id = serie.editora_id
        WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
              hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
          AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
          AND coalesce(serie.volume, 1) = 1
          AND edicao.url_capa LIKE
              'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol%'
          AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
    ) capa
    WHERE numero_numerico BETWEEN 1 AND 79
    ORDER BY numero_numerico
), edicoes_alvo AS (
    SELECT
        edicao.id,
        substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
      AND coalesce(serie.volume, 1) = 1
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas_por_numero capa ON capa.numero_numerico = alvo.numero_numerico
WHERE edicao.id = alvo.id;

-- Mantem referencias de leitura sincronizadas quando uma edicao da colecao ja
-- estiver vinculada a algum guia.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
  AND coalesce(serie.volume, 1) = 1
  AND edicao.url_capa IS NOT NULL;
