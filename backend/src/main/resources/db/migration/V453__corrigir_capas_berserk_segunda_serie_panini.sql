-- Corrige as 42 capas regulares de Berserk 2a Serie/Panini, volume 1.
-- A galeria be011104 possui tambem variantes especiais dos numeros 41 e 42;
-- esta migracao usa os registros regulares 174024 e 180470, respectivamente.
-- As imagens ficam no repositorio para evitar indisponibilidade por hotlink.

WITH capas(numero, id_guia) AS (VALUES
    (1, 111212),
    (2, 112378),
    (3, 113897),
    (4, 114743),
    (5, 116399),
    (6, 117142),
    (7, 118912),
    (8, 119909),
    (9, 120923),
    (10, 122771),
    (11, 123587),
    (12, 124545),
    (13, 125428),
    (14, 126160),
    (15, 127035),
    (16, 127849),
    (17, 129621),
    (18, 130637),
    (19, 133519),
    (20, 134237),
    (21, 134987),
    (22, 136843),
    (23, 137481),
    (24, 139483),
    (25, 141133),
    (26, 142312),
    (27, 142671),
    (28, 143896),
    (29, 145419),
    (30, 147050),
    (31, 148155),
    (32, 149164),
    (33, 149894),
    (34, 151571),
    (35, 153205),
    (36, 153875),
    (37, 154838),
    (38, 155829),
    (39, 156601),
    (40, 157415),
    (41, 174024),
    (42, 180470)
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie(U&'Berserk 2\00AA S\00E9rie')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa =
        'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'berserk-2-serie-panini/' || lpad(capa.numero::text, 2, '0') || '.jpg',
    url_origem =
        'https://www.guiadosquadrinhos.com/edicao/berserk-2-serie-n-' ||
        capa.numero::text || '/be011104/' || capa.id_guia::text,
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
          'berserk-2-serie-panini/' || lpad(capa.numero::text, 2, '0') || '.jpg'
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/edicao/berserk-2-serie-n-' ||
          capa.numero::text || '/be011104/' || capa.id_guia::text
  );

-- Mantem as capas armazenadas nos guias de leitura sincronizadas.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie(U&'Berserk 2\00AA S\00E9rie')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 42
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
