-- Cadastra Tex Edicao Especial Colorida publicada pela Mythos, dos numeros 1 a 24.
-- Fontes das capas: Rika, Martins Fontes e loja oficial da Mythos.
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
    'Tex Edição Especial Colorida',
    'Tex Edição Especial Colorida publicada pela Mythos, dos números 1 a 24.',
    1,
    'RIKA',
    'tex-edicao-especial-colorida-mythos-volume-1',
    'https://www.rika.com.br/tex---edicao-especial-colorida--01-12003004/p',
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

WITH capas(numero, url_capa, fonte) AS (VALUES
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/333130/Tex-Edicao-Especial-Colorida-1.jpg?v=637019072085270000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/333131/Tex-Edicao-Especial-Colorida-2.jpg?v=637019072095170000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/333132/Tex-Edicao-Especial-Colorida-3.jpg?v=637019072103630000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/333133/Tex-Edicao-Especial-Colorida-4.jpg?v=637019072109300000', 'RIKA'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/333134/Tex-Edicao-Especial-Colorida-5.jpg?v=637019072118970000', 'RIKA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/333135/Tex-Edicao-Especial-Colorida-6.jpg?v=637019072126170000', 'RIKA'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/333136/Tex-Edicao-Especial-Colorida-7.jpg?v=637019072133500000', 'RIKA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/333137/Tex-Edicao-Especial-Colorida-8.jpg?v=637019072142200000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/333138/Tex-Edicao-Especial-Colorida-9.jpg?v=637019072150530000', 'RIKA'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/333139/Tex-Edicao-Especial-Colorida-10.jpg?v=637019072162030000', 'RIKA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/333140/Tex-Edicao-Especial-Colorida-11.jpg?v=637019072169970000', 'RIKA'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/333141/Tex-Edicao-Especial-Colorida-12.jpg?v=637019072182400000', 'RIKA'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/405923/https---www.artesequencial.com.br-imagens-bonelli-Tex_Edicao_Especial_Colorida_13.jpg?v=637593804097030000', 'RIKA'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/345574/Tex-Edicao-Especial-Colorida-14.jpg?v=637234521684700000', 'RIKA'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/395035/Tex-Edicao-Especial-Colorida-15.jpg?v=637483228612230000', 'RIKA'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/406132/https---www.artesequencial.com.br-imagens-bonelli-Tex_Edicao_Especial_Colorida_16.jpg?v=637593809972030000', 'RIKA'),
    ('17', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1394564/951528.jpg?v=637618657464830000', 'MARTINS_FONTES'),
    ('18', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_especial_colorida_no_18_abril_2024_1710835_1_29f6ac888616ee74e721856f4b8c37d4.jpg', 'MYTHOS'),
    ('19', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_especial_colorida_no_19_agosto_2024_1711155_1_2f458bcde603ef2307ab85ed7f94da2d.jpg', 'MYTHOS'),
    ('20', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_especial_colorida_no_20_dezembro_2024_1711247_1_6dd51c03e0df51f7bc9450c9f069981d.jpg', 'MYTHOS'),
    ('21', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_especial_colorida_no_21_marco_2025_1711491_1_0c5cb3986ce2b14b3fb948269afcfa76.jpg', 'MYTHOS'),
    ('22', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_especial_colorida_no_22_julho_2025_1711643_1_3fd3428dd9235486a1ae6e3093f1e01f.jpg', 'MYTHOS'),
    ('23', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_especial_colorida_n_23_janeiro2026_1_20260110132811_ca6680c6e2aa.jpg', 'MYTHOS'),
    ('24', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_especial_colorida_n_24_julho2026_1_20260703175830_2e89ddac8be6.jpg', 'MYTHOS')
), serie_tex_especial_colorida AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Edição Especial Colorida')
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
    'Tex Edição Especial Colorida #' || capa.numero,
    'Tex Edição Especial Colorida - número ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-edicao-especial-colorida-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_especial_colorida serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
