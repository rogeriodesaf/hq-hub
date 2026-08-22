-- Cadastra Tex Gold publicada pela Salvat, dos numeros 1 a 60.
-- Fonte das capas: catalogo publico da Rika (VTEX).
-- Imagens genericas indisponiveis sao ignoradas. Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Salvat',
    'Editora responsavel pela colecao brasileira Tex Gold.',
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
    'Tex Gold',
    'Tex Gold publicada pela Salvat, dos números 1 a 60.',
    1,
    'RIKA',
    'tex-gold-salvat-volume-1',
    'https://www.rika.com.br/tex-gold--01-12002955/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Salvat')
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/376617/Tex-Gold---01.jpg?v=637349181788030000'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/376619/Tex-Gold---02.jpg?v=637349181835900000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/376621/Tex-Gold---03.jpg?v=637349181877830000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/376623/Tex-Gold---04.jpg?v=637349181921970000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/376625/Tex-Gold---05.jpg?v=637349182065770000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/376627/Tex-Gold---06.jpg?v=637349182108970000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/376629/Tex-Gold---07.jpg?v=637349182154130000'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/376631/Tex-Gold---08.jpg?v=637349182190100000'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/376633/Tex-Gold---09.jpg?v=637349182229070000'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/376635/Tex-Gold---10.jpg?v=637349182265930000'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/376637/Tex-Gold---11.jpg?v=637349182302630000'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/376639/Tex-Gold---12.jpg?v=637349182340200000'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/376641/Tex-Gold---13.jpg?v=637349182378030000'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/376643/Tex-Gold---14.jpg?v=637349182422630000'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/376645/Tex-Gold---15.jpg?v=637349182467070000'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/405919/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_16.jpg?v=637593804017900000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/376647/Tex-Gold---17.jpg?v=637349183101370000'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/376649/Tex-Gold---18.jpg?v=637349183161930000'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/376651/Tex-Gold---19.jpg?v=637349183209500000'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/376653/Tex-Gold---20.jpg?v=637349183250870000'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/376655/Tex-Gold---21.jpg?v=637349183298430000'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/376657/Tex-Gold---22.jpg?v=637349183348670000'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/376659/Tex-Gold---23.jpg?v=637349183398570000'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/376661/Tex-Gold---24.jpg?v=637349183438930000'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/376663/Tex-Gold---25.jpg?v=637349183473670000'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/376665/Tex-Gold---26.jpg?v=637349183511230000'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/376667/Tex-Gold---27.jpg?v=637349183547770000'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/376669/Tex-Gold---28.jpg?v=637349183583900000'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/376671/Tex-Gold---29.jpg?v=637349183633400000'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/376673/Tex-Gold---30.jpg?v=637349183668470000'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/376675/Tex-Gold---31.jpg?v=637349183705530000'),
    ('32', NULL),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/376677/Tex-Gold---33.jpg?v=637349184341300000'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/376679/Tex-Gold---34.jpg?v=637349184383330000'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/376681/Tex-Gold---35.jpg?v=637349184482430000'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/376683/Tex-Gold---36.jpg?v=637349184528130000'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/376685/Tex-Gold---37.jpg?v=637349184576400000'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/376687/Tex-Gold---38.jpg?v=637349184683370000'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/376689/Tex-Gold---39.jpg?v=637349184782370000'),
    ('40', 'https://rika.vteximg.com.br/arquivos/ids/376691/Tex-Gold---40.jpg?v=637349184913100000'),
    ('41', NULL),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/406071/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_42.jpg?v=637593807591030000'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/406073/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_43.jpg?v=637593807661930000'),
    ('44', NULL),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/406075/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_45.jpg?v=637593807719030000'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/406077/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_46.jpg?v=637593807789330000'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/406079/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_47.jpg?v=637593807843330000'),
    ('48', NULL),
    ('49', NULL),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/406081/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_50.jpg?v=637593807902800000'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/406082/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_51.jpg?v=637593808073770000'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/406083/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_52.jpg?v=637593808173400000'),
    ('53', NULL),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/406084/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_54.jpg?v=637593808234300000'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/406086/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_55.jpg?v=637593808331400000'),
    ('56', NULL),
    ('57', 'https://rika.vteximg.com.br/arquivos/ids/406088/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_57.jpg?v=637593808378030000'),
    ('58', 'https://rika.vteximg.com.br/arquivos/ids/406090/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_58.jpg?v=637593808433000000'),
    ('59', 'https://rika.vteximg.com.br/arquivos/ids/406092/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_59.jpg?v=637593808540300000'),
    ('60', 'https://rika.vteximg.com.br/arquivos/ids/406094/https---www.artesequencial.com.br-imagens-bonelli-Tex_Gold_60.jpg?v=637593808615100000')
), serie_tex_gold AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Gold')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Salvat')
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
    'Tex Gold #' || capa.numero,
    'Tex Gold - número ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-gold-salvat-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_gold serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

