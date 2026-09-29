-- Corrige as 84 capas de Berserk 1a Serie/Panini, volume 1.
-- A correspondencia numero a numero e os links de origem foram conferidos na
-- galeria be01101 do Guia dos Quadrinhos. As imagens ficam hospedadas no
-- proprio repositorio para evitar indisponibilidade por bloqueio de hotlink.

WITH capas(numero, id_guia) AS (VALUES
    (1, 20657),
    (2, 20658),
    (3, 20659),
    (4, 20660),
    (5, 20661),
    (6, 20662),
    (7, 20663),
    (8, 20664),
    (9, 20665),
    (10, 20666),
    (11, 20667),
    (12, 20668),
    (13, 20669),
    (14, 20670),
    (15, 20671),
    (16, 20672),
    (17, 20673),
    (18, 20674),
    (19, 20676),
    (20, 20677),
    (21, 20678),
    (22, 20680),
    (23, 32788),
    (24, 32790),
    (25, 41556),
    (26, 41557),
    (27, 52200),
    (28, 52201),
    (29, 52202),
    (30, 52241),
    (31, 57854),
    (32, 58369),
    (33, 62397),
    (34, 63485),
    (35, 65913),
    (36, 67573),
    (37, 69135),
    (38, 69594),
    (39, 70651),
    (40, 72201),
    (41, 73287),
    (42, 73941),
    (43, 75734),
    (44, 76344),
    (45, 77163),
    (46, 78168),
    (47, 79469),
    (48, 79887),
    (49, 80551),
    (50, 80817),
    (51, 81594),
    (52, 82183),
    (53, 82759),
    (54, 82999),
    (55, 84263),
    (56, 84619),
    (57, 85202),
    (58, 85315),
    (59, 86515),
    (60, 86652),
    (61, 87850),
    (62, 87994),
    (63, 88641),
    (64, 88958),
    (65, 89585),
    (66, 90123),
    (67, 91853),
    (68, 92104),
    (69, 93183),
    (70, 93541),
    (71, 97658),
    (72, 98907),
    (73, 105253),
    (74, 106843),
    (75, 126759),
    (76, 127422),
    (77, 134451),
    (78, 135155),
    (79, 144454),
    (80, 145582),
    (81, 174023),
    (82, 174026),
    (83, 178440),
    (84, 178441)
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie(U&'Berserk 1\00AA S\00E9rie')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa =
        'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'berserk-1-serie-panini/' || lpad(capa.numero::text, 2, '0') || '.jpg',
    url_origem =
        'https://www.guiadosquadrinhos.com/edicao/berserk-1-serie-n-' ||
        capa.numero::text || '/be01101/' || capa.id_guia::text,
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
          'berserk-1-serie-panini/' || lpad(capa.numero::text, 2, '0') || '.jpg'
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/edicao/berserk-1-serie-n-' ||
          capa.numero::text || '/be01101/' || capa.id_guia::text
  );

-- Mantem as capas armazenadas nos guias de leitura sincronizadas.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie(U&'Berserk 1\00AA S\00E9rie')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 84
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
