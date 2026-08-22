-- Cadastra Tex Edicao Historica publicada pela Globo, dos numeros 1 a 33.
-- Fonte das capas: catalogo publico da Rika. Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Globo',
    'Editora brasileira que publicou Tex antes da Mythos.',
    'Brasil',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (nome) DO UPDATE SET
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Tex Edição Histórica',
    'Tex Edição Histórica publicada pela Globo, dos números 1 a 33.',
    1,
    'RIKA',
    'tex-edicao-historica-globo-volume-1',
    'https://www.rika.com.br/tex---edicao-historica--0112000797/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Globo')
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/157826/-bonelli-tex-edicao-hist-01.jpg?v=635312936111530000'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/157827/-bonelli-tex-edicao-hist-02.jpg?v=635312936128270000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/157830/-bonelli-tex-edicao-hist-03.jpg?v=635312936176230000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/157831/-bonelli-tex-edicao-hist-04.jpg?v=635312936191100000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/157832/-bonelli-tex-edicao-hist-05.jpg?v=635312936206070000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/157838/-bonelli-tex-edicao-hist-06.jpg?v=635312936298170000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/157839/-bonelli-tex-edicao-hist-07.jpg?v=635312936313170000'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/157824/-bonelli-tex-edicao-hist-08.jpg?v=635312936074370000'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/157828/-bonelli-tex-edicao-hist-09.jpg?v=635312936145170000'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/157840/-bonelli-tex-edicao-hist-10.jpg?v=635312936328600000'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/157841/-bonelli-tex-edicao-hist-11.jpg?v=635312936342070000'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/157842/-bonelli-tex-edicao-hist-12.jpg?v=635312936355930000'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/157843/-bonelli-tex-edicao-hist-13.jpg?v=635312936370070000'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/157844/-bonelli-tex-edicao-hist-14.jpg?v=635312936387000000'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/157845/-bonelli-tex-edicao-hist-15.jpg?v=635312936402130000'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/157854/-bonelli-tex-edicao-hist-16.jpg?v=635312936535700000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/157855/-bonelli-tex-edicao-hist-17.jpg?v=635312936549100000'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/157856/-bonelli-tex-edicao-hist-18.jpg?v=635312936560900000'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/157857/-bonelli-tex-edicao-hist-19.jpg?v=635312936573630000'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/157858/-bonelli-tex-edicao-hist-20.jpg?v=635312936587600000'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/157859/-bonelli-tex-edicao-hist-21.jpg?v=635312936601000000'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/157860/-bonelli-tex-edicao-hist-22.jpg?v=635312936616200000'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/157861/-bonelli-tex-edicao-hist-23.jpg?v=635312936629000000'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/157862/-bonelli-tex-edicao-hist-24.jpg?v=635312936644570000'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/157863/-bonelli-tex-edicao-hist-25.jpg?v=635312936657130000'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/157825/-bonelli-tex-edicao-hist-26.jpg?v=635312936096470000'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/157829/-bonelli-tex-edicao-hist-27.jpg?v=635312936161430000'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/157846/-bonelli-tex-edicao-hist-28.jpg?v=635312936419400000'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/157847/-bonelli-tex-edicao-hist-29.jpg?v=635312936434370000'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/157864/-bonelli-tex-edicao-hist-30.jpg?v=635312936671900000'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/157865/-bonelli-tex-edicao-hist-31.jpg?v=635312936689130000'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/157833/-bonelli-tex-edicao-hist-32.jpg?v=635312936222230000'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/157834/-bonelli-tex-edicao-hist-33.jpg?v=635312936236000000')
), serie_tex_historica AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Edição Histórica')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Globo')
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, url_capa, fonte_externa, id_externo,
    serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Tex Edição Histórica #' || capa.numero,
    'Tex Edição Histórica - número ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-edicao-historica-globo-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_historica serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
