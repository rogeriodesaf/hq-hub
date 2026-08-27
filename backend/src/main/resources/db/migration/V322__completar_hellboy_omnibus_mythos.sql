-- Completa Hellboy Omnibus (Mythos, V1) com os volumes 2 e 3 e suas capas.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Hellboy Omnibus')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'mythos%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY (
        SELECT count(*)
        FROM edicoes edicao
        WHERE edicao.serie_id = serie.id
    ) DESC, serie.id
    LIMIT 1
), volumes(
    numero, titulo, descricao, nome_volume, url_capa, codigo_barras,
    quantidade_paginas, formato, fonte_externa, id_externo, url_origem
) AS (VALUES
    ('2',
     'Hellboy Omnibus Vol. 2: Paragens Exóticas',
     'Segundo volume da edição histórica de Hellboy publicada pela Mythos.',
     'Paragens Exóticas',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/0/1000x1000-comix_capa-hellboy-omnibus-2-paragens-exoticas.jpg',
     '9788578674595', 416, '17 x 26 cm, colorido, brochura',
     'MYTHOS', 'hellboy-omnibus-mythos-2',
     'https://www.lojamythos.com.br/hq-s/hellboy-omnibus-vol-2'),
    ('3',
     'Hellboy Omnibus Vol. 3: Caçada Selvagem',
     'Terceiro volume da edição histórica de Hellboy publicada pela Mythos.',
     'Caçada Selvagem',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/0/1000x1000-comix_capa-hellboy-omnibus-edicao-historica-vol-3.jpg',
     NULL, 532, '17 x 26 cm, colorido, brochura',
     'COMIX', 'hellboy-omnibus-mythos-3',
     'https://www.comix.com.br/hellboy-omnibus-edic-o-historica-vol-3.html')
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa, codigo_barras,
    quantidade_paginas, formato, fonte_externa, id_externo, url_origem,
    serie_id, data_criacao, data_atualizacao
)
SELECT
    volume.numero, volume.titulo, volume.descricao, volume.nome_volume,
    volume.url_capa, volume.codigo_barras, volume.quantidade_paginas,
    volume.formato, volume.fonte_externa, volume.id_externo,
    volume.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
