-- Correcao auditavel das capas de Amazing Spider-Man Annual, The (1964).
-- Identidade editorial validada em 2026-11-04: Marvel Comics, serie anual
-- iniciada em 1964. As edicoes 1 a 37 pertencem ao volume historico Comic
-- Vine 4050-2189; a edicao 42 e a excecao editorial numerada como 42 no volume
-- 4050-95808.
-- Fontes:
-- https://comicvine.gamespot.com/the-amazing-spider-man-annual/4050-2189/
-- https://comicvine.gamespot.com/amazing-spider-man-annual/4050-95808/
--
-- O catalogo possui 23 edicoes dessa identidade: 1, 2, 3, 4, 5, 10, 11, 13,
-- 14, 15, 16, 17, 18, 19, 20, 21, 23, 25, 26, 35, 36, 37 e 42. A Comic Vine
-- confirmou volume, numero e ID de cada uma. As 23 URLs responderam com imagem
-- (menor arquivo: 77.258 bytes) e o conjunto inteiro foi conferido visualmente.
-- Em producao, 18 edicoes estavam sem capa. Esta migracao nao substitui as
-- cinco capas existentes.

INSERT INTO correspondencias_series_externas
    (fonte_externa, id_volume, titulo_catalogo, editora, ano_inicio, url_fonte)
