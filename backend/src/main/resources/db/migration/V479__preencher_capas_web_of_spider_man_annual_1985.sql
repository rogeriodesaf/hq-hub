-- Correcao auditavel das capas de Web of Spider-Man Annual (1985).
-- Identidade editorial validada em 2026-11-03: Marvel Comics, serie anual
-- iniciada em 1985, correspondente exclusivamente ao volume Comic Vine
-- 4050-3520.
-- Fonte unica: https://comicvine.gamespot.com/web-of-spider-man-annual/4050-3520/
--
-- O catalogo possui cinco edicoes dessa identidade: 1, 2, 5, 7 e 8. A Comic
-- Vine confirmou volume, numero e ID de cada uma. As cinco URLs responderam
-- com imagem (menor arquivo: 65.626 bytes) e todas as capas foram conferidas
-- visualmente, inclusive as duas ja existentes. Em producao, 1, 2 e 8 estavam
-- sem capa. Esta migracao nao substitui nenhuma capa existente.

INSERT INTO correspondencias_series_externas
    (fonte_externa, id_volume, titulo_catalogo, editora, ano_inicio, url_fonte)
VALUES
    ('COMICVINE', '3520', 'Web of Spider-Man Annual (1985)', 'Marvel Comics', 1985,
     'https://comicvine.gamespot.com/web-of-spider-man-annual/4050-3520/')
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE capas_web_of_spider_man_annual_1985 (
    numero TEXT PRIMARY KEY,
    id_comic_vine TEXT NOT NULL,
    url_capa TEXT NOT NULL,
    url_comic_vine TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_web_of_spider_man_annual_1985
    (numero, id_comic_vine, url_capa, url_comic_vine)
VALUES
    ('1', '77992', 'https://comicvine.gamespot.com/a/uploads/original/0/4/72778-3520-77992-1-web-of-spider-man-an.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-annual-1-give-me-a-hand-future-m/4000-77992/'),
    ('2', '77993', 'https://comicvine.gamespot.com/a/uploads/original/0/4/72781-3520-77993-1-web-of-spider-man-an.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-annual-2-wake-me-up-i-gotta-be-d/4000-77993/'),
    ('5', '30615', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2749663-webofspider_manannual05.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-annual-5-war-zone-new-york/4000-30615/'),
    ('7', '77996', 'https://comicvine.gamespot.com/a/uploads/original/5/56044/1637568-web_of_spider_man_annual__1985__7.jpeg', 'https://comicvine.gamespot.com/web-of-spider-man-annual-7-the-vibranium-vendetta-/4000-77996/'),
    ('8', '77997', 'https://comicvine.gamespot.com/a/uploads/original/0/4/72807-3520-77997-1-web-of-spider-man-an.jpg', 'https://comicvine.gamespot.com/web-of-spider-man-annual-8-the-dark-at-the-end-of-/4000-77997/');

CREATE TEMP TABLE serie_web_of_spider_man_annual_1985 (
    id BIGINT PRIMARY KEY
) ON COMMIT DROP;

INSERT INTO serie_web_of_spider_man_annual_1985 (id)
SELECT serie.id
  FROM series serie
  JOIN editoras editora ON editora.id = serie.editora_id
 WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Web of Spider-Man Annual (1985)')
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
    SELECT count(*) INTO quantidade_series
      FROM serie_web_of_spider_man_annual_1985;
    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): esperada uma serie com edicoes, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes edicao
      JOIN serie_web_of_spider_man_annual_1985 serie ON serie.id = edicao.serie_id;
    IF quantidade_edicoes <> 5 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): esperadas 5 edicoes cadastradas, encontradas %',
            quantidade_edicoes;
    END IF;

    IF (SELECT count(*) FROM capas_web_of_spider_man_annual_1985) <> 5 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): auditoria incompleta; esperadas 5 capas';
    END IF;

    SELECT count(*)
      INTO quantidade_invalidas
      FROM capas_web_of_spider_man_annual_1985 capa
     WHERE (SELECT count(*)
              FROM edicoes edicao
              JOIN serie_web_of_spider_man_annual_1985 serie
                ON serie.id = edicao.serie_id
             WHERE hqhub_normalizar_identidade(edicao.numero) =
                   hqhub_normalizar_identidade(capa.numero)) <> 1;
    IF quantidade_invalidas > 0 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): % capas nao identificam uma unica edicao interna',
            quantidade_invalidas;
    END IF;

    SELECT count(*)
      INTO quantidade_conflitos
      FROM capas_web_of_spider_man_annual_1985 capa
      JOIN edicoes outra ON outra.id_comic_vine = capa.id_comic_vine
     WHERE NOT EXISTS (
               SELECT 1
                 FROM serie_web_of_spider_man_annual_1985 serie
                WHERE serie.id = outra.serie_id
           );
    IF quantidade_conflitos > 0 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): % IDs Comic Vine ja pertencem a outra serie',
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
      FROM capas_web_of_spider_man_annual_1985 capa
      JOIN serie_web_of_spider_man_annual_1985 serie ON true
     WHERE edicao.serie_id = serie.id
       AND hqhub_normalizar_identidade(edicao.numero) =
           hqhub_normalizar_identidade(capa.numero);

    GET DIAGNOSTICS quantidade_atualizada = ROW_COUNT;
    IF quantidade_atualizada <> 5 THEN
        RAISE EXCEPTION
            'Web of Spider-Man Annual (1985): esperadas 5 edicoes atualizadas, obtidas %',
            quantidade_atualizada;
    END IF;
END $$;
