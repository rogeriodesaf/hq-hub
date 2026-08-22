-- Cadastra Tex Colecao publicada pela Globo, dos numeros 2 a 143.
-- Fonte das capas: catalogo publico da Rika (VTEX). Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Globo',
    'Editora brasileira que publicou esta fase de Tex Colecao.',
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
    'Tex Coleção',
    'Tex Coleção publicada pela Editora Globo, dos números 2 a 143.',
    1,
    'RIKA',
    'tex-colecao-globo-volume-1',
    'https://www.rika.com.br/tex-colecao--00212000892/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('Globo'),
    hqhub_normalizar_titulo_serie('Editora Globo')
)
ORDER BY CASE
    WHEN hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Globo') THEN 0
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
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/157493/-bonelli-tex-colecao-002.jpg?v=635312925338900000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/157494/-bonelli-tex-colecao-003.jpg?v=635312925349970000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/157488/-bonelli-tex-colecao-004.jpg?v=635312925277600000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/157489/-bonelli-tex-colecao-005.jpg?v=635312925290800000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/157495/-bonelli-tex-colecao-006.jpg?v=635312925362670000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/157496/-bonelli-tex-colecao-007.jpg?v=635312925375400000'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/157497/-bonelli-tex-colecao-008.jpg?v=635312925389630000'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/157498/-bonelli-tex-colecao-009.jpg?v=635312925403200000'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/157500/-bonelli-tex-colecao-010.jpg?v=635312925436000000'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/157501/-bonelli-tex-colecao-011.jpg?v=635312925451130000'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/157502/-bonelli-tex-colecao-012.jpg?v=635312925464800000'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/157486/-bonelli-tex-colecao-013.jpg?v=635312925242870000'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/157490/-bonelli-tex-colecao-014.jpg?v=635312925303400000'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/157516/-bonelli-tex-colecao-015.jpg?v=635312925635770000'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/157517/-bonelli-tex-colecao-016.jpg?v=635312925650430000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/157518/-bonelli-tex-colecao-017.jpg?v=635312925665270000'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/157519/-bonelli-tex-colecao-018.jpg?v=635312925682330000'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/157520/-bonelli-tex-colecao-019.jpg?v=635312925697400000'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/157521/-bonelli-tex-colecao-020.jpg?v=635312925713370000'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/157522/-bonelli-tex-colecao-021.jpg?v=635312925725970000'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/157487/-bonelli-tex-colecao-022.jpg?v=635312925263730000'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/157491/-bonelli-tex-colecao-023.jpg?v=635312925315730000'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/157503/-bonelli-tex-colecao-024.jpg?v=635312925479000000'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/157504/-bonelli-tex-colecao-025.jpg?v=635312925492730000'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/157505/-bonelli-tex-colecao-026.jpg?v=635312925505600000'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/157506/-bonelli-tex-colecao-027.jpg?v=635312925517800000'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/157507/-bonelli-tex-colecao-028.jpg?v=635312925530270000'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/157508/-bonelli-tex-colecao-029.jpg?v=635312925542000000'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/157509/-bonelli-tex-colecao-030.jpg?v=635312925553000000'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/157510/-bonelli-tex-colecao-031.jpg?v=635312925563800000'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/157499/-bonelli-tex-colecao-032.jpg?v=635312925417100000'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/157511/-bonelli-tex-colecao-033.jpg?v=635312925574800000'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/157512/-bonelli-tex-colecao-034.jpg?v=635312925588930000'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/157513/-bonelli-tex-colecao-035.jpg?v=635312925599970000'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/157523/-bonelli-tex-colecao-036.jpg?v=635312925739570000'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/157524/-bonelli-tex-colecao-037.jpg?v=635312925754670000'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/157525/-bonelli-tex-colecao-038.jpg?v=635312925768670000'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/157526/-bonelli-tex-colecao-039.jpg?v=635312925781330000'),
    ('40', 'https://rika.vteximg.com.br/arquivos/ids/157514/-bonelli-tex-colecao-040.jpg?v=635312925612600000'),
    ('41', 'https://rika.vteximg.com.br/arquivos/ids/157515/-bonelli-tex-colecao-041.jpg?v=635312925623530000'),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/157527/-bonelli-tex-colecao-042.jpg?v=635312925792570000'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/157528/-bonelli-tex-colecao-043.jpg?v=635312925804930000'),
    ('44', 'https://rika.vteximg.com.br/arquivos/ids/157529/-bonelli-tex-colecao-044.jpg?v=635312925818630000'),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/157530/-bonelli-tex-colecao-045.jpg?v=635312925831100000'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/157531/-bonelli-tex-colecao-046.jpg?v=635312925842430000'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/157532/-bonelli-tex-colecao-047.jpg?v=635312925853400000'),
    ('48', 'https://rika.vteximg.com.br/arquivos/ids/157533/-bonelli-tex-colecao-048.jpg?v=635312925864300000'),
    ('49', 'https://rika.vteximg.com.br/arquivos/ids/157534/-bonelli-tex-colecao-049.jpg?v=635312925878100000'),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/157535/-bonelli-tex-colecao-050.jpg?v=635312925890300000'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/157536/-bonelli-tex-colecao-051.jpg?v=635312925903000000'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/157537/-bonelli-tex-colecao-052.jpg?v=635312925913900000'),
    ('53', 'https://rika.vteximg.com.br/arquivos/ids/157538/-bonelli-tex-colecao-053.jpg?v=635312925926670000'),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/157539/-bonelli-tex-colecao-054.jpg?v=635312925938530000'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/157540/-bonelli-tex-colecao-055.jpg?v=635312925950800000'),
    ('56', 'https://rika.vteximg.com.br/arquivos/ids/157541/-bonelli-tex-colecao-056.jpg?v=635312925964630000'),
    ('57', 'https://rika.vteximg.com.br/arquivos/ids/157542/-bonelli-tex-colecao-057.jpg?v=635312925975000000'),
    ('58', 'https://rika.vteximg.com.br/arquivos/ids/157543/-bonelli-tex-colecao-058.jpg?v=635312925987000000'),
    ('59', 'https://rika.vteximg.com.br/arquivos/ids/157544/-bonelli-tex-colecao-059.jpg?v=635312926001870000'),
    ('60', 'https://rika.vteximg.com.br/arquivos/ids/157548/-bonelli-tex-colecao-060.jpg?v=635312926057830000'),
    ('61', 'https://rika.vteximg.com.br/arquivos/ids/157549/-bonelli-tex-colecao-061.jpg?v=635312926071730000'),
    ('62', 'https://rika.vteximg.com.br/arquivos/ids/157550/-bonelli-tex-colecao-062.jpg?v=635312926086370000'),
    ('63', 'https://rika.vteximg.com.br/arquivos/ids/157551/-bonelli-tex-colecao-063.jpg?v=635312926101300000'),
    ('64', 'https://rika.vteximg.com.br/arquivos/ids/157552/-bonelli-tex-colecao-064.jpg?v=635312926115670000'),
    ('65', 'https://rika.vteximg.com.br/arquivos/ids/157553/-bonelli-tex-colecao-065.jpg?v=635312926129670000'),
    ('66', 'https://rika.vteximg.com.br/arquivos/ids/157554/-bonelli-tex-colecao-066.jpg?v=635312926142030000'),
    ('67', 'https://rika.vteximg.com.br/arquivos/ids/157555/-bonelli-tex-colecao-067.jpg?v=635312926152930000'),
    ('68', 'https://rika.vteximg.com.br/arquivos/ids/157556/-bonelli-tex-colecao-068.jpg?v=635312926165430000'),
    ('69', 'https://rika.vteximg.com.br/arquivos/ids/157557/-bonelli-tex-colecao-069.jpg?v=635312926178000000'),
    ('70', 'https://rika.vteximg.com.br/arquivos/ids/157558/-bonelli-tex-colecao-070.jpg?v=635312926189500000'),
    ('71', 'https://rika.vteximg.com.br/arquivos/ids/157545/-bonelli-tex-colecao-071.jpg?v=635312926015430000'),
    ('72', 'https://rika.vteximg.com.br/arquivos/ids/157559/-bonelli-tex-colecao-072.jpg?v=635312926200430000'),
    ('73', 'https://rika.vteximg.com.br/arquivos/ids/157560/-bonelli-tex-colecao-073.jpg?v=635312926211570000'),
    ('74', 'https://rika.vteximg.com.br/arquivos/ids/157561/-bonelli-tex-colecao-074.jpg?v=635312926222400000'),
    ('75', 'https://rika.vteximg.com.br/arquivos/ids/157562/-bonelli-tex-colecao-075.jpg?v=635312926234230000'),
    ('76', 'https://rika.vteximg.com.br/arquivos/ids/157563/-bonelli-tex-colecao-076.jpg?v=635312926247800000'),
    ('77', 'https://rika.vteximg.com.br/arquivos/ids/157564/-bonelli-tex-colecao-077.jpg?v=635312926260400000'),
    ('78', 'https://rika.vteximg.com.br/arquivos/ids/157565/-bonelli-tex-colecao-078.jpg?v=635312926272530000'),
    ('79', 'https://rika.vteximg.com.br/arquivos/ids/157566/-bonelli-tex-colecao-079.jpg?v=635312926282870000'),
    ('80', 'https://rika.vteximg.com.br/arquivos/ids/157567/-bonelli-tex-colecao-080.jpg?v=635312926294230000'),
    ('81', 'https://rika.vteximg.com.br/arquivos/ids/157568/-bonelli-tex-colecao-081.jpg?v=635312926308430000'),
    ('82', 'https://rika.vteximg.com.br/arquivos/ids/157569/-bonelli-tex-colecao-082.jpg?v=635312926321300000'),
    ('83', 'https://rika.vteximg.com.br/arquivos/ids/157570/-bonelli-tex-colecao-083.jpg?v=635312926333270000'),
    ('84', 'https://rika.vteximg.com.br/arquivos/ids/157571/-bonelli-tex-colecao-084.jpg?v=635312926345630000'),
    ('85', 'https://rika.vteximg.com.br/arquivos/ids/157546/-bonelli-tex-colecao-085.jpg?v=635312926029570000'),
    ('86', 'https://rika.vteximg.com.br/arquivos/ids/157547/-bonelli-tex-colecao-086.jpg?v=635312926041930000'),
    ('87', 'https://rika.vteximg.com.br/arquivos/ids/157572/-bonelli-tex-colecao-087.jpg?v=635312926357900000'),
    ('88', 'https://rika.vteximg.com.br/arquivos/ids/157573/-bonelli-tex-colecao-088.jpg?v=635312926368730000'),
    ('89', 'https://rika.vteximg.com.br/arquivos/ids/157574/-bonelli-tex-colecao-089.jpg?v=635312926379930000'),
    ('90', 'https://rika.vteximg.com.br/arquivos/ids/157575/-bonelli-tex-colecao-090.jpg?v=635312926390930000'),
    ('91', 'https://rika.vteximg.com.br/arquivos/ids/157576/-bonelli-tex-colecao-091.jpg?v=635312926403030000'),
    ('92', 'https://rika.vteximg.com.br/arquivos/ids/157577/-bonelli-tex-colecao-092.jpg?v=635312926421970000'),
    ('93', 'https://rika.vteximg.com.br/arquivos/ids/157578/-bonelli-tex-colecao-093.jpg?v=635312926435800000'),
    ('94', 'https://rika.vteximg.com.br/arquivos/ids/157579/-bonelli-tex-colecao-094.jpg?v=635312926452570000'),
    ('95', 'https://rika.vteximg.com.br/arquivos/ids/157580/-bonelli-tex-colecao-095.jpg?v=635312926466700000'),
    ('96', 'https://rika.vteximg.com.br/arquivos/ids/157581/-bonelli-tex-colecao-096.jpg?v=635312926478100000'),
    ('97', 'https://rika.vteximg.com.br/arquivos/ids/157582/-bonelli-tex-colecao-097.jpg?v=635312926490730000'),
    ('98', 'https://rika.vteximg.com.br/arquivos/ids/157583/-bonelli-tex-colecao-098.jpg?v=635312926506070000'),
    ('99', 'https://rika.vteximg.com.br/arquivos/ids/157584/-bonelli-tex-colecao-099.jpg?v=635312926518670000'),
    ('100', 'https://rika.vteximg.com.br/arquivos/ids/157585/-bonelli-tex-colecao-100.jpg?v=635312926529970000'),
    ('101', 'https://rika.vteximg.com.br/arquivos/ids/157586/-bonelli-tex-colecao-101.jpg?v=635312926539530000'),
    ('102', 'https://rika.vteximg.com.br/arquivos/ids/157587/-bonelli-tex-colecao-102.jpg?v=635312926555270000'),
    ('103', 'https://rika.vteximg.com.br/arquivos/ids/157588/-bonelli-tex-colecao-103.jpg?v=635312926567730000'),
    ('104', 'https://rika.vteximg.com.br/arquivos/ids/157589/-bonelli-tex-colecao-104.jpg?v=635312926582100000'),
    ('105', 'https://rika.vteximg.com.br/arquivos/ids/157590/-bonelli-tex-colecao-105.jpg?v=635312926597000000'),
    ('106', 'https://rika.vteximg.com.br/arquivos/ids/157591/-bonelli-tex-colecao-106.jpg?v=635312926610900000'),
    ('107', 'https://rika.vteximg.com.br/arquivos/ids/157592/-bonelli-tex-colecao-107.jpg?v=635312926623600000'),
    ('108', 'https://rika.vteximg.com.br/arquivos/ids/157593/-bonelli-tex-colecao-108.jpg?v=635312926634670000'),
    ('109', 'https://rika.vteximg.com.br/arquivos/ids/157594/-bonelli-tex-colecao-109.jpg?v=635312926645600000'),
    ('110', 'https://rika.vteximg.com.br/arquivos/ids/157595/-bonelli-tex-colecao-110.jpg?v=635312926658430000'),
    ('111', 'https://rika.vteximg.com.br/arquivos/ids/157596/-bonelli-tex-colecao-111.jpg?v=635312926673400000'),
    ('112', 'https://rika.vteximg.com.br/arquivos/ids/157597/-bonelli-tex-colecao-112.jpg?v=635312926685970000'),
    ('113', 'https://rika.vteximg.com.br/arquivos/ids/157598/-bonelli-tex-colecao-113.jpg?v=635312926698430000'),
    ('114', 'https://rika.vteximg.com.br/arquivos/ids/157599/-bonelli-tex-colecao-114.jpg?v=635312926709370000'),
    ('115', 'https://rika.vteximg.com.br/arquivos/ids/157600/-bonelli-tex-colecao-115.jpg?v=635312926723200000'),
    ('116', 'https://rika.vteximg.com.br/arquivos/ids/157601/-bonelli-tex-colecao-116.jpg?v=635312926737630000'),
    ('117', 'https://rika.vteximg.com.br/arquivos/ids/157602/-bonelli-tex-colecao-117.jpg?v=635312926752200000'),
    ('118', 'https://rika.vteximg.com.br/arquivos/ids/157603/-bonelli-tex-colecao-118.jpg?v=635312926766130000'),
    ('119', 'https://rika.vteximg.com.br/arquivos/ids/157604/-bonelli-tex-colecao-119.jpg?v=635312926780170000'),
    ('120', 'https://rika.vteximg.com.br/arquivos/ids/157605/-bonelli-tex-colecao-120.jpg?v=635312926794470000'),
    ('121', 'https://rika.vteximg.com.br/arquivos/ids/157606/-bonelli-tex-colecao-121.jpg?v=635312926808600000'),
    ('122', 'https://rika.vteximg.com.br/arquivos/ids/157607/-bonelli-tex-colecao-122.jpg?v=635312926822670000'),
    ('123', 'https://rika.vteximg.com.br/arquivos/ids/157608/-bonelli-tex-colecao-123.jpg?v=635312926835700000'),
    ('124', 'https://rika.vteximg.com.br/arquivos/ids/157609/-bonelli-tex-colecao-124.jpg?v=635312926848470000'),
    ('125', 'https://rika.vteximg.com.br/arquivos/ids/157612/-bonelli-tex-colecao-125.jpg?v=635312926883000000'),
    ('126', 'https://rika.vteximg.com.br/arquivos/ids/157613/-bonelli-tex-colecao-126.jpg?v=635312926897900000'),
    ('127', 'https://rika.vteximg.com.br/arquivos/ids/157614/-bonelli-tex-colecao-127.jpg?v=635312926911100000'),
    ('128', 'https://rika.vteximg.com.br/arquivos/ids/157615/-bonelli-tex-colecao-128.jpg?v=635312926925670000'),
    ('129', 'https://rika.vteximg.com.br/arquivos/ids/157616/-bonelli-tex-colecao-129.jpg?v=635312926939930000'),
    ('130', 'https://rika.vteximg.com.br/arquivos/ids/157617/-bonelli-tex-colecao-130.jpg?v=635312926954700000'),
    ('131', 'https://rika.vteximg.com.br/arquivos/ids/157618/-bonelli-tex-colecao-131.jpg?v=635312926971100000'),
    ('132', 'https://rika.vteximg.com.br/arquivos/ids/157619/-bonelli-tex-colecao-132.jpg?v=635312926985370000'),
    ('133', 'https://rika.vteximg.com.br/arquivos/ids/157620/-bonelli-tex-colecao-133.jpg?v=635312926998100000'),
    ('134', 'https://rika.vteximg.com.br/arquivos/ids/157621/-bonelli-tex-colecao-134.jpg?v=635312927012700000'),
    ('135', 'https://rika.vteximg.com.br/arquivos/ids/157622/-bonelli-tex-colecao-135.jpg?v=635312927026500000'),
    ('136', 'https://rika.vteximg.com.br/arquivos/ids/157623/-bonelli-tex-colecao-136.jpg?v=635312927038970000'),
    ('137', 'https://rika.vteximg.com.br/arquivos/ids/157624/-bonelli-tex-colecao-137.jpg?v=635312927051500000'),
    ('138', 'https://rika.vteximg.com.br/arquivos/ids/157625/-bonelli-tex-colecao-138.jpg?v=635312927064370000'),
    ('139', 'https://rika.vteximg.com.br/arquivos/ids/157610/-bonelli-tex-colecao-139.jpg?v=635312926859470000'),
    ('140', 'https://rika.vteximg.com.br/arquivos/ids/157611/-bonelli-tex-colecao-140.jpg?v=635312926870570000'),
    ('141', 'https://rika.vteximg.com.br/arquivos/ids/157626/-bonelli-tex-colecao-141.jpg?v=635312927076770000'),
    ('142', 'https://rika.vteximg.com.br/arquivos/ids/157627/-bonelli-tex-colecao-142.jpg?v=635312927087830000'),
    ('143', 'https://rika.vteximg.com.br/arquivos/ids/157628/-bonelli-tex-colecao-143.jpg?v=635312927099770000')
), serie_tex_colecao_globo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Coleção')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Globo'),
          hqhub_normalizar_titulo_serie('Editora Globo')
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
    'Tex Coleção #' || capa.numero,
    'Tex Coleção - número ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-colecao-globo-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_colecao_globo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