VALUES
    ('COMICVINE', '2189', 'Amazing Spider-Man Annual, The (1964)',
     'Marvel Comics', 1964,
     'https://comicvine.gamespot.com/the-amazing-spider-man-annual/4050-2189/')
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE capas_amazing_spider_man_annual_1964 (
    numero TEXT PRIMARY KEY,
    id_volume_comic_vine TEXT NOT NULL,
    id_comic_vine TEXT NOT NULL,
    url_capa TEXT NOT NULL,
    url_comic_vine TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_amazing_spider_man_annual_1964
    (numero, id_volume_comic_vine, id_comic_vine, url_capa, url_comic_vine)
VALUES
    ('1', '2189', '6837', 'https://comicvine.gamespot.com/a/uploads/original/0/4/6261-2189-6837-1-amazing-spider-man-a.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-1-the-sinister-sixa-/4000-6837/'),
    ('2', '2189', '7502', 'https://comicvine.gamespot.com/a/uploads/original/0/4/6877-2189-7502-1-amazing-spider-man-a.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-2-the-wondrous-world/4000-7502/'),
    ('3', '2189', '8905', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/4365817-03.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-3-to-become-an-aveng/4000-8905/'),
    ('4', '2189', '9714', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4218648-asman4vf8m111.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-4-the-web-and-the-fl/4000-9714/'),
    ('5', '2189', '111514', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/4365818-05.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-5-at-long-lastthe-pa/4000-111514/'),
    ('10', '2189', '15930', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437447-amazingspider_manannual10.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-10-step-into-my-parl/4000-15930/'),
    ('11', '2189', '17035', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437448-amazingspider_manannual11.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-11-spawn-of-the-spid/4000-17035/'),
    ('13', '2189', '19111', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4320597-asman13nm92m124.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-13-the-arms-of-docto/4000-19111/'),
    ('14', '2189', '20047', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4100914-asman14nm92m091.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-14-the-book-of-the-v/4000-20047/'),
    ('15', '2189', '20919', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4016720-tn15.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-15-spider-man-threat/4000-20919/'),
    ('16', '2189', '21812', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430795-amazingspider_manannual16.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-16-whos-that-lady/4000-21812/'),
    ('17', '2189', '22738', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430814-amazingspider_manannual17.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-17-heroes-and-villai/4000-22738/'),
    ('18', '2189', '64426', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430839-amazingspider_manannual18.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-18-the-scorpion-take/4000-64426/'),
    ('19', '2189', '64427', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430840-amazingspider_manannual19.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-19-fun-n-games/4000-64427/'),
    ('20', '2189', '112515', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430862-amazingspider_manannual20.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-20-man-of-the-year/4000-112515/'),
    ('21', '2189', '27607', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2459139-amazingspider_manannual21.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-21-the-wedding/4000-27607/'),
    ('23', '2189', '30692', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2749690-amazingspider_manannual23.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-23-abominations-my-s/4000-30692/'),
    ('25', '2189', '64429', 'https://comicvine.gamespot.com/a/uploads/original/5/56044/1832145-amazing_spider_man__1963_1998__annual_25n.jpeg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-25-the-vibranium-ven/4000-64429/'),
    ('26', '2189', '64430', 'https://comicvine.gamespot.com/a/uploads/original/5/56044/1811298-amazing_spider_man__1963_1998__annual_26.jpeg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-26-the-hero-killers-/4000-64430/'),
    ('35', '2189', '163390', 'https://comicvine.gamespot.com/a/uploads/original/0/40/869977-598719_asmannual_super.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-35-a-tale-of-two-jac/4000-163390/'),
    ('36', '2189', '163378', 'https://comicvine.gamespot.com/a/uploads/original/1/15776/869715-asma36a.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-36-peter-parker-must/4000-163378/'),
    ('37', '2189', '216118', 'https://comicvine.gamespot.com/a/uploads/original/0/1867/1241926-asma37.jpg', 'https://comicvine.gamespot.com/the-amazing-spider-man-annual-37-the-spider-and-th/4000-216118/'),
    ('42', '95808', '660005', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/6280586-42.jpg', 'https://comicvine.gamespot.com/amazing-spider-man-annual-42-bury-the-ledes-spider/4000-660005/');

CREATE TEMP TABLE serie_amazing_spider_man_annual_1964 (
    id BIGINT PRIMARY KEY
) ON COMMIT DROP;

INSERT INTO serie_amazing_spider_man_annual_1964 (id)
SELECT serie.id
  FROM series serie
  JOIN editoras editora ON editora.id = serie.editora_id
 WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Amazing Spider-Man Annual, The (1964)')
   AND hqhub_normalizar_titulo_serie(editora.nome) =
       hqhub_normalizar_titulo_serie('Marvel Comics')
   AND serie.ano_inicio = 1964
   AND serie.tipo_serie = 'ESTRANGEIRA'
   AND EXISTS (SELECT 1 FROM edicoes existente WHERE existente.serie_id = serie.id);

DO $$
DECLARE
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
    quantidade_invalidas INTEGER;
    quantidade_fontes_invalidas INTEGER;
    quantidade_conflitos INTEGER;
    quantidade_atualizada INTEGER;
BEGIN
    SELECT count(*) INTO quantidade_series
      FROM serie_amazing_spider_man_annual_1964;
    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): esperada uma serie com edicoes, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes edicao
      JOIN serie_amazing_spider_man_annual_1964 serie ON serie.id = edicao.serie_id;
    IF quantidade_edicoes <> 23 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): esperadas 23 edicoes cadastradas, encontradas %',
            quantidade_edicoes;
    END IF;

    IF (SELECT count(*) FROM capas_amazing_spider_man_annual_1964) <> 23 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): auditoria incompleta; esperadas 23 capas';
    END IF;

    SELECT count(*)
      INTO quantidade_fontes_invalidas
      FROM capas_amazing_spider_man_annual_1964 capa
     WHERE (capa.numero = '42' AND capa.id_volume_comic_vine <> '95808')
        OR (capa.numero <> '42' AND capa.id_volume_comic_vine <> '2189');
    IF quantidade_fontes_invalidas > 0 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): % mapeamentos usam volume Comic Vine inesperado',
            quantidade_fontes_invalidas;
    END IF;

    SELECT count(*)
      INTO quantidade_invalidas
      FROM capas_amazing_spider_man_annual_1964 capa
     WHERE (SELECT count(*)
              FROM edicoes edicao
              JOIN serie_amazing_spider_man_annual_1964 serie
                ON serie.id = edicao.serie_id
             WHERE hqhub_normalizar_identidade(edicao.numero) =
                   hqhub_normalizar_identidade(capa.numero)) <> 1;
    IF quantidade_invalidas > 0 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): % capas nao identificam uma unica edicao interna',
            quantidade_invalidas;
    END IF;

    SELECT count(*)
      INTO quantidade_conflitos
      FROM capas_amazing_spider_man_annual_1964 capa
      JOIN edicoes outra ON outra.id_comic_vine = capa.id_comic_vine
     WHERE NOT EXISTS (
               SELECT 1
                 FROM serie_amazing_spider_man_annual_1964 serie
                WHERE serie.id = outra.serie_id
           );
    IF quantidade_conflitos > 0 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): % IDs Comic Vine ja pertencem a outra serie',
            quantidade_conflitos;
    END IF;

    UPDATE edicoes edicao
       SET url_capa = CASE
               WHEN edicao.url_capa IS NULL OR trim(edicao.url_capa) = ''
               THEN capa.url_capa
               ELSE edicao.url_capa
           END,
           id_comic_vine = coalesce(
               nullif(trim(edicao.id_comic_vine), ''), capa.id_comic_vine),
           url_comic_vine = coalesce(
               nullif(trim(edicao.url_comic_vine), ''), capa.url_comic_vine),
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_amazing_spider_man_annual_1964 capa
      JOIN serie_amazing_spider_man_annual_1964 serie ON true
     WHERE edicao.serie_id = serie.id
       AND hqhub_normalizar_identidade(edicao.numero) =
           hqhub_normalizar_identidade(capa.numero);

    GET DIAGNOSTICS quantidade_atualizada = ROW_COUNT;
    IF quantidade_atualizada <> 23 THEN
        RAISE EXCEPTION
            'Amazing Spider-Man Annual, The (1964): esperadas 23 edicoes atualizadas, obtidas %',
            quantidade_atualizada;
    END IF;
END $$;
