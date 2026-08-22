-- Cadastra Tex Omnibus publicada pela Mythos, dos volumes 1 a 10.
-- Fonte das capas: catalogo publico da Martins Fontes Paulista.
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
    'Tex Omnibus',
    'Tex Omnibus publicada pela Mythos, dos volumes 1 a 10.',
    1,
    'MARTINS_FONTES_PAULISTA',
    'tex-omnibus-mythos-volume-1',
    'https://www.martinsfontespaulista.com.br/tex-omnibus-volume-1-996606/p',
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
    ('1', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1476816/996606.jpg?v=637880021028330000'),
    ('2', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1515228/1020678.jpg?v=638042450023700000'),
    ('3', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1545884/1044283.jpg?v=638169013994400000'),
    ('4', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1580087/1068537.jpg?v=638304037972900000'),
    ('5', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1618424/1089972.jpg?v=638452714989970000'),
    ('6', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1643909/1105296.jpg?v=638558157176700000'),
    ('7', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1664423/1118189.jpg?v=638652075160470000'),
    ('8', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1687853/1132719.jpg?v=638768134311230000'),
    ('9', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1739786/1170745.jpg?v=638953581093630000'),
    ('10', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1786255/1201600.jpg.jpg?v=639111447950600000')
), serie_tex_omnibus AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Omnibus')
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
    'Tex Omnibus #' || capa.numero,
    'Tex Omnibus - volume ' || capa.numero,
    capa.url_capa,
    'MARTINS_FONTES_PAULISTA',
    'tex-omnibus-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_omnibus serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

