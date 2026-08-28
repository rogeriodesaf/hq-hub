-- Cadastra as duas edições da minissérie Hellboy: Sementes da Destruição (Mythos).

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Hellboy: Sementes da Destruição')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'mythos%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
), volumes(numero, titulo, nome_volume, url_capa, quantidade_paginas,
           codigo_barras, id_externo, url_origem) AS (VALUES
    ('1', 'Hellboy: Sementes da Destruição', 'Parte 1 de 2',
     'https://rika.vtexassets.com/arquivos/ids/240179-800-auto?aspect=true&height=auto&v=635316704552800000&width=800',
     52, NULL, 'hellboy-sementes-destruicao-mythos-1',
     'https://www.rika.com.br/hellboy---sementes-da-destruicao--116001104/p'),
    ('2', 'Hellboy: Sementes da Destruição', 'O Covil do Demônio — Parte 2 de 2',
     'https://rika.vtexassets.com/arquivos/ids/240180-800-auto?aspect=true&height=auto&v=635316704563970000&width=800',
     52, NULL, 'hellboy-sementes-destruicao-mythos-2',
     'https://www.rika.com.br/hellboy---sementes-da-destruicao--216001105/p')
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, quantidade_paginas, codigo_barras,
    formato, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT volume.numero, volume.titulo, volume.nome_volume, volume.url_capa,
       volume.quantidade_paginas, volume.codigo_barras,
       '17 x 26 cm, colorido, capa cartão', 'LOJISTAS_BRASILEIROS',
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
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
