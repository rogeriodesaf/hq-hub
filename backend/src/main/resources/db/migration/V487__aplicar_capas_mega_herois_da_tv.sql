-- Reaplica as URLs das capas do Mega depois do cadastro da série 5014.
-- A migração anterior registrou os assets, mas a série pode ter sido importada
-- depois dela; por isso este passo atualiza explicitamente cada edição alvo.

CREATE TEMP TABLE capas_mega_herois_tv (
    numero TEXT PRIMARY KEY,
    url_capa TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO capas_mega_herois_tv (numero, url_capa)
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
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
BEGIN
    SELECT count(*)
      INTO quantidade_series
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
            'Identidade editorial ambígua para a série 5014: % séries',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes e
      JOIN capas_mega_herois_tv capa
        ON hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
     WHERE e.serie_id = 5014;

    IF quantidade_edicoes <> 8 THEN
        RAISE EXCEPTION
            'Auditoria recusada: esperadas 8 edições alvo, encontradas %',
            quantidade_edicoes;
    END IF;

    UPDATE edicoes e
       SET url_capa = capa.url_capa,
           url_origem = 'https://mega.nz/folder/SYhDwSKI#mRNrXsdW3pWJ5P7H_m4pPw',
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_mega_herois_tv capa
     WHERE e.serie_id = 5014
       AND hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero);

    UPDATE itens_ordem_leitura item
       SET url_capa_referencia = e.url_capa
      FROM edicoes e
      JOIN capas_mega_herois_tv capa
        ON hqhub_normalizar_identidade(e.numero) =
           hqhub_normalizar_identidade(capa.numero)
     WHERE item.edicao_id = e.id
       AND e.serie_id = 5014;
END $$;
