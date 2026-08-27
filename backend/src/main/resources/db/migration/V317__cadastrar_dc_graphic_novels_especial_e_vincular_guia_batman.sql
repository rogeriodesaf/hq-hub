-- Cadastra os seis volumes de DC Comics - Coleção de Graphic Novels Especial
-- (Eaglemoss) e vincula Batman: Cataclismo (#1) à posição 65 do guia do Batman.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Eaglemoss', 'Editora de coleções e graphic novels em capa dura.', 'Reino Unido', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'DC Comics - Coleção de Graphic Novels Especial',
    'Coleção especial da Eaglemoss em seis volumes, reunindo Batman: Cataclismo e Batman: Terra de Ninguém.',
    1,
    'EXCELSIOR',
    'dc-comics-graphic-novels-especial-eaglemoss-volume-1',
    'https://excelsiorcomics.com.br/serie/dc-comics-colecao-de-graphic-novels-especial-eaglemoss/',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      WHERE existente.editora_id = editora.id
        AND coalesce(existente.volume, 0) = 1
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('DC Comics - Coleção de Graphic Novels Especial')
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, titulo, nome_volume, paginas, url_capa, url_origem) AS (VALUES
    ('1', 'Batman: Cataclismo', 'Batman: Cataclismo', 320,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2018/07/dc-colecao-graphic-novels-especial-01-batman-cataclismo.jpg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-1-batman-cataclismo/'),
    ('2', 'Batman: Terra de Ninguém - Parte 1', 'Batman: Terra de Ninguém - Parte 1', 432,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/10/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-2.jpeg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-2-batman-terra-de-ninguem-parte-1/'),
    ('3', 'Batman: Terra de Ninguém - Parte 2', 'Batman: Terra de Ninguém - Parte 2', 352,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/10/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-3.jpeg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-3-batman-terra-de-ninguem-parte-2/'),
    ('4', 'Batman: Terra de Ninguém - Parte 3', 'Batman: Terra de Ninguém - Parte 3', NULL,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/10/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-4.jpeg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-4-batman-terra-de-ninguem-parte-3/'),
    ('5', 'Batman: Terra de Ninguém - Parte 4', 'Batman: Terra de Ninguém - Parte 4', NULL,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/10/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-5.jpeg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-5-batman-terra-de-ninguem-parte-4/'),
    ('6', 'Batman: Terra de Ninguém - Parte 5', 'Batman: Terra de Ninguém - Parte 5', NULL,
     'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/10/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-6.jpeg',
     'https://excelsiorcomics.com.br/produto/dc-comics-colecao-de-graphic-novels-especial-eaglemoss-6-batman-terra-de-ninguem-parte-5/')
), serie_especial AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('DC Comics - Coleção de Graphic Novels Especial')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, quantidade_paginas, formato,
    url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    capa.titulo,
    'Volume ' || capa.numero || ' de DC Comics - Coleção de Graphic Novels Especial, publicado pela Eaglemoss.',
    capa.nome_volume,
    DATE '2016-01-01',
    capa.paginas,
    '17 x 26 cm, capa dura',
    capa.url_capa,
    'EXCELSIOR',
    'dc-graphic-novels-especial-eaglemoss-' || capa.numero,
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_especial serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    quantidade_paginas = coalesce(EXCLUDED.quantidade_paginas, edicoes.quantidade_paginas),
    formato = EXCLUDED.formato,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    WHERE serie.id_externo = 'dc-comics-graphic-novels-especial-eaglemoss-volume-1'
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a DC Comics - Coleção de Graphic Novels Especial #1: Batman: Cataclismo.'
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 65;
