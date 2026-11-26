-- Corrige capas confirmadamente incorretas ou ausentes de Heróis da TV 2ª Série/Abril.
--
-- Identidade editorial conferida:
--   coleção: Heróis da TV 2ª Série
--   editora: Abril
--   volume: 2
--   fonte de conferência visual: https://hqsclassic.blogspot.com/p/herois-da-tv_29.html
--   referência editorial: https://www.guiadosquadrinhos.com/capas/herois-da-tv-2-serie/htv0302
--
-- A galeria do HQs Classic apresenta as capas em pranchas numeradas por sequência.
-- A conferência visual das pranchas 01 e 02 confirmou as correspondências 1–6,
-- 8 e 12. As capas 1–6 cadastradas eram de Grandes Heróis Marvel, e 8 e 12
-- estavam sem imagem. As demais edições não são alteradas nesta migração.

CREATE TEMP TABLE capas_herois_tv_2_correcao (
    numero TEXT PRIMARY KEY,
    url_capa TEXT NOT NULL,
    url_origem TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_herois_tv_2_correcao (numero, url_capa, url_origem)
VALUES
    ('1',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6274&path=abril/h/htv0302001.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-1/htv0302/6274'),
    ('2',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6275&path=abril/h/htv0302002.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-2/htv0302/6275'),
    ('3',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6276&path=abril/h/htv0302003.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-3/htv0302/6276'),
    ('4',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6277&path=abril/h/htv0302004.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-4/htv0302/6277'),
    ('5',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6278&path=abril/h/htv0302005.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-5/htv0302/6278'),
    ('6',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6279&path=abril/h/htv0302006.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-6/htv0302/6279'),
    ('8',  'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6281&path=abril/h/htv0302008.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-8/htv0302/6281'),
    ('12', 'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=6285&path=abril/h/htv0302012.jpg', 'https://www.guiadosquadrinhos.com/edicao/herois-da-tv-2-serie-n-12/htv0302/6285');

DO $$
DECLARE
    serie_alvo BIGINT;
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
BEGIN
    SELECT count(*), min(s.id)
      INTO quantidade_series, serie_alvo
      FROM series s
      JOIN editoras editora ON editora.id = s.editora_id
     WHERE s.id = 5014
       AND hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('Heróis da TV 2ª Série')
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Abril')
       AND coalesce(s.volume, 1) = 2;

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Identidade editorial ambígua para Heróis da TV 2ª Série/Abril volume 2: % séries',
            quantidade_series;
    END IF;

    IF (SELECT count(*) FROM capas_herois_tv_2_correcao) <> 8 THEN
        RAISE EXCEPTION 'Auditoria incompleta: eram esperadas 8 correções de capa';
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM capas_herois_tv_2_correcao capa
     WHERE (SELECT count(*)
              FROM edicoes e
             WHERE e.serie_id = serie_alvo
               AND hqhub_normalizar_identidade(e.numero) =
                   hqhub_normalizar_identidade(capa.numero)) <> 1;

    IF quantidade_edicoes <> 0 THEN
        RAISE EXCEPTION
            'Auditoria recusada: % números não identificam uma única edição da coleção',
            quantidade_edicoes;
    END IF;

    UPDATE edicoes e
       SET url_capa = capa.url_capa,
           url_origem = capa.url_origem,
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_herois_tv_2_correcao capa
     WHERE e.serie_id = serie_alvo
       AND hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
       AND (e.url_capa IS DISTINCT FROM capa.url_capa
            OR e.url_origem IS DISTINCT FROM capa.url_origem);

    UPDATE itens_ordem_leitura item
       SET url_capa_referencia = e.url_capa
      FROM edicoes e
      JOIN capas_herois_tv_2_correcao capa
        ON hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
     WHERE item.edicao_id = e.id
       AND e.serie_id = serie_alvo
       AND item.url_capa_referencia IS DISTINCT FROM e.url_capa;
END $$;
