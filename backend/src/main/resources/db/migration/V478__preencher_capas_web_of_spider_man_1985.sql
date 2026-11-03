-- Correcao auditavel das capas de Web of Spider-Man (1985).
-- Identidade editorial validada em 2026-11-03: Marvel Comics, serie iniciada em
-- 1985, correspondente exclusivamente ao volume Comic Vine 4050-3519.
-- Fonte: https://comicvine.gamespot.com/web-of-spider-man/4050-3519/
--
-- O catalogo possui 48 edicoes dessa identidade em duas series legadas: 47 em
-- "Marvel Comics" e a edicao 74 em "Marvel Comics,". Nao ha sobreposicao de
-- numeros entre elas. A Comic Vine confirmou numero e ID das 48 edicoes; todas
-- as URLs responderam com imagem (menor arquivo: 62.015 bytes) e o conjunto foi
-- conferido visualmente. Em producao, 31 dessas edicoes estavam sem capa.
-- Esta migracao nao substitui nenhuma capa existente.

INSERT INTO correspondencias_series_externas
    (fonte_externa, id_volume, titulo_catalogo, editora, ano_inicio, url_fonte)
VALUES
    ('COMICVINE', '3519', 'Web of Spider-Man (1985)', 'Marvel Comics', 1985,
     'https://comicvine.gamespot.com/web-of-spider-man/4050-3519/')
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE capas_web_of_spider_man_1985 (
    numero TEXT PRIMARY KEY,
    id_comic_vine TEXT NOT NULL,
    url_capa TEXT NOT NULL,
    url_comic_vine TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_web_of_spider_man_1985
    (numero, id_comic_vine, url_capa, url_comic_vine)
VALUES
    ('1', '25407', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4087937-wosm1nm92m084.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-1-til-death-do-us-part/4000-25407/'),
    ('2', '25501', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444129-webofspider_man002.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-2-treasures/4000-25501/'),
    ('3', '25603', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444131-webofspider_man003.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-3-iron-bars-do-not-a-prison-make/4000-25603/'),
    ('4', '25702', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444138-webofspider_man004.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-4-arms-and-the-man/4000-25702/'),
    ('5', '25802', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444146-webofspider_man005.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-5-the-enemy-within/4000-25802/'),
    ('6', '25897', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444147-webofspider_man006.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-6-gold-rush/4000-25897/'),
    ('7', '26001', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444153-webofspider_man007.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-7-welcome-to-my-nightmare/4000-26001/'),
    ('8', '26107', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444161-webofspider_man008.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-8-local-super-hero/4000-26107/'),
    ('9', '26212', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444166-webofspider_man009.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-9-the-twilight-heroes/4000-26212/'),
    ('10', '26415', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444168-webofspider_man010.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-10-there-but-for-fortune/4000-26415/'),
    ('11', '26521', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444172-webofspider_man011.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-11-have-you-seenthat-vigilante-m/4000-26521/'),
    ('12', '26615', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444177-webofspider_man012.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-12-law-and-order/4000-26615/'),
    ('13', '26712', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444179-webofspider_man013.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-13-point-of-view/4000-26712/'),
    ('14', '26806', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444187-webofspider_man014.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-14-all-that-glitters/4000-26806/'),
    ('15', '26904', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444202-webofspider_man015.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-15-fox-hunt/4000-26904/'),
    ('16', '26999', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444212-webofspider_man016.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-16-underworld/4000-26999/'),
    ('17', '27095', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444214-webofspider_man017.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-17-the-magma-solution/4000-27095/'),
    ('18', '27191', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444216-webofspider_man018.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-18-the-longest-road/4000-27191/'),
    ('19', '27288', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444219-webofspider_man019.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-19-humbug/4000-27288/'),
    ('22', '27692', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2444222-webofspider_man022.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-22-profit-of-doom/4000-27692/'),
    ('23', '27804', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2433175-webofspider_man023.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-23-slip-slydin-away/4000-27804/'),
    ('24', '27913', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2433184-webofspider_man024.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-24-high-takes/4000-27913/'),
    ('31', '28701', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2461461-webofspider_man031.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-31-kraven-s-last-hunt-part-one-t/4000-28701/'),
    ('32', '28819', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2461465-webofspider_man032.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-32-kraven-s-last-hunt-part-four-/4000-28819/'),
    ('44', '30327', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2677787-webofspider_man044.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-44-reunion/4000-30327/'),
    ('47', '30906', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2691492-webofspider_man047.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-47-the-face-in-the-mirror/4000-30906/'),
    ('51', '31342', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2719928-webofspider_man051.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-51-the-crimelord-of-new-york/4000-31342/'),
    ('56', '31886', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2781886-webofspider_man056.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-56-skin-deep/4000-31886/'),
    ('57', '31936', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2781913-webofspider_man057.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-57-flesh-and-blood/4000-31936/'),
    ('58', '32019', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2782068-webofspider_man058.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-58-rematch/4000-32019/'),
    ('73', '33894', 'https://comicvine.gamespot.com/a/uploads/original/0/4/30467-3519-33894-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-73-art-attack-part-1-head-quest/4000-33894/'),
    ('74', '34008', 'https://comicvine.gamespot.com/a/uploads/original/0/4/30563-3519-34008-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-74-art-attack-part-2-art-and-sou/4000-34008/'),
    ('101', '37378', 'https://comicvine.gamespot.com/a/uploads/original/10/108980/2198482-web_of_spider_man__101__1993_.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-101-maximum-carnage-part-2-darkl/4000-37378/'),
    ('102', '37530', 'https://comicvine.gamespot.com/a/uploads/original/0/4/33612-3519-37530-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-102-maximum-carnage-part-6-sinki/4000-37530/'),
    ('103', '37672', 'https://comicvine.gamespot.com/a/uploads/original/0/4/33742-3519-37672-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-103-maximum-carnage-part-10-sin-/4000-37672/'),
    ('117', '65542', 'https://comicvine.gamespot.com/a/uploads/original/11125/111254576/5674579-117.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-117-power-and-responsibility-par/4000-65542/'),
    ('118', '65543', 'https://comicvine.gamespot.com/a/uploads/original/11125/111254576/5558351-118.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-118-the-exile-returns-part-1-of-/4000-65543/'),
    ('119', '65544', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50088-3519-65544-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-119-the-exile-returns-part-3-of-/4000-65544/'),
    ('120', '65545', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50089-3519-65545-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-120-web-of-life-part-1-lure-of-t/4000-65545/'),
    ('121', '65546', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50090-3519-65546-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-121-web-of-life-part-3-the-hunti/4000-65546/'),
    ('122', '65547', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50091-3519-65547-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-122-smoke-and-mirrors-part-1-the/4000-65547/'),
    ('123', '65548', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50092-3519-65548-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-123-players-and-pawns-part-2-tru/4000-65548/'),
    ('124', '65549', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50093-3519-65549-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-124-the-mark-of-kaine-part-1-wal/4000-65549/'),
    ('125', '65550', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50094-3519-65550-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-125-lives-unlived-shining-armor/4000-65550/'),
    ('126', '65551', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50095-3519-65551-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-126-the-trial-of-peter-parker-pa/4000-65551/'),
    ('127', '65552', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50096-3519-65552-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-127-maximum-clonage-part-2-the-l/4000-65552/'),
    ('128', '65553', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50097-3519-65553-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-128-exiled-part-1-who-will-wear-/4000-65553/'),
    ('129', '65554', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50098-3519-65554-1-web-of-spider-man.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-129-time-bomb-part-2-by-my-hand-/4000-65554/');

CREATE TEMP TABLE series_web_of_spider_man_1985 (id BIGINT PRIMARY KEY) ON COMMIT DROP;

INSERT INTO series_web_of_spider_man_1985 (id)
SELECT serie.id
  FROM series serie
  JOIN editoras editora ON editora.id = serie.editora_id
 WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Web of Spider-Man (1985)')
   AND hqhub_normalizar_titulo_serie(editora.nome) =
       hqhub_normalizar_titulo_serie('Marvel Comics')
   AND serie.ano_inicio = 1985
   AND serie.tipo_serie = 'ESTRANGEIRA'
   AND EXISTS (SELECT 1 FROM edicoes existente WHERE existente.serie_id = serie.id);

DO $$
DECLARE
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
    quantidade_invalidas INTEGER;
    quantidade_conflitos INTEGER;
    quantidade_atualizada INTEGER;
BEGIN
    SELECT count(*) INTO quantidade_series FROM series_web_of_spider_man_1985;
    IF quantidade_series <> 2 THEN
        RAISE EXCEPTION
            'Web of Spider-Man (1985): esperadas duas series legadas com edicoes, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes edicao
      JOIN series_web_of_spider_man_1985 serie ON serie.id = edicao.serie_id;
    IF quantidade_edicoes <> 48 THEN
        RAISE EXCEPTION
            'Web of Spider-Man (1985): esperadas 48 edicoes cadastradas, encontradas %',
            quantidade_edicoes;
    END IF;

    IF (SELECT count(*) FROM capas_web_of_spider_man_1985) <> 48 THEN
        RAISE EXCEPTION 'Web of Spider-Man (1985): auditoria incompleta; esperadas 48 capas';
    END IF;

    SELECT count(*)
      INTO quantidade_invalidas
      FROM capas_web_of_spider_man_1985 capa
     WHERE (SELECT count(*)
              FROM edicoes edicao
              JOIN series_web_of_spider_man_1985 serie ON serie.id = edicao.serie_id
             WHERE hqhub_normalizar_identidade(edicao.numero) =
                   hqhub_normalizar_identidade(capa.numero)) <> 1;
    IF quantidade_invalidas > 0 THEN
        RAISE EXCEPTION
            'Web of Spider-Man (1985): % capas nao identificam uma unica edicao interna',
            quantidade_invalidas;
    END IF;

    SELECT count(*)
      INTO quantidade_conflitos
      FROM capas_web_of_spider_man_1985 capa
      JOIN edicoes outra ON outra.id_comic_vine = capa.id_comic_vine
     WHERE NOT EXISTS (
               SELECT 1
                 FROM series_web_of_spider_man_1985 serie
                WHERE serie.id = outra.serie_id
           );
    IF quantidade_conflitos > 0 THEN
        RAISE EXCEPTION
            'Web of Spider-Man (1985): % IDs Comic Vine ja pertencem a outra serie',
            quantidade_conflitos;
    END IF;

    UPDATE edicoes edicao
       SET url_capa = CASE
               WHEN edicao.url_capa IS NULL OR trim(edicao.url_capa) = ''
               THEN capa.url_capa
               ELSE edicao.url_capa
           END,
           id_comic_vine = coalesce(nullif(trim(edicao.id_comic_vine), ''), capa.id_comic_vine),
           url_comic_vine = coalesce(nullif(trim(edicao.url_comic_vine), ''), capa.url_comic_vine),
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_web_of_spider_man_1985 capa
      JOIN series_web_of_spider_man_1985 serie ON true
     WHERE edicao.serie_id = serie.id
       AND hqhub_normalizar_identidade(edicao.numero) =
           hqhub_normalizar_identidade(capa.numero);

    GET DIAGNOSTICS quantidade_atualizada = ROW_COUNT;
    IF quantidade_atualizada <> 48 THEN
        RAISE EXCEPTION
            'Web of Spider-Man (1985): esperadas 48 edicoes atualizadas, obtidas %',
            quantidade_atualizada;
    END IF;
END $$;
