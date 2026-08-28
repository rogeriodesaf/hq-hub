-- Cadastra as sete edições de John Constantine, Hellblazer - Condenado.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('John Constantine, Hellblazer - Condenado')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
), volumes(numero, titulo, nome_volume, data_publicacao, url_capa,
           quantidade_paginas, codigo_barras, id_externo, url_origem) AS (VALUES
    ('1', 'John Constantine, Hellblazer - Condenado Vol. 1', 'Sepulcro Vermelho', DATE '2020-01-01',
     'https://rika.vtexassets.com/arquivos/ids/406667/John-Constantine-Hellblazer-Condenado-Volume-1.jpg', 176, NULL,
     'hellblazer-condenado-panini-1', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-1---sepulcro-vermelho-15007937/p'),
    ('2', 'John Constantine, Hellblazer - Condenado Vol. 2', 'O Curinga', DATE '2020-04-01',
     'https://rika.vtexassets.com/arquivos/ids/406668/John-Constantine-Hellblazer-Condenado-Volume-2.jpg', 176, '9788542629811',
     'hellblazer-condenado-panini-2', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-2---o-curinga-15007938/p'),
    ('3', 'John Constantine, Hellblazer - Condenado Vol. 3', 'Olhando Para a Parede', DATE '2020-06-01',
     'https://rika.vtexassets.com/arquivos/ids/406669/John-Constantine-Hellblazer-Condenado-Volume-3.jpg', 144, NULL,
     'hellblazer-condenado-panini-3', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-3---olhando-para-a-parede-15007939/p'),
    ('4', 'John Constantine, Hellblazer - Condenado Vol. 4', 'Via Crúcis', DATE '2020-08-01',
     'https://rika.vtexassets.com/arquivos/ids/406670/John-Constantine-Hellblazer-Condenado-Volume-4.jpg', 136, NULL,
     'hellblazer-condenado-panini-4', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-4---via-crucis-15007940/p'),
    ('5', 'John Constantine, Hellblazer - Condenado Vol. 5', 'Razões Para Se Alegrar', DATE '2020-10-01',
     'https://rika.vtexassets.com/arquivos/ids/406671/John-Constantine-Hellblazer-Condenado-Volume-5.jpg', 148, NULL,
     'hellblazer-condenado-panini-5', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-5---razoes-para-se-alegrar-15007941/p'),
    ('6', 'John Constantine, Hellblazer - Condenado Vol. 6', 'O Dom', DATE '2020-12-01',
     'https://rika.vtexassets.com/arquivos/ids/406672/John-Constantine-Hellblazer-Condenado-Volume-6.jpg', 168, '9786555125906',
     'hellblazer-condenado-panini-6', 'https://www.amazon.com.br/John-Constantine-Hellblazer-Condenado-6/dp/655512590X'),
    ('7', 'John Constantine, Hellblazer - Condenado Vol. 7', 'O Convite', DATE '2021-02-01',
     'https://rika.vtexassets.com/arquivos/ids/406673/John-Constantine-Hellblazer-Condenado-Volume-7.jpg', 192, '9786555127928',
     'hellblazer-condenado-panini-7', 'https://www.rika.com.br/john-constantine---hellblazer---condenado---volume-7---o-convite-15007943/p')
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, data_publicacao, url_capa, quantidade_paginas,
    codigo_barras, formato, fonte_externa, id_externo, url_origem,
    serie_id, data_criacao, data_atualizacao
)
SELECT volume.numero, volume.titulo, volume.nome_volume, volume.data_publicacao,
       volume.url_capa, volume.quantidade_paginas, volume.codigo_barras,
       '17 x 26 cm, colorido, capa cartão', 'LOJISTAS_BRASILEIROS',
       volume.id_externo, volume.url_origem, serie.id,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    codigo_barras = COALESCE(EXCLUDED.codigo_barras, edicoes.codigo_barras),
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
