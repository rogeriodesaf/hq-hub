-- Cadastra o omnibus brasileiro citado pelo Crossover Nerd e o vincula ao guia mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Men: Tesouros Ocultos (Omnibus)',
    'Omnibus brasileiro que reúne a fase de John Byrne situada entre o cancelamento da série clássica e Giant-Size X-Men.',
    2023,
    2023,
    1,
    'PANINI',
    'PANINI-AXSEC001',
    'https://panini.com.br/x-men-tesouros-ocultos-omnibus',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('X-Men: Tesouros Ocultos (Omnibus)')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    quantidade_paginas, preco_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'X-Men: Tesouros Ocultos (Omnibus)',
    'Compila X-Men 94 (II), X-Men: Hidden Years 1-22, Fantastic Four (1961) 102-104, Yellow Claw 2 e Amazing Adult Fantasy 14 (II).',
    'X-Men: Tesouros Ocultos (Omnibus)',
    DATE '2023-06-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_d2o1b4b1j55dh6daigft7imr22/-S340-FWEBP',
    640,
    274.90,
    'Capa dura com sobrecapa',
    'PANINI',
    'AXSEC001',
    'https://panini.com.br/x-men-tesouros-ocultos-omnibus',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    preco_capa = EXCLUDED.preco_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('X-Men: Tesouros Ocultos (Omnibus)')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'X-Men: Tesouros Ocultos (Omnibus)',
    detalhe_referencia = 'V1 #UNICA',
    edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 21;
