-- Liga da Justica 1a Serie/Panini (2002-2012), edicoes 1 a 114.
-- O vinculo numero/capa foi conferido no catalogo da Rika e comparado por
-- amostragem com a galeria lj01101 do Guia dos Quadrinhos.
--
-- A migracao anterior (V367) aceitava qualquer serie Panini chamada apenas
-- "Liga da Justica". Aqui o titulo generico so e aceito quando os anos tambem
-- identificam a colecao de 2002, evitando misturar outras fases da revista.
WITH capas AS (
    SELECT numero,
           'https://rika.vtexassets.com/arquivos/ids/'
               || (221831 + numero)::text || '-600-auto' AS url_capa,
           'https://www.rika.com.br/liga-da-justica--'
               || lpad(numero::text, 3, '0')
               || (15002021 + numero)::text || '/p' AS url_origem
    FROM generate_series(1, 114) AS numero
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = coalesce(nullif(trim(edicao.url_origem), ''), capa.url_origem),
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1
  AND (
      hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Liga da Justiça 1ª Série'),
          hqhub_normalizar_titulo_serie('Liga da Justiça - 1ª Série')
      )
      OR (
          hqhub_normalizar_titulo_serie(serie.titulo) =
              hqhub_normalizar_titulo_serie('Liga da Justica')
          AND serie.ano_inicio = 2002
          AND (serie.ano_fim IS NULL OR serie.ano_fim = 2012)
      )
  )
  AND trim(edicao.numero) ~ '^[0-9]+$'
  AND trim(edicao.numero)::integer = capa.numero
  AND (
      edicao.url_capa IS DISTINCT FROM capa.url_capa
      OR edicao.url_origem IS NULL
      OR trim(edicao.url_origem) = ''
  );
