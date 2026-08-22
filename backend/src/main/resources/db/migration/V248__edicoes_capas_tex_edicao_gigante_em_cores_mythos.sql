-- Cadastra os 12 volumes de Tex Edicao Gigante em Cores, da Mythos.
-- Capas obtidas em catalogos publicos de lojas, sem usar o Guia dos Quadrinhos.

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
    'Tex Edição Gigante em Cores',
    'Coleção em capa dura e cores publicada pela Mythos em 12 volumes.',
    1,
    'RIKA',
    'tex-edicao-gigante-em-cores-mythos-volume-1',
    'https://www.rika.com.br/tex---edicao-gigante-em-cores--0112002817/p',
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/319379/Tex-Edicao-Gigante-Em-Cores-01.jpg?v=636894761743800000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/319380/Tex-Edicao-Gigante-Em-Cores-02.jpg?v=636894763170970000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/319381/Tex-Edicao-Gigante-Em-Cores-03.jpg?v=636894764280430000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/319382/Tex-Edicao-Gigante-Em-Cores-04.jpg?v=636894764832800000', 'RIKA'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/405839/https---www.artesequencial.com.br-imagens-bonelli-Tex_Edicao_Gigante_em_Cores_05.jpg?v=637593802293100000', 'RIKA'),
    ('6', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/m/y/mythos_texed6colo.jpg', 'COMIX'),
    ('7', 'https://www.touchelivros.com.br/wp-content/uploads/2025/06/tex_edicao_gigante_em_cores_n_007_o_pueblo_perdido.jpg', 'TOUCHE_LIVROS'),
    ('8', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/m/y/mythostexemcores8.jpg', 'COMIX'),
    ('9', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/m/y/mythos_texgigacores9.jpg', 'COMIX'),
    ('10', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/m/y/mythos_texgigacores10.jpg', 'COMIX'),
    ('11', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/t/e/texedi_aoemcores11.jpg', 'COMIX'),
    ('12', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/t/e/texedi_aoemcores12.jpg', 'COMIX')
), serie_tex_gigante_cores AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Edição Gigante em Cores')
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
    'Tex Edição Gigante em Cores #' || capa.numero,
    'Tex Edição Gigante em Cores - número ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-edicao-gigante-em-cores-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_gigante_cores serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
