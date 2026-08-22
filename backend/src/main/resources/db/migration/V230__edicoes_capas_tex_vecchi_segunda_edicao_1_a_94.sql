-- Cadastra a segunda edicao de Tex publicada pela Vecchi, dos numeros 1 a 94.
-- Fonte: catalogo publico da Rika (VTEX). URLs genericas de imagem indisponivel sao ignoradas.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Vecchi',
    'Editora brasileira que iniciou a publicacao de Tex no Brasil.',
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
    'Tex',
    'Segunda edicao brasileira de Tex publicada pela Vecchi, dos numeros 1 a 94.',
    2,
    'RIKA',
    'tex-vecchi-segunda-edicao',
    'https://www.rika.com.br/tex---2a-edicao--00112000527/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Vecchi')
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/157338/-bonelli-tex-2-s-01.jpg?v=635312921660330000'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/157339/-bonelli-tex-2-s-02.jpg?v=635312921673370000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/157342/-bonelli-tex-2-s-03.jpg?v=635312921711570000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/157343/-bonelli-tex-2-s-04.jpg?v=635312921722870000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/157344/-bonelli-tex-2-s-05.jpg?v=635312921734670000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/157350/-bonelli-tex-2-s-06.jpg?v=635312921806530000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/157351/-bonelli-tex-2-s-07.jpg?v=635312921819600000'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/157336/-bonelli-tex-2-s-08.jpg?v=635312921624570000'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/157340/-bonelli-tex-2-s-09.jpg?v=635312921684400000'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/157366/-bonelli-tex-2-s-10.jpg?v=635312922003170000'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/157367/-bonelli-tex-2-s-11.jpg?v=635312922017670000'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/157368/-bonelli-tex-2-s-12.jpg?v=635312922030430000'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/157369/-bonelli-tex-2-s-13.jpg?v=635312922041800000'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/157370/-bonelli-tex-2-s-14.jpg?v=635312922056030000'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/157371/-bonelli-tex-2-s-15.jpg?v=635312922070600000'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/157372/-bonelli-tex-2-s-16.jpg?v=635312922084830000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/157352/-bonelli-tex-2-s-17.jpg?v=635312921833300000'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/157353/-bonelli-tex-2-s-18.jpg?v=635312921845570000'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/157373/-bonelli-tex-2-s-19.jpg?v=635312922104100000'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/157374/-bonelli-tex-2-s-20.jpg?v=635312922117270000'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/157375/-bonelli-tex-2-s-21.jpg?v=635312922131670000'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/157376/-bonelli-tex-2-s-22.jpg?v=635312922144030000'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/157377/-bonelli-tex-2-s-23.jpg?v=635312922154800000'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/157378/-bonelli-tex-2-s-24.jpg?v=635312922166530000'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/157379/-bonelli-tex-2-s-25.jpg?v=635312922180270000'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/157337/-bonelli-tex-2-s-26.jpg?v=635312921647700000'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/157341/-bonelli-tex-2-s-27.jpg?v=635312921697700000'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/157354/-bonelli-tex-2-s-28.jpg?v=635312921858730000'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/157355/-bonelli-tex-2-s-29.jpg?v=635312921873300000'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/157356/-bonelli-tex-2-s-30.jpg?v=635312921886230000'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/157357/-bonelli-tex-2-s-31.jpg?v=635312921898330000'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/157345/-bonelli-tex-2-s-32.jpg?v=635312921746800000'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/157346/-bonelli-tex-2-s-33.jpg?v=635312921758200000'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/157347/-bonelli-tex-2-s-34.jpg?v=635312921770730000'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/157348/-bonelli-tex-2-s-35.jpg?v=635312921781700000'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/157349/-bonelli-tex-2-s-36.jpg?v=635312921793870000'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/157358/-bonelli-tex-2-s-37.jpg?v=635312921908730000'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/157359/-bonelli-tex-2-s-38.jpg?v=635312921919800000'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/157380/-bonelli-tex-2-s-39.jpg?v=635312922194630000'),
    ('40', 'https://rika.vteximg.com.br/arquivos/ids/157360/-bonelli-tex-2-s-40.jpg?v=635312921932330000'),
    ('41', 'https://rika.vteximg.com.br/arquivos/ids/157361/-bonelli-tex-2-s-41.jpg?v=635312921946200000'),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/157362/-bonelli-tex-2-s-42.jpg?v=635312921958830000'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/157363/-bonelli-tex-2-s-43.jpg?v=635312921969000000'),
    ('44', 'https://rika.vteximg.com.br/arquivos/ids/157364/-bonelli-tex-2-s-44.jpg?v=635312921980100000'),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/157365/-bonelli-tex-2-s-45.jpg?v=635312921990730000'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/157381/-bonelli-tex-2-s-46.jpg?v=635312922208030000'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/157398/-bonelli-tex-2-s-47.jpg?v=635312922421470000'),
    ('48', 'https://rika.vteximg.com.br/arquivos/ids/157382/-bonelli-tex-2-s-48.jpg?v=635312922220430000'),
    ('49', 'https://rika.vteximg.com.br/arquivos/ids/157383/-bonelli-tex-2-s-49.jpg?v=635312922231430000'),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/157384/-bonelli-tex-2-s-50.jpg?v=635312922245800000'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/157385/-bonelli-tex-2-s-51.jpg?v=635312922265370000'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/157386/-bonelli-tex-2-s-52.jpg?v=635312922278600000'),
    ('53', 'https://rika.vteximg.com.br/arquivos/ids/157387/-bonelli-tex-2-s-53.jpg?v=635312922291730000'),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/157388/-bonelli-tex-2-s-54.jpg?v=635312922304200000'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/157389/-bonelli-tex-2-s-55.jpg?v=635312922314700000'),
    ('56', 'https://rika.vteximg.com.br/arquivos/ids/157390/-bonelli-tex-2-s-56.jpg?v=635312922325930000'),
    ('57', 'https://rika.vteximg.com.br/arquivos/ids/157391/-bonelli-tex-2-s-57.jpg?v=635312922337070000'),
    ('58', 'https://rika.vteximg.com.br/arquivos/ids/157392/-bonelli-tex-2-s-58.jpg?v=635312922347700000'),
    ('59', 'https://rika.vteximg.com.br/arquivos/ids/157393/-bonelli-tex-2-s-59.jpg?v=635312922359730000'),
    ('60', 'https://rika.vteximg.com.br/arquivos/ids/157394/-bonelli-tex-2-s-60.jpg?v=635312922371600000'),
    ('61', 'https://rika.vteximg.com.br/arquivos/ids/157395/-bonelli-tex-2-s-61.jpg?v=635312922383500000'),
    ('62', 'https://rika.vteximg.com.br/arquivos/ids/157396/-bonelli-tex-2-s-62.jpg?v=635312922396970000'),
    ('63', 'https://rika.vteximg.com.br/arquivos/ids/157397/-bonelli-tex-2-s-63.jpg?v=635312922409100000'),
    ('64', 'https://rika.vteximg.com.br/arquivos/ids/157399/-bonelli-tex-2-s-64.jpg?v=635312922435600000'),
    ('65', 'https://rika.vteximg.com.br/arquivos/ids/157400/-bonelli-tex-2-s-65.jpg?v=635312922448930000'),
    ('66', 'https://rika.vteximg.com.br/arquivos/ids/157401/-bonelli-tex-2-s-66.jpg?v=635312922460300000'),
    ('67', 'https://rika.vteximg.com.br/arquivos/ids/157402/-bonelli-tex-2-s-67.jpg?v=635312922472930000'),
    ('68', 'https://rika.vteximg.com.br/arquivos/ids/157403/-bonelli-tex-2-s-68.jpg?v=635312922484100000'),
    ('69', 'https://rika.vteximg.com.br/arquivos/ids/157404/-bonelli-tex-2-s-69.jpg?v=635312922497130000'),
    ('70', 'https://rika.vteximg.com.br/arquivos/ids/157405/-bonelli-tex-2-s-70.jpg?v=635312922511500000'),
    ('71', 'https://rika.vteximg.com.br/arquivos/ids/157406/-bonelli-tex-2-s-71.jpg?v=635312922526070000'),
    ('72', 'https://rika.vteximg.com.br/arquivos/ids/157407/-bonelli-tex-2-s-72.jpg?v=635312922562570000'),
    ('73', 'https://rika.vteximg.com.br/arquivos/ids/157408/-bonelli-tex-2-s-73.jpg?v=635312922576630000'),
    ('74', 'https://rika.vteximg.com.br/arquivos/ids/157409/-bonelli-tex-2-s-74.jpg?v=635312922590370000'),
    ('75', 'https://rika.vteximg.com.br/arquivos/ids/157410/-bonelli-tex-2-s-75.jpg?v=635312922600730000'),
    ('76', 'https://rika.vteximg.com.br/arquivos/ids/157411/-bonelli-tex-2-s-76.jpg?v=635312922613130000'),
    ('77', 'https://rika.vteximg.com.br/arquivos/ids/157412/-bonelli-tex-2-s-77.jpg?v=635312922624200000'),
    ('78', 'https://rika.vteximg.com.br/arquivos/ids/157413/-bonelli-tex-2-s-78.jpg?v=635312922636370000'),
    ('79', 'https://rika.vteximg.com.br/arquivos/ids/157414/-bonelli-tex-2-s-79.jpg?v=635312922649100000'),
    ('80', 'https://rika.vteximg.com.br/arquivos/ids/449272/tex-2-edicao-080.jpg?v=638318768099200000'),
    ('81', 'https://rika.vteximg.com.br/arquivos/ids/157416/-bonelli-tex-2-s-81.jpg?v=635312922676570000'),
    ('82', 'https://rika.vteximg.com.br/arquivos/ids/157417/-bonelli-tex-2-s-82.jpg?v=635312922690000000'),
    ('83', 'https://rika.vteximg.com.br/arquivos/ids/157418/-bonelli-tex-2-s-83.jpg?v=635312922703900000'),
    ('84', 'https://rika.vteximg.com.br/arquivos/ids/405701/https---www.artesequencial.com.br-imagens-bonelli-Tex_2Edicao_084.jpg?v=637593799610000000'),
    ('85', 'https://rika.vteximg.com.br/arquivos/ids/157420/-bonelli-tex-2-s-85.jpg?v=635312922732970000'),
    ('86', 'https://rika.vteximg.com.br/arquivos/ids/405703/https---www.artesequencial.com.br-imagens-bonelli-Tex_2Edicao_086.jpg?v=637593799646300000'),
    ('87', 'https://rika.vteximg.com.br/arquivos/ids/157422/-bonelli-tex-2-s-87.jpg?v=635312922760830000'),
    ('88', NULL),
    ('89', 'https://rika.vteximg.com.br/arquivos/ids/157424/-bonelli-tex-2-s-89.jpg?v=635312922785700000'),
    ('90', NULL),
    ('91', NULL),
    ('92', NULL),
    ('93', NULL),
    ('94', NULL)
), serie_tex_vecchi_segunda_edicao AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Vecchi')
      AND serie.volume = 2
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
    'Tex - 2a Edicao #' || capa.numero,
    'Tex - 2a Edicao - numero ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-vecchi-segunda-edicao-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_vecchi_segunda_edicao serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

