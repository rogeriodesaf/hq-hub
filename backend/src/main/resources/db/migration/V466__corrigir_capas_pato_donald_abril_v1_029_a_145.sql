-- Corrige as capas 29 a 145 de Pato Donald, O / Abril, volume 1.
-- Identidade de catalogo: Guia dos Quadrinhos, galeria ptd0031. A galeria
-- identifica o titulo como Pato Donald, O, editora Abril, iniciado em 1950.
-- Escopo desta correcao: todas as 117 edicoes atualmente cadastradas no
-- intervalo 29-145. As capas vieram de um unico lote dedicado da Rika Comic
-- Shop (assets 172651-172767), responderam HTTP 200/image/jpeg e foram
-- conferidas visualmente, numero a numero. As capas 29 e 30 publicadas antes
-- desta migracao pertenciam incorretamente a Almanaque do Pato Donald.
-- Evidencia auditavel (fonte, asset, URL, dimensoes, tamanho e SHA-256):
-- docs/catalogo/capas/pato-donald-abril-v1-edicoes-029-a-145.csv

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
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Pato Donald, O')
       AND coalesce(serie.volume, 1) = 1;

    IF quantidade = 0 THEN
        RETURN;
    END IF;

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'Pato Donald, O/Abril V1: esperada uma serie alvo, encontradas %',
            quantidade;
    END IF;

    SELECT count(*)
      INTO numeros_duplicados
      FROM (
          SELECT trim(edicao.numero)::integer
            FROM edicoes edicao
           WHERE edicao.serie_id = serie_alvo_id
             AND trim(edicao.numero) ~ '^0*[0-9]+$'
             AND trim(edicao.numero)::integer BETWEEN 29 AND 145
           GROUP BY trim(edicao.numero)::integer
          HAVING count(*) > 1
      ) duplicados;

    IF numeros_duplicados <> 0 THEN
        RAISE EXCEPTION
            'Pato Donald, O/Abril V1: existem % numeros duplicados entre 29 e 145; nenhuma capa foi alterada',
            numeros_duplicados;
    END IF;
END
$$;

WITH capas(numero) AS (
    SELECT generate_series(29, 145)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Pato Donald, O')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'pato-donald-abril-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem =
           'https://www.guiadosquadrinhos.com/capas/pato-donald-o/ptd0031',
       fonte_externa = 'Rika / Guia dos Quadrinhos',
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
           'pato-donald-abril-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg'
       OR edicao.url_origem IS DISTINCT FROM
           'https://www.guiadosquadrinhos.com/capas/pato-donald-o/ptd0031'
       OR edicao.fonte_externa IS DISTINCT FROM 'Rika / Guia dos Quadrinhos'
   );

WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Pato Donald, O')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 29 AND 145
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
