-- Cadastra os oito volumes de Tex - Grandes Mestres publicados pela Mythos.
-- Fonte das capas: loja oficial da Mythos. Nenhuma imagem vem do Guia dos Quadrinhos.

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
    'Tex - Grandes Mestres',
    'Coleção da Mythos com histórias selecionadas de grandes desenhistas da saga de Tex.',
    1,
    'MYTHOS',
    'tex-grandes-mestres-mythos-volume-1',
    'https://www.lojamythos.com.br/tex-grandes-mestres',
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
    ('1', 'https://images.tcdn.com.br/img/img_prod/1119494/tex_grandes_mestres_vol_01_1710723_1_322f6b1264399a37a4367feb4cdaf576.jpg'),
    ('2', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_02_abril_2024_1710827_1_1abf9a35ba16ca5d32f6de67ddbd0d73.jpg'),
    ('3', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_03_julho_2024_1711147_1_478595898fb2484b8120f74fbcef3d28.jpg'),
    ('4', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_04_janeiro_2025_1711267_1_52b28d53d788e46cb28dff0c699073d6.jpg'),
    ('5', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_05_julho_2025_1711639_1_0d5856d88a82df39d1d55ffb54178a87.jpg'),
    ('6', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_06_outubro_2025_1711773_1_bea797ad6923a7800566ee3fd2514530.jpg'),
    ('7', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_grandes_mestres_vol_07_janeiro_2026_1711879_1_45796d51046f41bb92845b8cc08284de.jpg'),
    ('8', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_grandes_mestres_vol_08_julho2026_1_20260703165015_c0c72a1d093b.jpg')
), serie_tex_grandes_mestres AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex - Grandes Mestres')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
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
    'Tex - Grandes Mestres #' || capa.numero,
    'Tex - Grandes Mestres - volume ' || capa.numero,
    capa.url_capa,
    'MYTHOS',
    'tex-grandes-mestres-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_grandes_mestres serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
