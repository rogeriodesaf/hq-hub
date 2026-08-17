-- Cadastra X-Men: Trevas (Panini, 2019), vincula-o ao guia e substitui a
-- capa de Império Secreto pela imagem direta do encadernado Panini de 2023.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Men Trevas',
    'Especial brasileiro que reúne histórias de X-Men: Black dedicadas aos grandes antagonistas mutantes.',
    2019, 2019, 1, 'COMIX', '98540020160001',
    'https://www.comix.com.br/x-men-trevas.html',
    editora.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
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
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men Trevas')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    quantidade_paginas, formato, fonte_externa, id_externo, url_origem,
    serie_id, data_criacao, data_atualizacao
)
SELECT
    '1', 'X-Men Trevas',
    'Magneto, Emma Frost, Mística, Fanático, Mojo e Apocalipse protagonizam histórias sobre os grandes adversários dos X-Men.',
    'X-Men Trevas', DATE '2019-11-08',
    'https://images.tcdn.com.br/img/img_prod/1323385/x_men_trevas_panini_19723_1_705ab512710197a00849d77fc795e362.jpg',
    160, '17 x 26 cm, capa cartão, lombada quadrada',
    'COMIX', '98540020160001', 'https://www.comix.com.br/x-men-trevas.html',
    serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH edicao_trevas AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men Trevas')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_trevas edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 363;

WITH edicao_imperio AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Império Secreto')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
    ORDER BY edicao.id
    LIMIT 1
), atualizada AS (
    UPDATE edicoes edicao
    SET url_capa = 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2154088-1000-1000/lv504191_1.jpg',
        quantidade_paginas = 480,
        formato = '17 x 26 cm, capa dura',
        fonte_externa = 'LIVRARIAS_CURITIBA',
        id_externo = 'LV504191',
        url_origem = 'https://www.livrariascuritiba.com.br/imperio-secreto-lv504191/p',
        data_atualizacao = CURRENT_TIMESTAMP
    FROM edicao_imperio alvo
    WHERE edicao.id = alvo.id
    RETURNING edicao.id, edicao.url_capa
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM atualizada edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 392;
