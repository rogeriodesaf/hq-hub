-- Cadastra Conan, O Cimerio, serie publicada pela Mythos entre 2004 e 2008.
-- As 50 capas foram validadas na loja Rika; o Guia dos Quadrinhos nao foi usado.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan, O Cimerio',
    'Serie colorida em 50 edicoes publicada pela Mythos no Brasil entre 2004 e 2008, com material da Dark Horse Comics.',
    1,
    'RIKA',
    'conan-o-cimerio-mythos-2004',
    'https://www.rika.com.br/conan-o-cimerio--5016003408/p',
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
    ('1', 'https://rika.vtexassets.com/arquivos/ids/266182/conan-cimerio-1.jpg'),
    ('2', 'https://rika.vtexassets.com/arquivos/ids/266183/conan-cimerio-2.jpg'),
    ('3', 'https://rika.vtexassets.com/arquivos/ids/266184/conan-cimerio-3.jpg'),
    ('4', 'https://rika.vtexassets.com/arquivos/ids/266185/conan-cimerio-4.jpg'),
    ('5', 'https://rika.vtexassets.com/arquivos/ids/266186/conan-cimerio-5.jpg'),
    ('6', 'https://rika.vtexassets.com/arquivos/ids/266187/conan-cimerio-6.jpg'),
    ('7', 'https://rika.vtexassets.com/arquivos/ids/266188/conan-cimerio-7.jpg'),
    ('8', 'https://rika.vtexassets.com/arquivos/ids/266189/conan-cimerio-8.jpg'),
    ('9', 'https://rika.vtexassets.com/arquivos/ids/266190/conan-cimerio-9.jpg'),
    ('10', 'https://rika.vtexassets.com/arquivos/ids/266191/conan-cimerio-10.jpg'),
    ('11', 'https://rika.vtexassets.com/arquivos/ids/266192/conan-cimerio-11.jpg'),
    ('12', 'https://rika.vtexassets.com/arquivos/ids/266193/conan-cimerio-12.jpg'),
    ('13', 'https://rika.vtexassets.com/arquivos/ids/266194/conan-cimerio-13.jpg'),
    ('14', 'https://rika.vtexassets.com/arquivos/ids/266195/conan-cimerio-14.jpg'),
    ('15', 'https://rika.vtexassets.com/arquivos/ids/266196/conan-cimerio-15.jpg'),
    ('16', 'https://rika.vtexassets.com/arquivos/ids/266197/conan-cimerio-16.jpg'),
    ('17', 'https://rika.vtexassets.com/arquivos/ids/266198/conan-cimerio-17.jpg'),
    ('18', 'https://rika.vtexassets.com/arquivos/ids/266199/conan-cimerio-18.jpg'),
    ('19', 'https://rika.vtexassets.com/arquivos/ids/266200/conan-cimerio-19.jpg'),
    ('20', 'https://rika.vtexassets.com/arquivos/ids/266201/conan-cimerio-20.jpg'),
    ('21', 'https://rika.vtexassets.com/arquivos/ids/266202/conan-cimerio-21.jpg'),
    ('22', 'https://rika.vtexassets.com/arquivos/ids/266203/conan-cimerio-22.jpg'),
    ('23', 'https://rika.vtexassets.com/arquivos/ids/266204/conan-cimerio-23.jpg'),
    ('24', 'https://rika.vtexassets.com/arquivos/ids/266205/conan-cimerio-24.jpg'),
    ('25', 'https://rika.vtexassets.com/arquivos/ids/266206/conan-cimerio-25.jpg'),
    ('26', 'https://rika.vtexassets.com/arquivos/ids/266207/conan-cimerio-26.jpg'),
    ('27', 'https://rika.vtexassets.com/arquivos/ids/266208/conan-cimerio-27.jpg'),
    ('28', 'https://rika.vtexassets.com/arquivos/ids/266209/conan-cimerio-28.jpg'),
    ('29', 'https://rika.vtexassets.com/arquivos/ids/266210/conan-cimerio-29.jpg'),
    ('30', 'https://rika.vtexassets.com/arquivos/ids/266211/conan-cimerio-30.jpg'),
    ('31', 'https://rika.vtexassets.com/arquivos/ids/266212/conan-cimerio-31.jpg'),
    ('32', 'https://rika.vtexassets.com/arquivos/ids/266213/conan-cimerio-32.jpg'),
    ('33', 'https://rika.vtexassets.com/arquivos/ids/266214/conan-cimerio-33.jpg'),
    ('34', 'https://rika.vtexassets.com/arquivos/ids/266215/conan-cimerio-34.jpg'),
    ('35', 'https://rika.vtexassets.com/arquivos/ids/266216/conan-cimerio-35.jpg'),
    ('36', 'https://rika.vtexassets.com/arquivos/ids/266217/conan-cimerio-36.jpg'),
    ('37', 'https://rika.vtexassets.com/arquivos/ids/266218/conan-cimerio-37.jpg'),
    ('38', 'https://rika.vtexassets.com/arquivos/ids/266219/conan-cimerio-38.jpg'),
    ('39', 'https://rika.vtexassets.com/arquivos/ids/266220/conan-cimerio-39.jpg'),
    ('40', 'https://rika.vtexassets.com/arquivos/ids/266221/conan-cimerio-40.jpg'),
    ('41', 'https://rika.vtexassets.com/arquivos/ids/266222/conan-cimerio-41.jpg'),
    ('42', 'https://rika.vtexassets.com/arquivos/ids/266223/conan-cimerio-42.jpg'),
    ('43', 'https://rika.vtexassets.com/arquivos/ids/266224/conan-cimerio-43.jpg'),
    ('44', 'https://rika.vtexassets.com/arquivos/ids/266225/conan-cimerio-44.jpg'),
    ('45', 'https://rika.vtexassets.com/arquivos/ids/266226/conan-cimerio-45.jpg'),
    ('46', 'https://rika.vtexassets.com/arquivos/ids/266227/conan-cimerio-46.jpg'),
    ('47', 'https://rika.vtexassets.com/arquivos/ids/266228/conan-cimerio-47.jpg'),
    ('48', 'https://rika.vtexassets.com/arquivos/ids/266229/conan-cimerio-48.jpg'),
    ('49', 'https://rika.vtexassets.com/arquivos/ids/266230/conan-cimerio-49.jpg'),
    ('50', 'https://rika.vtexassets.com/arquivos/ids/266231/conan-cimerio-50.jpg')
), serie_conan AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'conan-o-cimerio-mythos-2004'
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
    'Conan, O Cimerio #' || capa.numero,
    'Edicao ' || capa.numero || ' da serie Conan, O Cimerio publicada pela Mythos.',
    'Edicao ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'conan-o-cimerio-mythos-2004-' || capa.numero,
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

