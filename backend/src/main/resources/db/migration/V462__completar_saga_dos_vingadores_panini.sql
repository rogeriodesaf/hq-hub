-- Completa e corrige A Saga dos Vingadores/Panini, volume 1 (2023-2025).
-- Identidade editorial: Guia dos Quadrinhos, galeria sa011140, 10 edições.
-- As páginas individuais 1-10 confirmaram título, editora, número e URL de capa.
-- Todos os 10 arquivos responderam como JPEG e foram conferidos visualmente.
-- Evidência número a número (página, id do Guia, URL, dimensões e SHA-256):
-- docs/catalogo/capas/saga-dos-vingadores-panini-v1.csv

DO $$
DECLARE
    quantidade INTEGER;
BEGIN
    SELECT count(*)
      INTO quantidade
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND coalesce(serie.volume, 1) = 1
       AND (
           serie.id_externo = 'panini|asaga dos vingadores|1'
           OR serie.url_origem LIKE '%/sa011140/%'
           OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
               hqhub_normalizar_titulo_serie('ASaga dos Vingadores'),
               hqhub_normalizar_titulo_serie('A Saga dos Vingadores'),
               hqhub_normalizar_titulo_serie('Saga dos Vingadores, A')
           )
       );

    IF quantidade > 1 THEN
        RAISE EXCEPTION
            'A Saga dos Vingadores/Panini V1: identidade ambígua (% séries)', quantidade;
    END IF;
END
$$;

-- Corrige também o título sem espaço atualmente exibido no catálogo público.
UPDATE series serie
   SET titulo = 'A Saga dos Vingadores',
       ano_inicio = coalesce(serie.ano_inicio, 2023),
       ano_fim = coalesce(serie.ano_fim, 2025),
       url_origem = 'https://www.guiadosquadrinhos.com/capas/saga-dos-vingadores-a/sa011140',
       fonte_externa = 'GUIA_DOS_QUADRINHOS',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM editoras editora
 WHERE editora.id = serie.editora_id
   AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
   AND coalesce(serie.volume, 1) = 1
   AND (
       serie.id_externo = 'panini|asaga dos vingadores|1'
       OR serie.url_origem LIKE '%/sa011140/%'
       OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
           hqhub_normalizar_titulo_serie('ASaga dos Vingadores'),
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores'),
           hqhub_normalizar_titulo_serie('Saga dos Vingadores, A')
       )
   );

WITH dados(numero, titulo, data_publicacao, paginas, preco, id_guia) AS (VALUES
    (6, 'Quem vai liderar os Vingadores?', DATE '2024-06-01', 148, 39.90, 178235),
    (7, 'Quinze Vingadores enfrentam os Guerreiros da Morte!', DATE '2024-08-01', 164, 44.90, 178920),
    (8, 'O dia do Adaptoide!', DATE '2024-10-01', 148, 39.90, 180745),
    (9, 'O começo do fim!', DATE '2025-01-01', 148, 39.90, 181475)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores')
       AND coalesce(serie.volume, 1) = 1
       AND (
           serie.id_externo = 'panini|asaga dos vingadores|1'
           OR serie.url_origem LIKE '%/sa011140%'
       )
)
INSERT INTO edicoes (
    numero, titulo, descricao, data_publicacao, url_capa,
    quantidade_paginas, preco_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero::text,
    dado.titulo,
    'Saga dos Vingadores, A nº ' || dado.numero::text || E'\n' || dado.titulo,
    dado.data_publicacao,
    'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'saga-dos-vingadores-panini-v1/' || lpad(dado.numero::text, 2, '0') || '.jpg',
    dado.paginas,
    dado.preco,
    'Americano (17 x 26 cm), colorido, lombada quadrada',
    'GUIA_DOS_QUADRINHOS',
    'panini|asaga dos vingadores|1|' || dado.numero::text,
    'https://www.guiadosquadrinhos.com/edicao/' ||
        'saga-dos-vingadores-a-n-' || dado.numero::text ||
        '/sa011140/' || dado.id_guia::text,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  FROM dados dado
 CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = coalesce(nullif(edicoes.titulo, ''), EXCLUDED.titulo),
    descricao = coalesce(nullif(edicoes.descricao, ''), EXCLUDED.descricao),
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    preco_capa = EXCLUDED.preco_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

DO $$
DECLARE
    serie_alvo_id BIGINT;
    numeros_invalidos INTEGER;
BEGIN
    SELECT serie.id
      INTO serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores')
       AND coalesce(serie.volume, 1) = 1
       AND (
           serie.id_externo = 'panini|asaga dos vingadores|1'
           OR serie.url_origem LIKE '%/sa011140%'
       );

    IF serie_alvo_id IS NULL THEN
        RETURN;
    END IF;

    SELECT count(*)
      INTO numeros_invalidos
      FROM generate_series(1, 10) esperado(numero)
     WHERE (
         SELECT count(*)
           FROM edicoes edicao
          WHERE edicao.serie_id = serie_alvo_id
            AND trim(edicao.numero) ~ '^0*[0-9]+$'
            AND trim(edicao.numero)::integer = esperado.numero
     ) <> 1;

    IF numeros_invalidos <> 0 THEN
        RAISE EXCEPTION
            'A Saga dos Vingadores/Panini V1: % números entre 1 e 10 estão ausentes ou duplicados',
            numeros_invalidos;
    END IF;
END
$$;

WITH capas(numero, id_guia) AS (VALUES
    (1, 174305), (2, 174996), (3, 175505), (4, 176565), (5, 177236),
    (6, 178235), (7, 178920), (8, 180745), (9, 181475), (10, 183522)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores')
       AND coalesce(serie.volume, 1) = 1
       AND (
           serie.id_externo = 'panini|asaga dos vingadores|1'
           OR serie.url_origem LIKE '%/sa011140%'
       )
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'saga-dos-vingadores-panini-v1/' || lpad(capa.numero::text, 2, '0') || '.jpg',
       url_origem =
           'https://www.guiadosquadrinhos.com/edicao/' ||
           'saga-dos-vingadores-a-n-' || capa.numero::text ||
           '/sa011140/' || capa.id_guia::text,
       fonte_externa = 'GUIA_DOS_QUADRINHOS',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa
 CROSS JOIN serie_alvo serie
 WHERE edicao.serie_id = serie.id
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer = capa.numero;

WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores')
       AND coalesce(serie.volume, 1) = 1
       AND (
           serie.id_externo = 'panini|asaga dos vingadores|1'
           OR serie.url_origem LIKE '%/sa011140%'
       )
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[0-9]+$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 10
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
