-- Cadastra a primeira serie brasileira de Conan, O Barbaro publicada pela Panini
-- entre 2019 e 2022 e associa as capas dos 13 volumes.
-- O Guia dos Quadrinhos nao foi usado como fonte das imagens.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan, O Barbaro',
    'Primeira serie de Conan, O Barbaro publicada pela Panini no Brasil, com 13 volumes lancados entre 2019 e 2022.',
    1,
    'PANINI',
    'conan-o-barbaro-panini-2019',
    'https://panini.com.br/conan-o-barbaro-vol-1',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
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

WITH capas(numero, url_capa) AS (VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1ttmjqp23t1pdftff0jr9b416i/-S1200-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_4sc747uuep1p34964b1ovj6g2h/-S1200-FWEBP'),
    ('3', 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1578796551l/50400536._SL1600_.jpg'),
    ('4', 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1581213173l/51086952._SL1600_.jpg'),
    ('5', 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1584493001l/52462462._SL1600_.jpg'),
    ('6', 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1588626978l/53331463._SL1600_.jpg'),
    ('7', 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1588627223l/53331470._SL1600_.jpg'),
    ('8', 'https://static.estantevirtual.com.br/book/00/0GU-4812-000/0GU-4812-000_detail1.jpg?ts=1712772740799'),
    ('9', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qcoechk0p93a359mpt2luvis6o/-S1200-FWEBP'),
    ('10', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_k6nneudllp7kf1jf5mndueh506/-S1200-FWEBP'),
    ('11', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1418636/969403.jpg?v=637992830155800000'),
    ('12', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9u8jg450l15j1bqkpk3emk1h50/-S1200-FWEBP'),
    ('13', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_opsn5s658l5btd4fjpp0fgit44/-S1200-FWEBP')
), serie_conan AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'conan-o-barbaro-panini-2019'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Conan, O Barbaro Vol. ' || capa.numero,
    'Volume ' || capa.numero || ' da primeira serie de Conan, O Barbaro publicada pela Panini.',
    'Volume ' || capa.numero,
    capa.url_capa,
    'PANINI',
    'conan-o-barbaro-panini-2019-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_conan serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
