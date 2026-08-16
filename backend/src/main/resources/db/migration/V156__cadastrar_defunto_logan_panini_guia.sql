-- Cadastra os dois encadernados brasileiros de O Defunto Logan (Panini)
-- e os vincula às referências existentes no guia de leitura mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'O Defunto Logan',
    'Série brasileira em dois encadernados que compila Dead Man Logan (2019) 1 a 12.',
    2019,
    2020,
    1,
    'PANINI',
    'PANINI-DEFUNTO-LOGAN-V1',
    'https://panini.com.br/o-defunto-logan-vol-1',
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

WITH dados(numero, titulo, descricao, data_publicacao, paginas, preco, url_capa, id_externo, url_origem) AS (VALUES
    (
        '1',
        'Pecados do Pai',
        'Logan está morrendo e decide resolver seus últimos assuntos inacabados antes que Mystério possa repetir a tragédia que destruiu os X-Men de seu mundo. Compila Dead Man Logan (2019) 1 a 6.',
        DATE '2019-12-01',
        152,
        24.90,
        'https://panini.com.br/media/catalog/product/A/M/AMVSW001.jpg',
        'AMVSW001',
        'https://panini.com.br/o-defunto-logan-vol-1'
    ),
    (
        '2',
        'Bem-vindo de Volta, Logan',
        'De volta às Terras Desoladas, Logan precisa proteger o último dos Hulk e enfrentar uma velha rivalidade em seus derradeiros dias. Compila Dead Man Logan (2019) 7 a 12.',
        DATE '2020-03-01',
        136,
        22.90,
        'https://www.comix.com.br/media/catalog/product/2/0/202655_900x900defunto.jpg',
        'AMVSW002',
        'https://www.comix.com.br/o-defunto-logan-n-02.html'
    )
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('O Defunto Logan')
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
    dado.numero,
    dado.titulo,
    dado.descricao,
    'O Defunto Logan Vol. ' || dado.numero,
    dado.data_publicacao,
    dado.url_capa,
    dado.paginas,
    dado.preco,
    '17 x 26 cm, capa cartão, lombada quadrada',
    'PANINI',
    dado.id_externo,
    dado.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM dados dado
CROSS JOIN serie_alvo serie
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

WITH referencias(posicao, numero) AS (VALUES
    (361, '1'),
    (362, '2')
), candidatos AS (
    SELECT referencia.posicao, referencia.numero, edicao.id AS edicao_id, edicao.url_capa
    FROM referencias referencia
    JOIN edicoes edicao ON trim(edicao.numero) = referencia.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('O Defunto Logan')
      AND coalesce(serie.volume, 0) = 1
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'O Defunto Logan',
    detalhe_referencia = 'V1 #' || referencia.numero,
    edicao_id = referencia.edicao_id,
    url_capa_referencia = referencia.url_capa
FROM candidatos referencia
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = referencia.posicao;
