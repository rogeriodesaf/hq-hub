-- Cadastra a serie Conan, O Barbaro publicada pela Mythos entre 2002 e 2010.
-- As 76 capas foram validadas na loja Rika; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan, O Barbaro',
    'Serie em 76 edicoes publicada pela Mythos no Brasil entre 2002 e 2010.',
    1,
    'RIKA',
    'conan-o-barbaro-mythos-2002',
    'https://www.rika.com.br/',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
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
    ('1', 'https://rika.vtexassets.com/arquivos/ids/266105/conan-barbaro-mythos-1.jpg'),
    ('2', 'https://rika.vtexassets.com/arquivos/ids/266106/conan-barbaro-mythos-2.jpg'),
    ('3', 'https://rika.vtexassets.com/arquivos/ids/266107/conan-barbaro-mythos-3.jpg'),
    ('4', 'https://rika.vtexassets.com/arquivos/ids/266108/conan-barbaro-mythos-4.jpg'),
    ('5', 'https://rika.vtexassets.com/arquivos/ids/266109/conan-barbaro-mythos-5.jpg'),
    ('6', 'https://rika.vtexassets.com/arquivos/ids/266110/conan-barbaro-mythos-6.jpg'),
    ('7', 'https://rika.vtexassets.com/arquivos/ids/266111/conan-barbaro-mythos-7.jpg'),
    ('8', 'https://rika.vtexassets.com/arquivos/ids/266112/conan-barbaro-mythos-8.jpg'),
    ('9', 'https://rika.vtexassets.com/arquivos/ids/266113/conan-barbaro-mythos-9.jpg'),
    ('10', 'https://rika.vtexassets.com/arquivos/ids/266114/conan-barbaro-mythos-10.jpg'),
    ('11', 'https://rika.vtexassets.com/arquivos/ids/266115/conan-barbaro-mythos-11.jpg'),
    ('12', 'https://rika.vtexassets.com/arquivos/ids/266116/conan-barbaro-mythos-12.jpg'),
    ('13', 'https://rika.vtexassets.com/arquivos/ids/266117/conan-barbaro-mythos-13.jpg'),
    ('14', 'https://rika.vtexassets.com/arquivos/ids/266118/conan-barbaro-mythos-14.jpg'),
    ('15', 'https://rika.vtexassets.com/arquivos/ids/266119/conan-barbaro-mythos-15.jpg'),
    ('16', 'https://rika.vtexassets.com/arquivos/ids/266120/conan-barbaro-mythos-16.jpg'),
    ('17', 'https://rika.vtexassets.com/arquivos/ids/266121/conan-barbaro-mythos-17.jpg'),
    ('18', 'https://rika.vtexassets.com/arquivos/ids/266122/conan-barbaro-mythos-18.jpg'),
    ('19', 'https://rika.vtexassets.com/arquivos/ids/266123/conan-barbaro-mythos-19.jpg'),
    ('20', 'https://rika.vtexassets.com/arquivos/ids/266124/conan-barbaro-mythos-20.jpg'),
    ('21', 'https://rika.vtexassets.com/arquivos/ids/266125/conan-barbaro-mythos-21.jpg'),
    ('22', 'https://rika.vtexassets.com/arquivos/ids/266126/conan-barbaro-mythos-22.jpg'),
    ('23', 'https://rika.vtexassets.com/arquivos/ids/266127/conan-barbaro-mythos-23.jpg'),
    ('24', 'https://rika.vtexassets.com/arquivos/ids/266128/conan-barbaro-mythos-24.jpg'),
    ('25', 'https://rika.vtexassets.com/arquivos/ids/266129/conan-barbaro-mythos-25.jpg'),
    ('26', 'https://rika.vtexassets.com/arquivos/ids/266130/conan-barbaro-mythos-26.jpg'),
    ('27', 'https://rika.vtexassets.com/arquivos/ids/266131/conan-barbaro-mythos-27.jpg'),
    ('28', 'https://rika.vtexassets.com/arquivos/ids/266132/conan-barbaro-mythos-28.jpg'),
    ('29', 'https://rika.vtexassets.com/arquivos/ids/266133/conan-barbaro-mythos-29.jpg'),
    ('30', 'https://rika.vtexassets.com/arquivos/ids/266134/conan-barbaro-mythos-30.jpg'),
    ('31', 'https://rika.vtexassets.com/arquivos/ids/266135/conan-barbaro-mythos-31.jpg'),
    ('32', 'https://rika.vtexassets.com/arquivos/ids/266136/conan-barbaro-mythos-32.jpg'),
    ('33', 'https://rika.vtexassets.com/arquivos/ids/266137/conan-barbaro-mythos-33.jpg'),
    ('34', 'https://rika.vtexassets.com/arquivos/ids/266138/conan-barbaro-mythos-34.jpg'),
    ('35', 'https://rika.vtexassets.com/arquivos/ids/266139/conan-barbaro-mythos-35.jpg'),
    ('36', 'https://rika.vtexassets.com/arquivos/ids/266140/conan-barbaro-mythos-36.jpg'),
    ('37', 'https://rika.vtexassets.com/arquivos/ids/266141/conan-barbaro-mythos-37.jpg'),
    ('38', 'https://rika.vtexassets.com/arquivos/ids/266142/conan-barbaro-mythos-38.jpg'),
    ('39', 'https://rika.vtexassets.com/arquivos/ids/266143/conan-barbaro-mythos-39.jpg'),
    ('40', 'https://rika.vtexassets.com/arquivos/ids/266144/conan-barbaro-mythos-40.jpg'),
    ('41', 'https://rika.vtexassets.com/arquivos/ids/266145/conan-barbaro-mythos-41.jpg'),
    ('42', 'https://rika.vtexassets.com/arquivos/ids/266146/conan-barbaro-mythos-42.jpg'),
    ('43', 'https://rika.vtexassets.com/arquivos/ids/266147/conan-barbaro-mythos-43.jpg'),
    ('44', 'https://rika.vtexassets.com/arquivos/ids/266148/conan-barbaro-mythos-44.jpg'),
    ('45', 'https://rika.vtexassets.com/arquivos/ids/266149/conan-barbaro-mythos-45.jpg'),
    ('46', 'https://rika.vtexassets.com/arquivos/ids/266150/conan-barbaro-mythos-46.jpg'),
    ('47', 'https://rika.vtexassets.com/arquivos/ids/266151/conan-barbaro-mythos-47.jpg'),
    ('48', 'https://rika.vtexassets.com/arquivos/ids/266152/conan-barbaro-mythos-48.jpg'),
    ('49', 'https://rika.vtexassets.com/arquivos/ids/266153/conan-barbaro-mythos-49.jpg'),
    ('50', 'https://rika.vtexassets.com/arquivos/ids/266154/conan-barbaro-mythos-50.jpg'),
    ('51', 'https://rika.vtexassets.com/arquivos/ids/266155/conan-barbaro-mythos-51.jpg'),
    ('52', 'https://rika.vtexassets.com/arquivos/ids/266156/conan-barbaro-mythos-52.jpg'),
    ('53', 'https://rika.vtexassets.com/arquivos/ids/266157/conan-barbaro-mythos-53.jpg'),
    ('54', 'https://rika.vtexassets.com/arquivos/ids/266158/conan-barbaro-mythos-54.jpg'),
    ('55', 'https://rika.vtexassets.com/arquivos/ids/266159/conan-barbaro-mythos-55.jpg'),
    ('56', 'https://rika.vtexassets.com/arquivos/ids/266160/conan-barbaro-mythos-56.jpg'),
    ('57', 'https://rika.vtexassets.com/arquivos/ids/266161/conan-barbaro-mythos-57.jpg'),
    ('58', 'https://rika.vtexassets.com/arquivos/ids/266162/conan-barbaro-mythos-58.jpg'),
    ('59', 'https://rika.vtexassets.com/arquivos/ids/266163/conan-barbaro-mythos-59.jpg'),
    ('60', 'https://rika.vtexassets.com/arquivos/ids/266164/conan-barbaro-mythos-60.jpg'),
    ('61', 'https://rika.vtexassets.com/arquivos/ids/266165/conan-barbaro-mythos-61.jpg'),
    ('62', 'https://rika.vtexassets.com/arquivos/ids/266166/conan-barbaro-mythos-62.jpg'),
    ('63', 'https://rika.vtexassets.com/arquivos/ids/266167/conan-barbaro-mythos-63.jpg'),
    ('64', 'https://rika.vtexassets.com/arquivos/ids/266168/conan-barbaro-mythos-64.jpg'),
    ('65', 'https://rika.vtexassets.com/arquivos/ids/266169/conan-barbaro-mythos-65.jpg'),
    ('66', 'https://rika.vtexassets.com/arquivos/ids/266170/conan-barbaro-mythos-66.jpg'),
    ('67', 'https://rika.vtexassets.com/arquivos/ids/266171/conan-barbaro-mythos-67.jpg'),
    ('68', 'https://rika.vtexassets.com/arquivos/ids/266172/conan-barbaro-mythos-68.jpg'),
    ('69', 'https://rika.vtexassets.com/arquivos/ids/266173/conan-barbaro-mythos-69.jpg'),
    ('70', 'https://rika.vtexassets.com/arquivos/ids/266174/conan-barbaro-mythos-70.jpg'),
    ('71', 'https://rika.vtexassets.com/arquivos/ids/266175/conan-barbaro-mythos-71.jpg'),
    ('72', 'https://rika.vtexassets.com/arquivos/ids/266176/conan-barbaro-mythos-72.jpg'),
    ('73', 'https://rika.vtexassets.com/arquivos/ids/266177/conan-barbaro-mythos-73.jpg'),
    ('74', 'https://rika.vtexassets.com/arquivos/ids/266178/conan-barbaro-mythos-74.jpg'),
    ('75', 'https://rika.vtexassets.com/arquivos/ids/266179/conan-barbaro-mythos-75.jpg'),
    ('76', 'https://rika.vtexassets.com/arquivos/ids/266180/conan-barbaro-mythos-76.jpg')
), serie_conan AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'conan-o-barbaro-mythos-2002'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Conan, O Barbaro #' || capa.numero,
    'Edicao ' || capa.numero || ' da serie Conan, O Barbaro publicada pela Mythos.',
    'Edicao ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'conan-o-barbaro-mythos-2002-' || capa.numero,
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

