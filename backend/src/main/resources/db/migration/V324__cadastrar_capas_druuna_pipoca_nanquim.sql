-- Cadastra as três edições de Druuna da Pipoca & Nanquim na série Panini já existente.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Druuna')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
), volumes(numero, titulo, nome_volume, url_capa, quantidade_paginas, id_externo, url_origem) AS (VALUES
    ('1', 'Druuna Vol. 1', 'Morbus Gravis, Delta, Criatura, Carnívora',
     'https://img.olx.com.br/images/86/866609723008543.jpg', 308,
     'druuna-pipoca-nanquim-1', 'https://pipocaenanquim.com.br/colecao-druuna-03-volumes.html'),
    ('2', 'Druuna Vol. 2', NULL,
     'https://pipocaenanquim.com.br/media/catalog/product/cache/02cddd4670051054d5ac13d7e3aa93e7/7/0/700x1000-druuna-vol02-capa.png', 308,
     'druuna-pipoca-nanquim-2', 'https://pipocaenanquim.com.br/druuna-vol-2-reimpressao.html'),
    ('3', 'Druuna Vol. 3', NULL,
     'https://pipocaenanquim.com.br/media/catalog/product/cache/a71aea54aaaa85b910cda2569c1085f4/7/0/700x1000-druuna-03-mockup.png', 196,
     'druuna-pipoca-nanquim-3', 'https://pipocaenanquim.com.br/druuna-vol-3-reimpressao.html')
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, quantidade_paginas, formato,
    fonte_externa, id_externo, url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT volume.numero, volume.titulo, volume.nome_volume, volume.url_capa,
       volume.quantidade_paginas, 'capa dura, colorido', 'PIPOCA_E_NANQUIM',
       volume.id_externo, volume.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
