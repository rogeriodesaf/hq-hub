-- Cadastra a segunda edicao de Tex publicada pela RGE, da edicao extra 94-A a 134.
-- Fonte: catalogo publico da Rika (VTEX). URLs genericas de imagem indisponivel sao ignoradas.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'RGE / Rio Grafica',
    'Rio Grafica e Editora, editora brasileira que publicou esta fase de Tex.',
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
    'Segunda edicao brasileira de Tex publicada pela RGE, da edicao extra 94-A ao numero 134.',
    2,
    'RIKA',
    'tex-rge-segunda-edicao',
    'https://www.rika.com.br/tex---2%C2%AA-edicao--094-a12000621/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('RGE / Rio Grafica'),
    hqhub_normalizar_titulo_serie('Rio Grafica e Editora')
)
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
    ('94-A', 'https://rika.vteximg.com.br/arquivos/ids/157430/-bonelli-tex-2-s-94-a.jpg?v=635312922875870000'),
    ('95', 'https://rika.vteximg.com.br/arquivos/ids/449273/tex-2-edicao-095.jpg?v=638318782766900000'),
    ('96', NULL),
    ('97', NULL),
    ('98', 'https://rika.vteximg.com.br/arquivos/ids/157434/-bonelli-tex-2-s-98.jpg?v=635312922941200000'),
    ('99', 'https://rika.vteximg.com.br/arquivos/ids/285652/tex-2-edicao-099.jpg?v=636195818975200000'),
    ('100', NULL),
    ('101', NULL),
    ('102', NULL),
    ('103', NULL),
    ('104', NULL),
    ('105', 'https://rika.vteximg.com.br/arquivos/ids/449290/tex-2-edicao-105.jpg?v=638318799885330000'),
    ('106', 'https://rika.vteximg.com.br/arquivos/ids/285653/tex-2-edicao-106.jpg?v=636195819658370000'),
    ('107', 'https://rika.vteximg.com.br/arquivos/ids/449274/tex-2-edicao-107.jpg?v=638318783385900000'),
    ('108', NULL),
    ('109', 'https://rika.vteximg.com.br/arquivos/ids/285654/tex-2-edicao-109.jpg?v=636195820195000000'),
    ('110', NULL),
    ('111', 'https://rika.vteximg.com.br/arquivos/ids/449275/tex-2-edicao-111.jpg?v=638318784050200000'),
    ('112', 'https://rika.vteximg.com.br/arquivos/ids/157448/-bonelli-tex-2-s-112.jpg?v=635312923154730000'),
    ('113', 'https://rika.vteximg.com.br/arquivos/ids/449276/tex-2-edicao-113.jpg?v=638318784613570000'),
    ('114', NULL),
    ('115', 'https://rika.vteximg.com.br/arquivos/ids/449277/tex-2-edicao-115.jpg?v=638318785934970000'),
    ('116', 'https://rika.vteximg.com.br/arquivos/ids/449278/tex-2-edicao-116.jpg?v=638318786382170000'),
    ('117', 'https://rika.vteximg.com.br/arquivos/ids/449279/tex-2-edicao-117.jpg?v=638318786795430000'),
    ('118', NULL),
    ('119', 'https://rika.vteximg.com.br/arquivos/ids/449280/tex-2-edicao-119.jpg?v=638318787194000000'),
    ('120', 'https://rika.vteximg.com.br/arquivos/ids/449281/tex-2-edicao-120.jpg?v=638318787771530000'),
    ('121', 'https://rika.vteximg.com.br/arquivos/ids/449282/tex-2-edicao-121.jpg?v=638318788233800000'),
    ('122', 'https://rika.vteximg.com.br/arquivos/ids/449283/tex-2-edicao-122.jpg?v=638318788747170000'),
    ('123', 'https://rika.vteximg.com.br/arquivos/ids/405705/https---www.artesequencial.com.br-imagens-bonelli-Tex_2Edicao_123.jpg?v=637593799682100000'),
    ('124', 'https://rika.vteximg.com.br/arquivos/ids/449284/tex-2-edicao-124.jpg?v=638318789487930000'),
    ('125', 'https://rika.vteximg.com.br/arquivos/ids/318696/Tex-2-Edicao-125.jpg?v=636855921622100000'),
    ('126', 'https://rika.vteximg.com.br/arquivos/ids/449285/tex-2-edicao-126.jpg?v=638318789878100000'),
    ('127', 'https://rika.vteximg.com.br/arquivos/ids/157465/-bonelli-tex-2-s-127.jpg?v=635312923420370000'),
    ('128', 'https://rika.vteximg.com.br/arquivos/ids/157466/-bonelli-tex-2-s-128.jpg?v=635312923431670000'),
    ('129', NULL),
    ('130', NULL),
    ('131', 'https://rika.vteximg.com.br/arquivos/ids/285655/tex-2-edicao-131.jpg?v=636195821182930000'),
    ('132', 'https://rika.vteximg.com.br/arquivos/ids/157470/-bonelli-tex-2-s-132.jpg?v=635312923492430000'),
    ('133', 'https://rika.vteximg.com.br/arquivos/ids/285656/tex-2-edicao-133.jpg?v=636195822780900000'),
    ('134', 'https://rika.vteximg.com.br/arquivos/ids/405707/https---www.artesequencial.com.br-imagens-bonelli-Tex_2Edicao_134.jpg?v=637593799718700000')
), serie_tex_rge_segunda_edicao AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('RGE / Rio Grafica'),
          hqhub_normalizar_titulo_serie('Rio Grafica e Editora')
      )
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
    'tex-rge-segunda-edicao-' || lower(capa.numero),
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_rge_segunda_edicao serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

