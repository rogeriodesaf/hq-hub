-- Corrige as capas 1 a 11 de Batman/Superman: Os Melhores do Mundo,
-- segunda serie, Panini, volume 2 (2025-2026).
-- Identidade de catalogo: Guia dos Quadrinhos, galeria ba011335, 11 edicoes
-- publicadas ate setembro de 2026. A galeria ainda marca a edicao 11 sem capa;
-- por isso, as imagens foram obtidas de uma unica fonte editorial oficial:
-- paginas de produto da Panini, SKUs ABSMM001 a ABSMM011.
-- Todas as paginas e imagens responderam HTTP 200/image-webp e o conjunto foi
-- conferido visualmente, numero a numero.
-- Evidencia auditavel (fonte, SKU, URL, tamanho e SHA-256 por arquivo):
-- docs/catalogo/capas/batman-superman-melhores-do-mundo-panini-v2.csv

DO $$
DECLARE
    serie_alvo_id BIGINT;
    quantidade INTEGER;
    numeros_duplicados INTEGER;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Batman/Superman: Os Melhores do Mundo 2\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 2;

    -- Catalogos novos podem ainda nao ter importado a serie. Nesse caso, a
    -- migracao permanece inocua, como as demais correcoes de capas do projeto.
    IF quantidade = 0 THEN
        RETURN;
    END IF;

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'Batman/Superman: Os Melhores do Mundo 2a Serie/Panini V2: esperada uma serie alvo, encontradas %',
            quantidade;
    END IF;

    -- A serie esta em publicacao. Valida apenas o recorte 1-11 documentado pela
    -- referencia, sem impedir edicoes posteriores que venham a ser cadastradas.
    SELECT count(*)
      INTO numeros_duplicados
      FROM (
          SELECT trim(edicao.numero)::integer
            FROM edicoes edicao
           WHERE edicao.serie_id = serie_alvo_id
             AND trim(edicao.numero) ~ '^0*[0-9]+$'
             AND trim(edicao.numero)::integer BETWEEN 1 AND 11
           GROUP BY trim(edicao.numero)::integer
          HAVING count(*) > 1
      ) duplicados;

    IF numeros_duplicados <> 0 THEN
        RAISE EXCEPTION
            'Batman/Superman: Os Melhores do Mundo 2a Serie/Panini V2: existem % numeros duplicados entre 1 e 11; nenhuma capa foi alterada',
            numeros_duplicados;
    END IF;
END
$$;

WITH capas(numero) AS (
    SELECT generate_series(1, 11)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Batman/Superman: Os Melhores do Mundo 2\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 2
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'batman-superman-melhores-do-mundo-panini-v2/' ||
           lpad(capa.numero::text, 3, '0') || '.webp',
       url_origem =
           'https://www.guiadosquadrinhos.com/capas/' ||
           'batmansuperman-os-melhores-do-mundo-2-serie/ba011335',
       fonte_externa = 'Panini / Guia dos Quadrinhos',
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
           'batman-superman-melhores-do-mundo-panini-v2/' ||
           lpad(capa.numero::text, 3, '0') || '.webp'
       OR edicao.url_origem IS DISTINCT FROM
           'https://www.guiadosquadrinhos.com/capas/' ||
           'batmansuperman-os-melhores-do-mundo-2-serie/ba011335'
       OR edicao.fonte_externa IS DISTINCT FROM 'Panini / Guia dos Quadrinhos'
   );

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Batman/Superman: Os Melhores do Mundo 2\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 2
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 11
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
