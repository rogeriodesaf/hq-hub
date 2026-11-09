-- Vincula a republicacao brasileira de A Saga do Batman V3 #8
-- a Batman 5a Serie #19, da Abril.
--
-- Identidade validada no Guia dos Quadrinhos:
-- origem: A Saga do Batman - 3a Serie / Panini
--         https://www.guiadosquadrinhos.com/capas/saga-do-batman-a-3-serie/sa011301
-- destino: Batman 5a Serie - n. 19 / Abril
--          https://guiadosquadrinhos.com/edicao/batman-5-serie-n-19/bt00305/4834
-- A relacao e gravada da edicao Panini para a edicao Abril, como
-- REPUBLICADA_EM, sem substituir vinculos anteriores.

DO $$
DECLARE
    origem_id BIGINT;
    destino_id BIGINT;
    quantidade_origem INTEGER;
    quantidade_destino INTEGER;
BEGIN
    SELECT count(*), min(edicao.id)
      INTO quantidade_origem, origem_id
      FROM edicoes edicao
      JOIN series serie ON serie.id = edicao.serie_id
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
       AND coalesce(serie.volume, 1) = 3
       AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
           hqhub_normalizar_titulo_serie('A Saga do Batman'),
           hqhub_normalizar_titulo_serie('Saga do Batman, A')
       )
       AND hqhub_normalizar_identidade(edicao.numero) = '8';

    IF quantidade_origem <> 1 THEN
        RAISE EXCEPTION
            'A Saga do Batman V3 #8: esperada 1 edicao Panini, encontradas %',
            quantidade_origem;
    END IF;

    SELECT count(*), min(edicao.id)
      INTO quantidade_destino, destino_id
      FROM edicoes edicao
      JOIN series serie ON serie.id = edicao.serie_id
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'abril%'
       AND coalesce(serie.volume, 1) = 5
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Batman 5ª Série')
       AND hqhub_normalizar_identidade(edicao.numero) = '19';

    IF quantidade_destino <> 1 THEN
        RAISE EXCEPTION
            'Batman 5a Serie #19: esperada 1 edicao Abril, encontradas %',
            quantidade_destino;
    END IF;

    INSERT INTO publicacoes_relacionadas (
        edicao_origem_id,
        edicao_destino_id,
        tipo,
        fonte_externa,
        url_origem,
        observacoes,
        data_criacao,
        data_atualizacao
    ) VALUES (
        origem_id,
        destino_id,
        'REPUBLICADA_EM',
        'GUIA_BATMAN',
        'https://www.guiadosquadrinhos.com/capas/saga-do-batman-a-3-serie/sa011301',
        'Correspondencia validada entre A Saga do Batman V3 #8 (Panini) e Batman 5a Serie #19 (Abril).',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (edicao_origem_id, edicao_destino_id, tipo) DO UPDATE
       SET fonte_externa = EXCLUDED.fonte_externa,
           url_origem = EXCLUDED.url_origem,
           observacoes = EXCLUDED.observacoes,
           data_atualizacao = CURRENT_TIMESTAMP;
END $$;
