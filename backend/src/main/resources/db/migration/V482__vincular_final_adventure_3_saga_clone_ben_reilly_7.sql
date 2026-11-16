-- Vincula Spider-Man: The Final Adventure #3 à edição brasileira
-- Homem-Aranha: A Saga do Clone - Ben Reilly #7, da Panini.
--
-- Origem validada pela referência do Guia dos Quadrinhos e pela identidade
-- Comic Vine do volume 4050-21004, edição 3:
-- https://www.guiadosquadrinhos.com/edicao-estrangeira/spider-man-the-final-adventure-(1995)-n-3/5640/39386
-- https://comicvine.gamespot.com/spider-man-the-final-adventure/4050-21004/
-- Destino identificado no catálogo por título, editora e número, para não
-- depender de IDs locais entre ambientes.

DO $$
DECLARE
    origem_id BIGINT;
    destino_id BIGINT;
    historia_id BIGINT;
    quantidade_origem INTEGER;
    quantidade_destino INTEGER;
BEGIN
    SELECT count(*), min(edicao.id)
      INTO quantidade_origem, origem_id
      FROM edicoes edicao
      JOIN series serie ON serie.id = edicao.serie_id
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE (
             edicao.id_comic_vine IN ('125770', '4000-125770')
             OR (edicao.fonte_externa = 'COMICVINE'
                 AND edicao.id_externo IN ('125770', '4000-125770'))
           )
       AND hqhub_normalizar_identidade(edicao.numero) = '3'
       AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
           hqhub_normalizar_titulo_serie('Spider-Man: The Final Adventure'),
           hqhub_normalizar_titulo_serie('Spider-Man: The Final Adventure (1995)'))
       AND hqhub_normalizar_titulo_serie(editora.nome) IN (
           hqhub_normalizar_titulo_serie('Marvel'),
           hqhub_normalizar_titulo_serie('Marvel Comics'))
       AND EXISTS (
           SELECT 1
             FROM conteudos_edicoes conteudo_origem
             JOIN historias historia_origem
               ON historia_origem.id = conteudo_origem.historia_id
            WHERE conteudo_origem.edicao_id = edicao.id
              AND hqhub_normalizar_identidade(historia_origem.titulo) =
                  hqhub_normalizar_identidade('À flor da pele'));

    IF quantidade_origem <> 1 THEN
        RAISE EXCEPTION
            'Spider-Man: The Final Adventure #3: esperada 1 edição Comic Vine, encontradas %',
            quantidade_origem;
    END IF;

    SELECT count(*), min(edicao.id)
      INTO quantidade_destino, destino_id
      FROM edicoes edicao
      JOIN series serie ON serie.id = edicao.serie_id
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Homem-Aranha: A Saga do Clone - Ben Reilly')
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_identidade(edicao.numero) = '7';

    IF quantidade_destino <> 1 THEN
        RAISE EXCEPTION
            'A Saga do Clone - Ben Reilly #7: esperada 1 edição Panini, encontradas %',
            quantidade_destino;
    END IF;

    SELECT historia.id
      INTO historia_id
      FROM historias historia
      JOIN conteudos_edicoes conteudo ON conteudo.historia_id = historia.id
     WHERE conteudo.edicao_id = origem_id
       AND hqhub_normalizar_identidade(historia.titulo) = hqhub_normalizar_identidade('À flor da pele')
     ORDER BY historia.id
     LIMIT 1;

    IF historia_id IS NULL THEN
        RAISE EXCEPTION
            'Não foi encontrada a história À flor da pele vinculada à origem %', origem_id;
    END IF;

    INSERT INTO publicacoes_historias (
        historia_id, edicao_original_id, edicao_publicada_id, status,
        tipo_publicacao_historia, titulo_usado, paginas_publicadas,
        fonte_externa, url_origem, observacoes, fonte_informacao,
        url_fonte_informacao, status_validacao, data_criacao, data_atualizacao
    ) VALUES (
        historia_id, origem_id, destino_id, 'COMPLETA',
        'PUBLICACAO_BRASILEIRA', 'À flor da pele', NULL,
        'PANINI', NULL,
        'Vínculo adicional da edição Panini #7 com Spider-Man: The Final Adventure #3.',
        'Panini / referência editorial informada pelo usuário',
        'https://www.guiadosquadrinhos.com/edicao-estrangeira/spider-man-the-final-adventure-(1995)-n-3/5640/39386',
        'APROVADA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    )
    ON CONFLICT ON CONSTRAINT uk_publicacoes_historias_historia_edicao DO UPDATE SET
        edicao_original_id = EXCLUDED.edicao_original_id,
        status = EXCLUDED.status,
        tipo_publicacao_historia = EXCLUDED.tipo_publicacao_historia,
        titulo_usado = EXCLUDED.titulo_usado,
        fonte_externa = EXCLUDED.fonte_externa,
        url_origem = EXCLUDED.url_origem,
        observacoes = EXCLUDED.observacoes,
        fonte_informacao = EXCLUDED.fonte_informacao,
        url_fonte_informacao = EXCLUDED.url_fonte_informacao,
        status_validacao = EXCLUDED.status_validacao,
        data_atualizacao = CURRENT_TIMESTAMP;
END $$;
