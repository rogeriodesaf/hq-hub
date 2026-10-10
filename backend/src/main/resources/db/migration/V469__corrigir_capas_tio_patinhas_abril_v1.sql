-- Corrige as capas de Tio Patinhas / Abril, volume 1 (1963-2018).
-- Identidade de catalogo: Guia dos Quadrinhos, galeria tph0031, 637 numeros.
-- Fonte unica das imagens: acervo dedicado Tio Patinhas da Vila Xurupita,
-- que identifica a colecao Abril de dezembro/1963 a julho/2018 e organiza as
-- 637 capas regulares por numero. As 637 URLs responderam com imagem valida,
-- foram normalizadas para JPEG e conferidas visualmente, numero a numero.
-- A fonte tem dois erros de HTML documentados no manifesto: as paginas apontam
-- 581 no lugar de 582 e 513 no lugar de 613; os arquivos corretos 0582a.jpg e
-- 0613a.jpg existem na mesma fonte e foram validados individualmente.
-- Evidencia auditavel completa (fonte, URL, dimensoes e hashes de origem/local):
-- docs/catalogo/capas/tio-patinhas-abril-v1.csv

DO $$
DECLARE
    serie_alvo_id BIGINT;
    quantidade INTEGER;
    numeros_duplicados INTEGER;
    numeros_fora_catalogo INTEGER;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas')
       AND coalesce(serie.volume, 1) = 1;

    IF quantidade = 0 THEN
        RETURN;
    END IF;

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'Tio Patinhas/Abril V1: esperada uma serie alvo, encontradas %',
            quantidade;
    END IF;

    SELECT count(*)
      INTO numeros_duplicados
      FROM (
          SELECT trim(edicao.numero)::integer
            FROM edicoes edicao
           WHERE edicao.serie_id = serie_alvo_id
             AND trim(edicao.numero) ~ '^0*[0-9]+$'
             AND trim(edicao.numero)::integer BETWEEN 1 AND 637
           GROUP BY trim(edicao.numero)::integer
          HAVING count(*) > 1
      ) duplicados;

    IF numeros_duplicados <> 0 THEN
        RAISE EXCEPTION
            'Tio Patinhas/Abril V1: existem % numeros duplicados entre 1 e 637; nenhuma capa foi alterada',
            numeros_duplicados;
    END IF;

    SELECT count(*)
      INTO numeros_fora_catalogo
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*[0-9]+$'
       AND trim(edicao.numero)::integer NOT BETWEEN 1 AND 637;

    IF numeros_fora_catalogo <> 0 THEN
        RAISE EXCEPTION
            'Tio Patinhas/Abril V1: existem % edicoes numericas fora do catalogo 1-637; nenhuma capa foi alterada',
            numeros_fora_catalogo;
    END IF;
END
$$;

WITH capas(numero) AS (
    SELECT numero
      FROM generate_series(1, 637) AS sequencia(numero)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'tio-patinhas-abril-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem =
           'https://www.guiadosquadrinhos.com/capas/tio-patinhas/tph0031',
       fonte_externa = 'Vila Xurupita / Guia dos Quadrinhos',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa
 CROSS JOIN serie_alvo serie
 WHERE edicao.serie_id = serie.id
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer = capa.numero
   AND (
       edicao.url_capa IS DISTINCT FROM
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'tio-patinhas-abril-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg'
       OR edicao.url_origem IS DISTINCT FROM
           'https://www.guiadosquadrinhos.com/capas/tio-patinhas/tph0031'
       OR edicao.fonte_externa IS DISTINCT FROM
           'Vila Xurupita / Guia dos Quadrinhos'
   );

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 637
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
