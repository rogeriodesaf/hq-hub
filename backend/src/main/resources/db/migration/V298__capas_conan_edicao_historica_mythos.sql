-- Corrige o cadastro e adiciona as tres capas de Conan - Edicao Historica (Mythos).
-- As imagens vieram de Submundo HQ, Comix e Rika; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos e livros.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan - Edição Histórica',
    'Colecao de luxo em tres volumes publicada pela Mythos, reunindo aventuras classicas de Conan como rei da Aquilonia.',
    2011, 2018, 1, 'COMIX', 'conan-edicao-historica-mythos',
    'https://www.comix.com.br/conan-edic-o-historica-vol-1-conan-o-libertador.html',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) = hqhub_normalizar_titulo_serie('Mythos')
        AND hqhub_normalizar_titulo_serie(existente.titulo) IN (
            hqhub_normalizar_titulo_serie('Conan - Edição Histórica'),
            hqhub_normalizar_titulo_serie('onan - Edição Histórica')
        )
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Conan - Edição Histórica'),
          hqhub_normalizar_titulo_serie('onan - Edição Histórica')
      )
    ORDER BY
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE series serie
SET titulo = 'Conan - Edição Histórica',
    descricao = 'Colecao de luxo em tres volumes publicada pela Mythos, reunindo aventuras classicas de Conan como rei da Aquilonia.',
    ano_inicio = 2011,
    ano_fim = 2018,
    fonte_externa = 'COMIX',
    id_externo = 'conan-edicao-historica-mythos',
    url_origem = 'https://www.comix.com.br/conan-edic-o-historica-vol-1-conan-o-libertador.html',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH volumes(numero, subtitulo, data_publicacao, isbn, paginas, fonte, url_origem, url_capa) AS (VALUES
    ('1', 'O Libertador', DATE '2011-12-01', '9788578670856', 500, 'SUBMUNDO_HQ',
     'https://blogdoxandro.blogspot.com/2017/02/submundo-hq-n144.html',
     'https://3.bp.blogspot.com/-yf7H5ywB3WY/WKi9XddiwuI/AAAAAAACh1c/3dKTRlvjyDInHYjO6NoRl8FSW8pxqu5gACLcB/s1600/Conan%2B1a.jpg'),
    ('2', 'O Conquistador', DATE '2017-11-01', NULL, 440, 'COMIX',
     'https://www.comix.com.br/conan-edic-o-historica-vol-2-conan-o-conquistador.html',
     'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/c/o/conan_edicaohistorica_vol2_conan_oconquistador_coverbg.jpg'),
    ('3', 'Conan da Aquilônia', DATE '2018-09-01', '9788578673529', 368, 'RIKA',
     'https://www.rika.com.br/conan---edicao-historica---volume-3---conan-da-aquilonia-16006680/p',
     'https://rika.vtexassets.com/arquivos/ids/327866-800-auto?aspect=true&height=auto&v=636987170833200000&width=800')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Conan - Edição Histórica')
    ORDER BY CASE WHEN serie.id_externo = 'conan-edicao-historica-mythos' THEN 0 ELSE 1 END, serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    volume.numero,
    'Conan - Edição Histórica Vol. ' || volume.numero || ': ' || volume.subtitulo,
    'Volume ' || volume.numero || ' da colecao Conan - Edicao Historica da Mythos.',
    volume.subtitulo,
    volume.data_publicacao,
    volume.url_capa,
    volume.isbn,
    volume.paginas,
    'Capa dura, 24 x 31 cm, preto e branco e colorido',
    volume.fonte,
    'conan-edicao-historica-mythos-' || volume.numero,
    volume.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
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
