-- Cadastra Tex Willer Especial publicada pela Mythos, dos numeros 1 a 8.
-- A fonte Rika nomeia a serie como Tex Willer.
-- Imagens genericas indisponiveis sao ignoradas. Nenhuma imagem vem do Guia dos Quadrinhos.

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
    'Tex Willer Especial',
    'Tex Willer Especial publicada pela Mythos, dos números 1 a 8.',
    1,
    'RIKA',
    'tex-willer-especial-mythos-volume-1',
    'https://www.rika.com.br/tex-willer--01-12003046/p',
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/333171/Tex-Willer-1.jpg?v=637019072445370000'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/333172/Tex-Willer-2.jpg?v=637019072459930000'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/405945/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_03.jpg?v=637593804551370000'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/405947/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_04.jpg?v=637593804616670000'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/405949/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_05.jpg?v=637593804655100000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/405951/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_06.jpg?v=637593804693000000'),
    ('7', NULL),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/405953/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_08.jpg?v=637593804735200000')
), serie_tex_willer_especial AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Willer Especial')
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
    'Tex Willer Especial #' || capa.numero,
    'Tex Willer Especial - número ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-willer-especial-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_willer_especial serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

