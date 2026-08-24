-- Cadastra as 82 edicoes de Batman, quarta serie da Panini (2017-2023), com suas capas.
-- A numeracao editorial permaneceu continua ate a edicao 82; a partir da 59,
-- a numeracao exibida na capa reiniciou em 1.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini Comics', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Batman',
    'Quarta serie brasileira de Batman publicada pela Panini, completa em 82 edicoes.',
    4,
    'PANINI',
    'batman-panini-quarta-serie',
    'https://panini.com.br/batman-2017-01',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
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
    ('1', 'https://panini.com.br/media/catalog/product/A/D/ADCIF001.jpg'),
    ('2', 'https://panini.com.br/media/catalog/product/A/D/ADCIF002.jpg'),
    ('3', 'https://panini.com.br/media/catalog/product/A/D/ADCIF003.jpg'),
    ('4', 'https://panini.com.br/media/catalog/product/A/D/ADCIF004.jpg'),
    ('5', 'https://panini.com.br/media/catalog/product/A/D/ADCIF005.jpg'),
    ('6', 'https://panini.com.br/media/catalog/product/A/D/ADCIF006.jpg'),
    ('7', 'https://panini.com.br/media/catalog/product/A/D/ADCIF007.jpg'),
    ('8', 'https://panini.com.br/media/catalog/product/A/D/ADCIF008.jpg'),
    ('9', 'https://panini.com.br/media/catalog/product/A/D/ADCIF009.jpg'),
    ('10', 'https://panini.com.br/media/catalog/product/A/D/ADCIF010.jpg'),
    ('11', 'https://panini.com.br/media/catalog/product/A/D/ADCIF011.jpg'),
    ('12', 'https://panini.com.br/media/catalog/product/A/D/ADCIF012.jpg'),
    ('13', 'https://panini.com.br/media/catalog/product/A/D/ADCIF013.jpg'),
    ('14', 'https://panini.com.br/media/catalog/product/A/D/ADCIF014.jpg'),
    ('15', 'https://panini.com.br/media/catalog/product/A/D/ADCIF015.jpg'),
    ('16', 'https://panini.com.br/media/catalog/product/A/D/ADCIF016.jpg'),
    ('17', 'https://panini.com.br/media/catalog/product/A/D/ADCIF017.jpg'),
    ('18', 'https://panini.com.br/media/catalog/product/A/D/ADCIF018.jpg'),
    ('19', 'https://panini.com.br/media/catalog/product/A/D/ADCIF019.jpg'),
    ('20', 'https://panini.com.br/media/catalog/product/A/D/ADCIF020.jpg'),
    ('21', 'https://panini.com.br/media/catalog/product/A/D/ADCIF021.jpg'),
    ('22', 'https://panini.com.br/media/catalog/product/A/D/ADCIF022.jpg'),
    ('23', 'https://panini.com.br/media/catalog/product/A/D/ADCIF023.jpg'),
    ('24', 'https://panini.com.br/media/catalog/product/A/D/ADCIF024.jpg'),
    ('25', 'https://panini.com.br/media/catalog/product/A/D/ADCIF025.jpg'),
    ('26', 'https://panini.com.br/media/catalog/product/A/D/ADCIF026.jpg'),
    ('27', 'https://panini.com.br/media/catalog/product/A/D/ADCIF027.jpg'),
    ('28', 'https://files1.comics.org//img/gcd/covers_by_id/1348/w400/1348721.jpg'),
    ('29', 'https://panini.com.br/media/catalog/product/A/D/ADCIF029.jpg'),
    ('30', 'https://panini.com.br/media/catalog/product/A/D/ADCIF030.jpg'),
    ('31', 'https://panini.com.br/media/catalog/product/A/D/ADCIF031.jpg'),
    ('32', 'https://panini.com.br/media/catalog/product/A/D/ADCIF032.jpg'),
    ('33', 'https://panini.com.br/media/catalog/product/A/D/ADCIF033.jpg'),
    ('34', 'https://panini.com.br/media/catalog/product/A/D/ADCIF034.jpg'),
    ('35', 'https://panini.com.br/media/catalog/product/A/D/ADCIF035.jpg'),
    ('36', 'https://panini.com.br/media/catalog/product/A/D/ADCIF036.jpg'),
    ('37', 'https://panini.com.br/media/catalog/product/A/D/ADCIF037.jpg'),
    ('38', 'https://panini.com.br/media/catalog/product/A/D/ADCIF038.jpg'),
    ('39', 'https://panini.com.br/media/catalog/product/A/D/ADCIF039.jpg'),
    ('40', 'https://panini.com.br/media/catalog/product/A/D/ADCIF040.jpg'),
    ('41', 'https://panini.com.br/media/catalog/product/A/D/ADCIF041.jpg'),
    ('42', 'https://panini.com.br/media/catalog/product/A/D/ADCIF042.jpg'),
    ('43', 'https://panini.com.br/media/catalog/product/A/D/ADCIF043.jpg'),
    ('44', 'https://panini.com.br/media/catalog/product/A/D/ADCIF044.jpg'),
    ('45', 'https://panini.com.br/media/catalog/product/A/D/ADCIF045.jpg'),
    ('46', 'https://panini.com.br/media/catalog/product/A/D/ADCIF046.jpg'),
    ('47', 'https://panini.com.br/media/catalog/product/A/D/ADCIF047.jpg'),
    ('48', 'https://panini.com.br/media/catalog/product/A/D/ADCIF048.jpg'),
    ('49', 'https://panini.com.br/media/catalog/product/A/D/ADCIF049.jpg'),
    ('50', 'https://panini.com.br/media/catalog/product/A/D/ADCIF050.jpg'),
    ('51', 'https://panini.com.br/media/catalog/product/A/D/ADCIF051.jpg'),
    ('52', 'https://panini.com.br/media/catalog/product/A/D/ADCIF052.jpg'),
    ('53', 'https://panini.com.br/media/catalog/product/A/D/ADCIF053.png'),
    ('54', 'https://panini.com.br/media/catalog/product/A/D/ADCIF054.jpg'),
    ('55', 'https://panini.com.br/media/catalog/product/A/D/ADCIF055.png'),
    ('56', 'https://panini.com.br/media/catalog/product/A/D/ADCIF056.png'),
    ('57', 'https://panini.com.br/media/catalog/product/A/D/ADCIF057.png'),
    ('58', 'https://panini.com.br/media/catalog/product/A/D/ADCIF058.png'),
    ('59', 'https://panini.com.br/media/catalog/product/A/D/ADCIF059.png'),
    ('60', 'https://panini.com.br/media/catalog/product/A/D/ADCIF060.png'),
    ('61', 'https://panini.com.br/media/catalog/product/a/d/adcif061.png'),
    ('62', 'https://panini.com.br/media/catalog/product/a/d/adcif062.png'),
    ('63', 'https://panini.com.br/media/catalog/product/A/D/ADCIF063.png'),
    ('64', 'https://panini.com.br/media/catalog/product/A/D/ADCIF064.png'),
    ('65', 'https://panini.com.br/media/catalog/product/A/D/ADCIF065.png'),
    ('66', 'https://panini.com.br/media/catalog/product/A/D/ADCIF066.png'),
    ('67', 'https://panini.com.br/media/catalog/product/A/D/ADCIF067.jpg'),
    ('68', 'https://panini.com.br/media/catalog/product/A/D/ADCIF068.jpg'),
    ('69', 'https://panini.com.br/media/catalog/product/A/D/ADCIF069.jpg'),
    ('70', 'https://panini.com.br/media/catalog/product/A/D/ADCIF070.jpg'),
    ('71', 'https://panini.com.br/media/catalog/product/A/D/ADCIF071.jpg'),
    ('72', 'https://panini.com.br/media/catalog/product/A/D/ADCIF072.jpg'),
    ('73', 'https://panini.com.br/media/catalog/product/A/D/ADCIF073.jpg'),
    ('74', 'https://panini.com.br/media/catalog/product/A/D/ADCIF074.jpg'),
    ('75', 'https://panini.com.br/media/catalog/product/a/d/adcif075.jpg'),
    ('76', 'https://panini.com.br/media/catalog/product/a/d/adcif076.jpg'),
    ('77', 'https://panini.com.br/media/catalog/product/A/D/ADCIF077.jpg'),
    ('78', 'https://panini.com.br/media/catalog/product/A/D/ADCIF078.jpg'),
    ('79', 'https://panini.com.br/media/catalog/product/A/D/ADCIF079.jpg'),
    ('80', 'https://panini.com.br/media/catalog/product/A/D/ADCIF080.jpg'),
    ('81', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_v43bdg39c90o37r90789ahch13/-S897-FWEBP'),
    ('82', 'https://rihappy.vtexassets.com/arquivos/ids/6480225-800-auto?aspect=true&height=auto&v=638621091108600000&width=800')
), serie_batman AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.volume = 4
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Batman ' || capa.numero,
    'Edicao ' || capa.numero || ' da quarta serie de Batman publicada pela Panini.',
    'Edicao ' || capa.numero,
    capa.url_capa,
    'PANINI',
    'batman-panini-quarta-serie-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_batman serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

