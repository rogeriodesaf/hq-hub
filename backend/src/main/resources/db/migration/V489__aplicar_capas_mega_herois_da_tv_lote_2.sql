-- Atualiza o segundo lote de capas da serie Heróis da TV 2ª Série/Abril volume 2.
-- Fonte única: https://mega.nz/folder/SYhDwSKI#mRNrXsdW3pWJ5P7H_m4pPw
-- CBRs extraídos e capas conferidas visualmente, número a número:
-- 0007, 0009, 0013, 0014, 0015, 0016, 0019, 0020, 0021, 0022,
-- 0025, 0027 e 0028. A edição 0024 foi excluída por conter arquivo
-- extraído inválido, sem imagem utilizável.

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
            'Identidade editorial ambígua para Heróis da TV 2ª Série/Abril volume 2: % séries',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes e
     WHERE e.serie_id = 5014
       AND hqhub_normalizar_identidade(e.numero) IN
           ('7', '9', '13', '14', '15', '16', '19', '20', '21', '22', '25', '27', '28');

    IF quantidade_edicoes <> 13 THEN
        RAISE EXCEPTION
            'Auditoria recusada: esperadas 13 edições alvo, encontradas %',
            quantidade_edicoes;
    END IF;

    UPDATE edicoes
       SET url_capa = CASE hqhub_normalizar_identidade(numero)
           WHEN '7'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/007.jpg?versao=mega-20261126-lote2'
           WHEN '9'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/009.jpg?versao=mega-20261126-lote2'
           WHEN '13' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/013.jpg?versao=mega-20261126-lote2'
           WHEN '14' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/014.jpg?versao=mega-20261126-lote2'
           WHEN '15' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/015.jpg?versao=mega-20261126-lote2'
           WHEN '16' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/016.jpg?versao=mega-20261126-lote2'
           WHEN '19' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/019.jpg?versao=mega-20261126-lote2'
           WHEN '20' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/020.jpg?versao=mega-20261126-lote2'
           WHEN '21' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/021.jpg?versao=mega-20261126-lote2'
           WHEN '22' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/022.jpg?versao=mega-20261126-lote2'
           WHEN '25' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/025.jpg?versao=mega-20261126-lote2'
           WHEN '27' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/027.jpg?versao=mega-20261126-lote2'
           WHEN '28' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/028.jpg?versao=mega-20261126-lote2'
           ELSE url_capa
           END,
           url_origem = 'https://mega.nz/folder/SYhDwSKI#mRNrXsdW3pWJ5P7H_m4pPw',
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = 5014
       AND hqhub_normalizar_identidade(numero) IN
           ('7', '9', '13', '14', '15', '16', '19', '20', '21', '22', '25', '27', '28');

    UPDATE itens_ordem_leitura item
       SET url_capa_referencia = e.url_capa
      FROM edicoes e
     WHERE item.edicao_id = e.id
       AND e.serie_id = 5014
       AND hqhub_normalizar_identidade(e.numero) IN
           ('7', '9', '13', '14', '15', '16', '19', '20', '21', '22', '25', '27', '28');
END $$;
