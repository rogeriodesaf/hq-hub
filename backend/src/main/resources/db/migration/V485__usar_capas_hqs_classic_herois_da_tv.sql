-- Substitui as URLs bloqueadas do Guia dos Quadrinhos pelas capas extraídas
-- das pranchas públicas do HQs Classic, fonte indicada para esta coleção.
-- Fonte: https://hqsclassic.blogspot.com/p/herois-da-tv_29.html
-- Pranchas utilizadas: 01.JPG (edições 1–8) e 02.JPG (edições 9–16).
-- Os arquivos derivados ficam em META-INF/resources/capas/herois-da-tv-2-serie.

CREATE TEMP TABLE capas_hqs_classic_herois_tv (
    numero TEXT PRIMARY KEY,
    url_capa TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_hqs_classic_herois_tv (numero, url_capa)
VALUES
    ('1',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/001.jpg'),
    ('2',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/002.jpg'),
    ('3',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/003.jpg'),
    ('4',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/004.jpg'),
    ('5',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/005.jpg'),
    ('6',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/006.jpg'),
    ('8',  'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/008.jpg'),
    ('12', 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/012.jpg');

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

    SELECT count(*)
      INTO quantidade_edicoes
      FROM capas_hqs_classic_herois_tv capa
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
           url_origem = 'https://hqsclassic.blogspot.com/p/herois-da-tv_29.html',
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_hqs_classic_herois_tv capa
     WHERE e.serie_id = serie_alvo
       AND hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
       AND e.url_capa IS DISTINCT FROM capa.url_capa;

    UPDATE itens_ordem_leitura item
       SET url_capa_referencia = e.url_capa
      FROM edicoes e
      JOIN capas_hqs_classic_herois_tv capa
        ON hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
     WHERE item.edicao_id = e.id
       AND e.serie_id = serie_alvo
       AND item.url_capa_referencia IS DISTINCT FROM e.url_capa;
END $$;
