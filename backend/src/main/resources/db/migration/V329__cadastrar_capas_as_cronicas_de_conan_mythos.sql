-- Cadastra os quatro volumes de As Crônicas de Conan (Mythos).

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('As Crônicas de Conan')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'mythos%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
), volumes(numero, titulo, nome_volume, url_capa, quantidade_paginas,
           codigo_barras, id_externo, url_origem) AS (VALUES
    ('1', 'As Crônicas de Conan - Volume 1', 'A Torre do Elefante e outras histórias',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/a/s/ascronicas1.jpg',
     180, NULL, 'as-cronicas-de-conan-mythos-1',
     'https://www.guiadosquadrinhos.com/edicao/cronicas-de-conan-as-n-1/cr062101/124090'),
    ('2', 'As Crônicas de Conan - Volume 2', 'Inimigos em Casa e outras histórias',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/a/s/ascronicas2.jpg',
     152, NULL, 'as-cronicas-de-conan-mythos-2',
     'https://www.comix.com.br/quadrinhos/dark-horse/conan/colecao-as-cronicas-de-conan-com-4-volumes.html'),
    ('3', 'As Crônicas de Conan - Volume 3', 'A Imperatriz Verde de Melniboné e outras histórias',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/a/s/ascronicas3.jpg',
     NULL, NULL, 'as-cronicas-de-conan-mythos-3',
     'https://www.comix.com.br/quadrinhos/dark-horse/conan/colecao-as-cronicas-de-conan-com-4-volumes.html'),
    ('4', 'As Crônicas de Conan - Volume 4', 'Pregos Vermelhos e outras histórias',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/a/s/ascronicas4.jpg',
     172, '9788578673970', 'as-cronicas-de-conan-mythos-4',
     'https://www.guiadosquadrinhos.com/edicao/cronicas-de-conan-as-n-4/cr062101/144412')
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, quantidade_paginas, codigo_barras,
    formato, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT volume.numero, volume.titulo, volume.nome_volume, volume.url_capa,
       volume.quantidade_paginas, volume.codigo_barras,
       '18,5 x 27 cm, colorido, capa dura', 'LOJISTAS_BRASILEIROS',
       volume.id_externo, volume.url_origem, serie.id,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    codigo_barras = COALESCE(EXCLUDED.codigo_barras, edicoes.codigo_barras),
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
