-- Atualiza a fonte auditavel das capas da serie Abril volume 2.
-- Fonte: https://mega.nz/folder/SYhDwSKI#mRNrXsdW3pWJ5P7H_m4pPw
-- Arquivos CBR conferidos individualmente: 0001, 0002, 0003, 0004,
-- 0005, 0006, 0008 e 0012. As capas publicadas ficam nos assets estaticos
-- com os nomes 001.jpg, 002.jpg, 003.jpg, 004.jpg, 005.jpg, 006.jpg,
-- 008.jpg e 012.jpg, respectivamente.

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
            'Identidade editorial ambígua para a série Heróis da TV 2ª Série/Abril volume 2: % séries',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes e
     WHERE e.serie_id = 5014
       AND hqhub_normalizar_identidade(e.numero) IN
           ('1', '2', '3', '4', '5', '6', '8', '12');

    IF quantidade_edicoes <> 8 THEN
        RAISE EXCEPTION
            'Auditoria recusada: esperadas 8 edições alvo, encontradas %',
            quantidade_edicoes;
    END IF;

    UPDATE edicoes
       SET url_origem = 'https://mega.nz/folder/SYhDwSKI#mRNrXsdW3pWJ5P7H_m4pPw',
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = 5014
       AND hqhub_normalizar_identidade(numero) IN
           ('1', '2', '3', '4', '5', '6', '8', '12');
END $$;
