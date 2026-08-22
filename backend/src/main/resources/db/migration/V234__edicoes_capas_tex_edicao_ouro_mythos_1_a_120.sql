-- Cadastra Tex Edicao de Ouro publicada pela Mythos, dos numeros 1 a 120.
-- Fonte: catalogo publico da Rika (VTEX). Imagens genericas indisponiveis sao ignoradas.
-- Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Mythos',
    'Editora brasileira de historias em quadrinhos.',
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
    'Tex Edição de Ouro',
    'Tex Edição de Ouro publicada pela Mythos, dos números 1 a 120.',
    1,
    'RIKA',
    'tex-edicao-de-ouro-mythos-volume-1',
    'https://www.rika.com.br/tex-ouro--0112000841/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('Mythos'),
    hqhub_normalizar_titulo_serie('Mythos Editora')
)
ORDER BY CASE
    WHEN hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos') THEN 0
    ELSE 1
END, editora.id
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/155538/-bonelli-tex-ouro-01.jpg?v=635312786216530000'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/155539/-bonelli-tex-ouro-02.jpg?v=635312786232000000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/155542/-bonelli-tex-ouro-03.jpg?v=635312786285130000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/155536/-bonelli-tex-ouro-04.jpg?v=635312786172600000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/155540/-bonelli-tex-ouro-05.jpg?v=635312786246170000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/155550/-bonelli-tex-ouro-06.jpg?v=635312786424100000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/155551/-bonelli-tex-ouro-07.jpg?v=635312786438500000'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/155552/-bonelli-tex-ouro-08.jpg?v=635312786454830000'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/155553/-bonelli-tex-ouro-09.jpg?v=635312786471100000'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/155554/-bonelli-tex-ouro-10.jpg?v=635312786485500000'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/155566/-bonelli-tex-ouro-11.jpg?v=635312786701270000'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/155567/-bonelli-tex-ouro-12.jpg?v=635312786719000000'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/155537/-bonelli-tex-ouro-13.jpg?v=635312786198030000'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/155541/-bonelli-tex-ouro-14.jpg?v=635312786265900000'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/155555/-bonelli-tex-ouro-15.jpg?v=635312786502770000'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/155556/-bonelli-tex-ouro-16.jpg?v=635312786525400000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/155557/-bonelli-tex-ouro-17.jpg?v=635312786540970000'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/155558/-bonelli-tex-ouro-18.jpg?v=635312786553330000'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/155559/-bonelli-tex-ouro-19.jpg?v=635312786571300000'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/155560/-bonelli-tex-ouro-20.jpg?v=635312786586830000'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/155561/-bonelli-tex-ouro-21.jpg?v=635312786600800000'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/155562/-bonelli-tex-ouro-22.jpg?v=635312786614930000'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/155563/-bonelli-tex-ouro-23.jpg?v=635312786633700000'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/155564/-bonelli-tex-ouro-24.jpg?v=635312786651830000'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/155543/-bonelli-tex-ouro-25.jpg?v=635312786306030000'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/155544/-bonelli-tex-ouro-26.jpg?v=635312786322500000'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/155545/-bonelli-tex-ouro-27.jpg?v=635312786339630000'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/155546/-bonelli-tex-ouro-28.jpg?v=635312786355500000'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/155547/-bonelli-tex-ouro-29.jpg?v=635312786371700000'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/155548/-bonelli-tex-ouro-30.jpg?v=635312786388630000'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/155549/-bonelli-tex-ouro-31.jpg?v=635312786405570000'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/155565/-bonelli-tex-ouro-32.jpg?v=635312786684470000'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/155568/-bonelli-tex-ouro-33.jpg?v=635312786736000000'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/155569/-bonelli-tex-ouro-34.jpg?v=635312786754830000'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/155570/-bonelli-tex-ouro-35.jpg?v=635312786773600000'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/155571/-bonelli-tex-ouro-36.jpg?v=635312786789300000'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/155572/-bonelli-tex-ouro-37.jpg?v=635312786838070000'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/155573/-bonelli-tex-ouro-38.jpg?v=635312786854800000'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/155574/-bonelli-tex-ouro-39.jpg?v=635312786869070000'),
    ('40', 'https://rika.vteximg.com.br/arquivos/ids/155575/-bonelli-tex-ouro-40.jpg?v=635312786884600000'),
    ('41', 'https://rika.vteximg.com.br/arquivos/ids/155576/-bonelli-tex-ouro-41.jpg?v=635312786901870000'),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/155577/-bonelli-tex-ouro-42.jpg?v=635312786920270000'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/155578/-bonelli-tex-ouro-43.jpg?v=635312786938430000'),
    ('44', 'https://rika.vteximg.com.br/arquivos/ids/155579/-bonelli-tex-ouro-44.jpg?v=635312786956300000'),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/155580/-bonelli-tex-ouro-45.jpg?v=635312786972100000'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/155581/-bonelli-tex-ouro-46.jpg?v=635312786986570000'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/155582/-bonelli-tex-ouro-47.jpg?v=635312787010000000'),
    ('48', 'https://rika.vteximg.com.br/arquivos/ids/155583/-bonelli-tex-ouro-48.jpg?v=635312787025800000'),
    ('49', 'https://rika.vteximg.com.br/arquivos/ids/155584/-bonelli-tex-ouro-49.jpg?v=635312787042370000'),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/155585/-bonelli-tex-ouro-50.jpg?v=635312787094000000'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/155586/-bonelli-tex-ouro-51.jpg?v=635312787114130000'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/155587/-bonelli-tex-ouro-52.jpg?v=635312787129600000'),
    ('53', 'https://rika.vteximg.com.br/arquivos/ids/155588/-bonelli-tex-ouro-53.jpg?v=635312787145100000'),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/155589/-bonelli-tex-ouro-54.jpg?v=635312787162700000'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/155590/-bonelli-tex-ouro-55.jpg?v=635312787181430000'),
    ('56', 'https://rika.vteximg.com.br/arquivos/ids/155591/-bonelli-tex-ouro-56.jpg?v=635312787199630000'),
    ('57', 'https://rika.vteximg.com.br/arquivos/ids/155592/-bonelli-tex-ouro-57.jpg?v=635312787218470000'),
    ('58', 'https://rika.vteximg.com.br/arquivos/ids/155593/-bonelli-tex-ouro-58.jpg?v=635312787233430000'),
    ('59', 'https://rika.vteximg.com.br/arquivos/ids/155594/-bonelli-tex-ouro-59.jpg?v=635312787251830000'),
    ('60', 'https://rika.vteximg.com.br/arquivos/ids/319395/Tex-Ouro-60.jpg?v=636894791195500000'),
    ('61', 'https://rika.vteximg.com.br/arquivos/ids/319396/Tex-Ouro-61.jpg?v=636894791820800000'),
    ('62', 'https://rika.vteximg.com.br/arquivos/ids/283614/tex-ouro-62.jpg?v=635915771592930000'),
    ('63', 'https://rika.vteximg.com.br/arquivos/ids/283615/tex-ouro-63.jpg?v=635915771612300000'),
    ('64', 'https://rika.vteximg.com.br/arquivos/ids/405821/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_64.jpg?v=637593801925100000'),
    ('65', 'https://rika.vteximg.com.br/arquivos/ids/283617/tex-ouro-65.jpg?v=635915771653730000'),
    ('66', 'https://rika.vteximg.com.br/arquivos/ids/283618/tex-ouro-66.jpg?v=635915771675700000'),
    ('67', 'https://rika.vteximg.com.br/arquivos/ids/283619/tex-ouro-67.jpg?v=635915771694970000'),
    ('68', 'https://rika.vteximg.com.br/arquivos/ids/283620/tex-ouro-68.jpg?v=635915771713000000'),
    ('69', 'https://rika.vteximg.com.br/arquivos/ids/283621/tex-ouro-69.jpg?v=635915771734030000'),
    ('70', 'https://rika.vteximg.com.br/arquivos/ids/283622/tex-ouro-70.jpg?v=635915771752470000'),
    ('71', 'https://rika.vteximg.com.br/arquivos/ids/283623/tex-ouro-71.jpg?v=635915771771200000'),
    ('72', 'https://rika.vteximg.com.br/arquivos/ids/283624/tex-ouro-72.jpg?v=635915771792400000'),
    ('73', 'https://rika.vteximg.com.br/arquivos/ids/283625/tex-ouro-73.jpg?v=635915771811100000'),
    ('74', 'https://rika.vteximg.com.br/arquivos/ids/283626/tex-ouro-74.jpg?v=635915771830000000'),
    ('75', 'https://rika.vteximg.com.br/arquivos/ids/283627/tex-ouro-75.jpg?v=635915771855230000'),
    ('76', 'https://rika.vteximg.com.br/arquivos/ids/285658/tex-ouro-76.jpg?v=636195824237800000'),
    ('77', 'https://rika.vteximg.com.br/arquivos/ids/283628/tex-ouro-77.jpg?v=635915771877270000'),
    ('78', 'https://rika.vteximg.com.br/arquivos/ids/283629/tex-ouro-78.jpg?v=635915771896870000'),
    ('79', 'https://rika.vteximg.com.br/arquivos/ids/283630/tex-ouro-79.jpg?v=635915771916230000'),
    ('80', 'https://rika.vteximg.com.br/arquivos/ids/405823/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_80.jpg?v=637593801963600000'),
    ('81', 'https://rika.vteximg.com.br/arquivos/ids/405825/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_81.jpg?v=637593802007430000'),
    ('82', 'https://rika.vteximg.com.br/arquivos/ids/405827/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_82.jpg?v=637593802046070000'),
    ('83', 'https://rika.vteximg.com.br/arquivos/ids/405885/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_83.jpg?v=637593803312430000'),
    ('84', 'https://rika.vteximg.com.br/arquivos/ids/405887/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_84.jpg?v=637593803355770000'),
    ('85', NULL),
    ('86', 'https://rika.vteximg.com.br/arquivos/ids/319397/Tex-Ouro-86.jpg?v=636894792207630000'),
    ('87', 'https://rika.vteximg.com.br/arquivos/ids/405889/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_87.jpg?v=637593803397700000'),
    ('88', 'https://rika.vteximg.com.br/arquivos/ids/319398/Tex-Ouro-88.jpg?v=636894795968630000'),
    ('89', 'https://rika.vteximg.com.br/arquivos/ids/405891/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_89.jpg?v=637593803435570000'),
    ('90', 'https://rika.vteximg.com.br/arquivos/ids/405893/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_90.jpg?v=637593803474230000'),
    ('91', 'https://rika.vteximg.com.br/arquivos/ids/405895/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_91.jpg?v=637593803517870000'),
    ('92', 'https://rika.vteximg.com.br/arquivos/ids/405897/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_92.jpg?v=637593803578730000'),
    ('93', NULL),
    ('94', 'https://rika.vteximg.com.br/arquivos/ids/405899/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_94.jpg?v=637593803618330000'),
    ('95', 'https://rika.vteximg.com.br/arquivos/ids/333143/Tex-Ouro-95.jpg?v=637019072203270000'),
    ('96', 'https://rika.vteximg.com.br/arquivos/ids/333144/Tex-Ouro-96.jpg?v=637019072211800000'),
    ('97', 'https://rika.vteximg.com.br/arquivos/ids/333145/Tex-Ouro-97.jpg?v=637019072221570000'),
    ('98', 'https://rika.vteximg.com.br/arquivos/ids/333146/Tex-Ouro-98.jpg?v=637019072229270000'),
    ('99', 'https://rika.vteximg.com.br/arquivos/ids/333147/Tex-Ouro-99.jpg?v=637019072236170000'),
    ('100', 'https://rika.vteximg.com.br/arquivos/ids/333148/Tex-Ouro-100.jpg?v=637019072241230000'),
    ('101', 'https://rika.vteximg.com.br/arquivos/ids/405925/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_101.jpg?v=637593804138000000'),
    ('102', 'https://rika.vteximg.com.br/arquivos/ids/405927/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_102.jpg?v=637593804178070000'),
    ('103', 'https://rika.vteximg.com.br/arquivos/ids/405929/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_103.jpg?v=637593804222100000'),
    ('104', 'https://rika.vteximg.com.br/arquivos/ids/345596/Tex-Ouro-104.jpg?v=637234521852270000'),
    ('105', 'https://rika.vteximg.com.br/arquivos/ids/345597/Tex-Ouro-105.jpg?v=637234521857930000'),
    ('106', 'https://rika.vteximg.com.br/arquivos/ids/345598/Tex-Ouro-106.jpg?v=637234521863970000'),
    ('107', 'https://rika.vteximg.com.br/arquivos/ids/406068/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_107.jpg?v=637593807429170000'),
    ('108', 'https://rika.vteximg.com.br/arquivos/ids/395026/Tex-Ouro-108.jpg?v=637483228575730000'),
    ('109', 'https://rika.vteximg.com.br/arquivos/ids/395027/Tex-Ouro-109.jpg?v=637483228580330000'),
    ('110', 'https://rika.vteximg.com.br/arquivos/ids/395028/Tex-Ouro-110.jpg?v=637483228585030000'),
    ('111', NULL),
    ('112', NULL),
    ('113', 'https://rika.vteximg.com.br/arquivos/ids/406180/https---www.artesequencial.com.br-imagens-bonelli-Tex_Ouro_113.jpg?v=637593811061400000'),
    ('114', 'https://rika.vteximg.com.br/arquivos/ids/411584/Tex-Ouro-114.jpg?v=637844306084700000'),
    ('115', 'https://rika.vteximg.com.br/arquivos/ids/411585/Tex-Ouro-115.jpg?v=637844306093770000'),
    ('116', 'https://rika.vteximg.com.br/arquivos/ids/411586/Tex-Ouro-116.jpg?v=637844306104400000'),
    ('117', 'https://rika.vteximg.com.br/arquivos/ids/411587/Tex-Ouro-117.jpg?v=637844306113800000'),
    ('118', 'https://rika.vteximg.com.br/arquivos/ids/444360/https---www.artesequencial.com.br-imagens-2023-08-Tex-Ouro-118.jpg?v=638269470692570000'),
    ('119', 'https://rika.vteximg.com.br/arquivos/ids/444362/https---www.artesequencial.com.br-imagens-2023-08-Tex-Ouro-119.jpg?v=638269470714830000'),
    ('120', 'https://rika.vteximg.com.br/arquivos/ids/444364/https---www.artesequencial.com.br-imagens-2023-08-Tex-Ouro-120.jpg?v=638269470737400000')
), serie_tex_edicao_ouro AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Edição de Ouro')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Mythos'),
          hqhub_normalizar_titulo_serie('Mythos Editora')
      )
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
    'Tex Edição de Ouro #' || capa.numero,
    'Tex Edição de Ouro - número ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-edicao-de-ouro-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_edicao_ouro serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

