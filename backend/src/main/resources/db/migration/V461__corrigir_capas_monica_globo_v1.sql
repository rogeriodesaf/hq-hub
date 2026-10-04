-- Corrige as 246 capas de Mônica/Globo, volume 1 (1987-2006).
-- Identidade de catálogo: Guia dos Quadrinhos, galeria mo00502, 246 edições.
-- Fonte única das imagens: acervo dedicado "Mônica - Editora Globo" do Get Back.
-- A correspondência foi validada número a número pelos nomes/captions das páginas,
-- todos os 246 URLs responderam JPEG e o conjunto inteiro foi conferido visualmente.
-- Evidência reproduzível (fonte, URL, tamanho e SHA-256 de cada arquivo):
-- docs/catalogo/capas/monica-globo-v1.csv

DO $$
DECLARE
    serie_alvo_id BIGINT;
    quantidade INTEGER;
    numeros_invalidos INTEGER;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'M\00F4nica')
       AND coalesce(serie.volume, 1) = 1;

    -- Catálogos novos podem ainda não ter importado a série. Nesse caso, a
    -- migração permanece inócua, como as demais correções de capas do projeto.
    IF quantidade = 0 THEN
        RETURN;
    END IF;

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'Mônica/Globo V1: esperada uma série alvo, encontradas %', quantidade;
    END IF;

    SELECT count(*)
      INTO numeros_invalidos
      FROM generate_series(1, 246) esperado(numero)
     WHERE (
         SELECT count(*)
           FROM edicoes edicao
          WHERE edicao.serie_id = serie_alvo_id
            AND trim(edicao.numero) ~ '^0*[0-9]+$'
            AND trim(edicao.numero)::integer = esperado.numero
     ) <> 1;

    IF numeros_invalidos <> 0 THEN
        RAISE EXCEPTION
            'Mônica/Globo V1: % números entre 1 e 246 estão ausentes ou duplicados; nenhuma capa foi alterada',
            numeros_invalidos;
    END IF;

    SELECT count(*)
      INTO quantidade
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*[0-9]+$'
       AND trim(edicao.numero)::integer NOT BETWEEN 1 AND 246;

    IF quantidade <> 0 THEN
        RAISE EXCEPTION
            'Mônica/Globo V1: existem % edições numéricas fora do catálogo 1-246; nenhuma capa foi alterada',
            quantidade;
    END IF;
END
$$;

WITH capas(numero) AS (
    SELECT generate_series(1, 246)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'M\00F4nica')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'monica-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem = 'https://www.guiadosquadrinhos.com/capas/monica/mo00502',
       fonte_externa = 'Get Back / Guia dos Quadrinhos',
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
           'monica-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg'
       OR edicao.url_origem IS DISTINCT FROM
           'https://www.guiadosquadrinhos.com/capas/monica/mo00502'
       OR edicao.fonte_externa IS DISTINCT FROM 'Get Back / Guia dos Quadrinhos'
   );

-- Mantém eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'M\00F4nica')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 246
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
