-- Cadastra os oito volumes de Conan Omnibus publicados pela Mythos entre 2021 e 2024.
-- Capas e metadados obtidos no catalogo oficial da Mythos; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos e livros.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan Omnibus',
    'Colecao em oito volumes da fase Dark Horse de Conan, publicada pela Mythos entre 2021 e 2024.',
    2021, 2024, 1, 'MYTHOS', 'conan-omnibus-mythos-2021',
    'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-omnibus-vol-1-dezembro2025',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) = hqhub_normalizar_titulo_serie('Mythos')
        AND hqhub_normalizar_titulo_serie(existente.titulo) = hqhub_normalizar_titulo_serie('Conan Omnibus')
  )
ORDER BY editora.id
LIMIT 1
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

WITH volumes(numero, subtitulo, data_publicacao, isbn, paginas, url_origem, url_capa) AS (VALUES
    ('1', 'Nasce uma Lenda', DATE '2021-04-01', '9786559510733', 472,
     'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-omnibus-vol-1-dezembro2025',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_conan_omnibus_vol_1_dezembro_2025_1711847_1_4972362174f991f837168df0e31ea0c7.jpg'),
    ('2', 'A Cidade dos Ladroes', DATE '2021-09-01', '9786559511679', 476,
     'https://www.lojamythos.com.br/hq-s/pre-venda-conan-omnibus-vol-2-setembro2024',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_conan_omnibus_vol_2_setembro_2024_1711169_1_8eef366590c4a1dd7e5094adb9c2f5d0.jpg'),
    ('3', 'Deuses e Feiticeiros Ancestrais', DATE '2022-04-01', '9786559512966', 456,
     'https://www.lojamythos.com.br/hq-s/conan-omnibus-vol-3-1710467',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_omnibus_vol_3_1710467_1_6a89fbfa53d84f53fbec7d3a0838f7d2.jpg'),
    ('4', 'Mercenarios e Loucura', DATE '2022-04-01', '9786559512973', 460,
     'https://www.lojamythos.com.br/hq-s/conan-omnibus-vol-4-1710471',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_omnibus_vol_4_1710471_1_bc274c01749d097b5201abbfcc502457.jpg'),
    ('5', 'Pirataria e Paixao', DATE '2022-10-01', '9786559513628', 436,
     'https://www.lojamythos.com.br/hq-s/conan-omnibus-vol-5',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_omnibus_vol_5_1710545_1_09b75ed5fd315ce1aa7e99659d00a009.jpg'),
    ('6', 'Selvageria e Sofrimento', DATE '2023-04-01', '9786559514397', 448,
     'https://www.lojamythos.com.br/hq-s/conan-omnibus-vol-6/',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_omnibus_vol_6_1710645_1_f9082c78caf3764e63f504d774afa1f6.jpg'),
    ('7', 'Bruxarias e Batalhas', DATE '2023-10-01', '9786559515004', 452,
     'https://www.lojamythos.com.br/hq-s/conan-omnibus-vol-7',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_omnibus_vol_7_1710783_1_3e8354614e2e5c263e8d9a222102d36b.jpg'),
    ('8', 'Desforras e Desfechos', DATE '2024-05-10', '9786559515684', 292,
     'https://www.lojamythos.com.br/hq-s/pre-venda-conan-omnibus-vol-8-abril2024',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_conan_omnibus_vol_8_abril_2024_1710699_1_b08da4e0e92f8b1f23fc545a4d0e5671.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Conan Omnibus')
    ORDER BY
        CASE WHEN serie.id_externo = 'conan-omnibus-mythos-2021' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    volume.numero,
    'Conan Omnibus Vol. ' || volume.numero || ': ' || volume.subtitulo,
    'Volume ' || volume.numero || ' da colecao Conan Omnibus da Mythos.',
    volume.subtitulo,
    volume.data_publicacao,
    volume.url_capa,
    volume.isbn,
    volume.paginas,
    'Capa brochura, 17 x 26 cm, colorido',
    'MYTHOS',
    'conan-omnibus-mythos-' || volume.numero,
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
