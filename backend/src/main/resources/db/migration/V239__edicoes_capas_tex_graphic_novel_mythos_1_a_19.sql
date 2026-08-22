-- Cadastra Tex Graphic Novel publicada pela Mythos, dos volumes 1 a 19.
-- Fontes das capas: catalogos publicos da Rika e Martins Fontes Paulista.
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
    'Tex Graphic Novel',
    'Tex Graphic Novel publicada pela Mythos, dos volumes 1 a 19.',
    1,
    'RIKA',
    'tex-graphic-novel-mythos-volume-1',
    'https://www.rika.com.br/tex-graphic-novel--112002846/p',
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

WITH capas(numero, url_capa, fonte) AS (VALUES
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/405847/https---www.artesequencial.com.br-imagens-bonelli-Tex_Graphic_Novel_1.jpg?v=637593802542030000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/313426/Tex-Graphic-Novel-02.jpg?v=636731265517830000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/313427/Tex-Graphic-Novel-03.jpg?v=636731266291800000', 'RIKA'),
    ('4', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/304263/842359_ampliada.jpg?v=637253906741470000', 'MARTINS_FONTES_PAULISTA'),
    ('5', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/304119/842356_ampliada.jpg?v=637253900640200000', 'MARTINS_FONTES_PAULISTA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/333180/Tex-Graphic-Novel-6-Justica-em-Corpus-Christi.jpg?v=637019072531100000', 'RIKA'),
    ('7', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1232803/878164_ampliada.jpg?v=637298859068930000', 'MARTINS_FONTES_PAULISTA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/411572/Tex-Graphic-Novel-8.jpg?v=637844305949630000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/411573/Tex-Graphic-Novel-9.jpg?v=637844305961100000', 'RIKA'),
    ('10', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1394985/949847.jpg?v=637619713501870000', 'MARTINS_FONTES_PAULISTA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/411575/Tex-Graphic-Novel-11.jpg?v=637844305988770000', 'RIKA'),
    ('12', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1518319/1022998.jpg?v=638059741989370000', 'MARTINS_FONTES_PAULISTA'),
    ('13', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1607661/1082608.jpg?v=638514081182230000', 'MARTINS_FONTES_PAULISTA'),
    ('14', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1656763/1113645.jpg?v=638616039129500000', 'MARTINS_FONTES_PAULISTA'),
    ('15', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1677659/1126842.jpg?v=638724220310970000', 'MARTINS_FONTES_PAULISTA'),
    ('16', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1708230/1146747.jpg?v=638852782341670000', 'MARTINS_FONTES_PAULISTA'),
    ('17', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1779501/1197538.jpg?v=639082471588130000', 'MARTINS_FONTES_PAULISTA'),
    ('18', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1789723/1203613.jpg.jpg?v=639126543804300000', 'MARTINS_FONTES_PAULISTA'),
    ('19', NULL, NULL)
), serie_tex_graphic_novel AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Graphic Novel')
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
    'Tex Graphic Novel #' || capa.numero,
    'Tex Graphic Novel - volume ' || capa.numero,
    capa.url_capa,
    COALESCE(capa.fonte, 'CATALOGO_LOJA'),
    'tex-graphic-novel-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_graphic_novel serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

