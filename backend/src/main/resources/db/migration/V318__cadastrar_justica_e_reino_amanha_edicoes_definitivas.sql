-- Cadastra Justiça - Edição Definitiva e Reino do Amanhã - Edição Definitiva,
-- ambas publicadas pela Panini, com capas conferidas em lojistas brasileiros.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

WITH obras(titulo, descricao, ano, id_externo, url_origem) AS (VALUES
    ('Justiça - Edição Definitiva',
     'Edição definitiva da maxissérie Justiça, de Alex Ross, Jim Krueger e Doug Braithwaite.',
     2017, 'justica-edicao-definitiva-panini',
     'https://www.comix.com.br/justica-edic-o-definitiva-30576.html'),
    ('Reino do Amanhã - Edição Definitiva',
     'Edição definitiva da minissérie Reino do Amanhã, de Mark Waid e Alex Ross.',
     2013, 'reino-do-amanha-edicao-definitiva-panini',
     'https://universohq.com/noticias/capa-e-detalhes-de-o-reino-amanha-edicao-definitiva/')
)
INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    obra.titulo, obra.descricao, obra.ano, obra.ano, 1, 'LOJISTAS_BRASILEIROS',
    obra.id_externo, obra.url_origem, editora.id, 'BRASILEIRA',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM obras obra
CROSS JOIN LATERAL (
    SELECT id
    FROM editoras
    WHERE hqhub_normalizar_titulo_serie(nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY id
    LIMIT 1
) editora
WHERE NOT EXISTS (
    SELECT 1
    FROM series existente
    WHERE existente.editora_id = editora.id
      AND coalesce(existente.volume, 0) = 1
      AND hqhub_normalizar_titulo_serie(existente.titulo) =
          hqhub_normalizar_titulo_serie(obra.titulo)
)
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH obras(
    serie_id_externo, titulo, descricao, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, id_edicao, url_origem
) AS (VALUES
    ('justica-edicao-definitiva-panini',
     'Justiça - Edição Definitiva',
     'Reúne Justice (2005) #1-12, de Alex Ross, Jim Krueger e Doug Braithwaite.',
     DATE '2017-10-01',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/4/147258369-CAPA-INDOUG_1.png',
     '9788565484336', 492, '19,5 x 30,5 cm, colorido, capa dura',
     'justica-edicao-definitiva-panini-unica',
     'https://www.comix.com.br/justica-edic-o-definitiva-30576.html'),
    ('reino-do-amanha-edicao-definitiva-panini',
     'Reino do Amanhã - Edição Definitiva',
     'Reúne Kingdom Come #1-4 e material adicional, por Mark Waid e Alex Ross.',
     DATE '2013-10-01',
     'https://rika.vtexassets.com/arquivos/ids/271133/reino-do-amanha-ed-definitiva.jpg?v=635658307802270000',
     '9788565484640', 336, '19,5 x 30 cm, papel couché, colorido, capa dura',
     'reino-do-amanha-edicao-definitiva-panini-unica',
     'https://www.rika.com.br/reino-do-amanha---edicao-definitiva15003992/p')
), series_alvo AS (
    SELECT serie.id, serie.id_externo, serie.titulo
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Justiça - Edição Definitiva'),
          hqhub_normalizar_titulo_serie('Reino do Amanhã - Edição Definitiva')
      )
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA', obra.titulo, obra.descricao, 'Edição Definitiva',
    obra.data_publicacao, obra.url_capa, obra.codigo_barras,
    obra.quantidade_paginas, obra.formato, 'LOJISTAS_BRASILEIROS',
    obra.id_edicao, obra.url_origem, serie.id,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM obras obra
JOIN series_alvo serie
  ON (
      obra.serie_id_externo = 'justica-edicao-definitiva-panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Justiça - Edição Definitiva')
  )
  OR (
      obra.serie_id_externo = 'reino-do-amanha-edicao-definitiva-panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Reino do Amanhã - Edição Definitiva')
  )
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
