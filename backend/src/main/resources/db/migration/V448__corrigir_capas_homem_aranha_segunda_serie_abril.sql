-- Corrige Homem-Aranha 2a Serie/Abril (linha Super-Herois Premium).
-- A colecao completa possui 17 edicoes, de agosto/2000 a dezembro/2001.
-- As capas foram conferidas, numero a numero, com a galeria ha00402 do
-- Guia dos Quadrinhos e obtidas de uma unica pagina dedicada a esta colecao.
WITH capas(numero, url_capa) AS (VALUES
    (1,  'https://tudohqemanga.com.br/wp-content/uploads/2024/02/Homem-Aranha-Super-Premium-001-Editora-Abril-000.jpg'),
    (2,  'https://tudohqemanga.com.br/wp-content/uploads/2024/02/Homem-Aranha-Super-Premium-002-Editora-Abril-000.jpg'),
    (3,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-003-Editora-Abril-000.jpg'),
    (4,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-004-Editora-Abril-000.jpg'),
    (5,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-005-Editora-Abril-000.jpg'),
    (6,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-006-Editora-Abril-000.jpg'),
    (7,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-007-Editora-Abril-000.jpg'),
    (8,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-008-Editora-Abril-000.jpg'),
    (9,  'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-009-Editora-Abril-000.jpg'),
    (10, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-010-Editora-Abril-000.jpg'),
    (11, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-011-Editora-Abril-000.jpg'),
    (12, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-012-Editora-Abril-000.jpg'),
    (13, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-013-Editora-Abril-000.jpg'),
    (14, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-014-Editora-Abril-000.jpg'),
    (15, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-015-Editora-Abril-000.jpg'),
    (16, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-016-Editora-Abril-000.jpg'),
    (17, 'https://tudohqemanga.com.br/wp-content/uploads/2024/01/Homem-Aranha-Super-Premium-017-Editora-Abril-000.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Abril')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Homem-Aranha 2ª Série')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem =
        'https://www.guiadosquadrinhos.com/edicao/homem-aranha-2-serie-n-' ||
        capa.numero::text || '/ha00402/' || (6675 + capa.numero)::text,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND trim(edicao.numero) ~ '^[0-9]+$'
  AND trim(edicao.numero)::integer = capa.numero
  AND (
      edicao.url_capa IS DISTINCT FROM capa.url_capa
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/edicao/homem-aranha-2-serie-n-' ||
          capa.numero::text || '/ha00402/' || (6675 + capa.numero)::text
  );

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Abril')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Homem-Aranha 2ª Série')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 17
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
