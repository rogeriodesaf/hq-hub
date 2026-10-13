-- Alinha as capas de Tio Patinhas / Abril, volume 1, diretamente a galeria
-- indicada pelo usuario: https://www.guiadosquadrinhos.com/capas/tio-patinhas/tph0031
--
-- Identidade editorial validada: Tio Patinhas, Editora Abril, volume 1,
-- numeros 1 a 637 (dezembro/1963 a junho/2018). A galeria retornou 639
-- registros: 637 numeros, com segundas entradas somente nos numeros 9 e 400.
-- Em ambos os casos foi selecionada a unica entrada que possui capa.
--
-- Das 637 capas, 625 foram obtidas da imagem da propria edicao no Guia com
-- HTTP 200 e content-type de imagem. Nos numeros 1, 4, 35, 43, 46, 57, 67,
-- 68, 88, 377, 479 e 623, a propria galeria exibe "capa em breve"; somente
-- nessas 12 excecoes foi preservada a capa do acervo dedicado Tio Patinhas da
-- Vila Xurupita, ja validada na V469, removendo-se moldura e legenda externas.
-- O conjunto completo foi conferido visualmente, numero a numero, em 16 folhas.
--
-- Evidencia auditavel (URL da edicao, URL da imagem, origem de cada excecao,
-- status HTTP, dimensoes, bytes e SHA-256 dos 637 arquivos):
-- docs/catalogo/capas/tio-patinhas-abril-v2.csv

DO $$
DECLARE
    serie_alvo_id BIGINT;
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
    quantidade_numeros INTEGER;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade_series, serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
               hqhub_normalizar_titulo_serie('Abril'),
               hqhub_normalizar_titulo_serie('Editora Abril')
           )
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
       AND coalesce(serie.volume, 1) = 1;

    IF quantidade_series = 0 THEN
        RETURN;
    END IF;

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: esperada uma serie alvo, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*),
           count(DISTINCT trim(edicao.numero)::integer)
      INTO quantidade_edicoes, quantidade_numeros
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*[1-9][0-9]*$'
       AND trim(edicao.numero)::integer BETWEEN 1 AND 637;

    IF quantidade_edicoes <> 637 OR quantidade_numeros <> 637 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: esperadas 637 edicoes unicas de 1 a 637, encontradas % edicoes e % numeros; nenhuma capa foi alterada',
            quantidade_edicoes,
            quantidade_numeros;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM edicoes edicao
         WHERE edicao.serie_id = serie_alvo_id
           AND (
               trim(edicao.numero) !~ '^0*[1-9][0-9]*$'
               OR trim(edicao.numero)::numeric NOT BETWEEN 1 AND 637
           )
    ) THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: existem edicoes fora da identidade numerica 1-637; nenhuma capa foi alterada';
    END IF;
END
$$;

WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
               hqhub_normalizar_titulo_serie('Abril'),
               hqhub_normalizar_titulo_serie('Editora Abril')
           )
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'tio-patinhas-abril-v2/' ||
           lpad(trim(edicao.numero)::integer::text, 3, '0') || '.jpg',
       url_origem = 'https://www.guiadosquadrinhos.com/capas/tio-patinhas/tph0031',
       fonte_externa = 'Guia dos Quadrinhos / Vila Xurupita (12 coversoon)',
       data_atualizacao = CURRENT_TIMESTAMP
 WHERE edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[1-9][0-9]*$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 637;

UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
  JOIN series serie ON serie.id = edicao.serie_id
  JOIN editoras editora ON editora.id = serie.editora_id
 WHERE item.edicao_id = edicao.id
   AND hqhub_normalizar_titulo_serie(editora.nome) IN (
           hqhub_normalizar_titulo_serie('Abril'),
           hqhub_normalizar_titulo_serie('Editora Abril')
       )
   AND hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
   AND coalesce(serie.volume, 1) = 1
   AND trim(edicao.numero) ~ '^0*[1-9][0-9]*$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 637
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
