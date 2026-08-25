-- Cadastra O Espetacular Homem-Aranha, 2a serie (Panini, 2015-2016), com 13 capas.
-- Capas brasileiras obtidas no Skoob; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'O Espetacular Homem-Aranha, 2ª Série',
    'Serie mensal da Panini publicada entre julho de 2015 e julho de 2016, em duas versoes de acabamento.',
    2015, 2016, 2, 'SKOOB', '519700',
    'https://www.skoob.com.br/pt/book/563775',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 2ª Série')
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 2ª Série')
    ORDER BY serie.id
    LIMIT 1
), capas(numero, data_publicacao, url_capa) AS (
    VALUES
        ('1',  DATE '2015-07-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEM_ARANHA_A1_1438601400519700SK1438601400B.jpg'),
        ('2',  DATE '2015-08-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A2_1446991614519700SK1446991614B.jpg'),
        ('3',  DATE '2015-09-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A3_1446991912519700SK1446991912B.jpg'),
        ('4',  DATE '2015-10-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A4_1446992255519700SK1446992255B.jpg'),
        ('5',  DATE '2015-11-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A5_1450550175519700SK1450550175B.jpg'),
        ('6',  DATE '2015-12-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A6_1455107061519700SK1455107061B.jpg'),
        ('7',  DATE '2016-01-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A7_1454980936519700SK1454980936B.jpg'),
        ('8',  DATE '2016-02-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A8_1463232544519700SK1463232544B.jpg'),
        ('9',  DATE '2016-03-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A9_1459617928519700SK1459617928B.jpg'),
        ('10', DATE '2016-04-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A10_1462145662519700SK1462145662B.jpg'),
        ('11', DATE '2016-05-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A11_1464465146519700SK1464465146B.jpg'),
        ('12', DATE '2016-06-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_A12_1466876903519700SK1466876903B.jpg'),
        ('13', DATE '2016-07-01', 'https://skoob.s3.amazonaws.com/livros/519700/O_ESPETACULAR_HOMEMARANHA_1471147724519700SK1471147724B.jpg')
)
INSERT INTO edicoes (
    numero, titulo, descricao, data_publicacao, url_capa, quantidade_paginas,
    formato, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'O Espetacular Homem-Aranha #' || capa.numero,
    'Edicao brasileira da segunda serie de O Espetacular Homem-Aranha publicada pela Panini.',
    capa.data_publicacao,
    capa.url_capa,
    68,
    '17 x 26 cm, colorido, lombada canoa',
    'SKOOB',
    'SKOOB-519700-' || lpad(capa.numero, 2, '0'),
    'https://www.skoob.com.br/pt/book/563775',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
