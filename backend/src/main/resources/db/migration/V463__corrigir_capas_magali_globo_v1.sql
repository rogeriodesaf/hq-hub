-- Corrige as 403 capas de Magali/Globo, volume 1 (1989-2006).
-- Identidade de catalogo: Guia dos Quadrinhos, galeria ma00501, 403 edicoes.
-- Fonte unica das imagens: acervo dedicado "Magali - Globo" do Get Back.
-- A correspondencia foi validada numero a numero pela sequencia da fonte; todos
-- os 403 URLs responderam JPEG e o conjunto inteiro foi conferido visualmente.
-- Evidencia reproduzivel (fonte, URL, dimensoes, tamanho e SHA-256 por arquivo):
-- docs/catalogo/capas/magali-globo-v1.csv

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
           hqhub_normalizar_titulo_serie('Magali')
       AND coalesce(serie.volume, 1) = 1;

    -- Catalogos novos podem ainda nao ter importado a serie. Nesse caso, a
    -- migracao permanece inocua, como as demais correcoes de capas do projeto.
    IF quantidade = 0 THEN
        RETURN;
    END IF;

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'Magali/Globo V1: esperada uma serie alvo, encontradas %', quantidade;
    END IF;

    SELECT count(*)
      INTO numeros_invalidos
      FROM generate_series(1, 403) esperado(numero)
     WHERE (
         SELECT count(*)
           FROM edicoes edicao
          WHERE edicao.serie_id = serie_alvo_id
            AND trim(edicao.numero) ~ '^0*[0-9]+$'
            AND trim(edicao.numero)::integer = esperado.numero
     ) <> 1;

    IF numeros_invalidos <> 0 THEN
        RAISE EXCEPTION
            'Magali/Globo V1: % numeros entre 1 e 403 estao ausentes ou duplicados; nenhuma capa foi alterada',
            numeros_invalidos;
    END IF;

    SELECT count(*)
      INTO quantidade
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*[0-9]+$'
       AND trim(edicao.numero)::integer NOT BETWEEN 1 AND 403;

    IF quantidade <> 0 THEN
        RAISE EXCEPTION
            'Magali/Globo V1: existem % edicoes numericas fora do catalogo 1-403; nenhuma capa foi alterada',
            quantidade;
    END IF;
END
$$;

WITH capas(numero) AS (
    SELECT generate_series(1, 403)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Magali')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'magali-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem = 'https://www.guiadosquadrinhos.com/capas/magali/ma00501',
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
           'magali-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg'
       OR edicao.url_origem IS DISTINCT FROM
           'https://www.guiadosquadrinhos.com/capas/magali/ma00501'
       OR edicao.fonte_externa IS DISTINCT FROM 'Get Back / Guia dos Quadrinhos'
   );

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Magali')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 403
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
