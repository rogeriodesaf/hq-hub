-- Cadastra a segunda serie de Tex Gigante da Mythos, republicada em papel offset.
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
    'Tex Gigante',
    'Republicacao de Tex Edicao Gigante pela Mythos em papel offset, iniciada em 2025.',
    2,
    'MYTHOS',
    'tex-gigante-mythos-volume-2',
    'https://www.lojamythos.com.br/hq-s/pre-venda-tex-ed-gigante-no-001-republicacao-fevereiro2025',
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
    ('1', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_001_republicacao_fevereiro_2025_1711469_1_33721b7a73f03acb10c68096c2c5d346.jpg'),
    ('2', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_002_republicacao_maio_2025_1711543_1_eaf2b923aea51fbb204f10437e7d472b.jpg'),
    ('3', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_003_republicacao_setembro_2025_1711735_1_5af5d73a00c83fd3ff65fc686f5c6e38.jpg'),
    ('4', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_004_republicacao_novembro_2025_1711825_1_66204db7e230ccacb9c4c5d26a6d0e98.jpg'),
    ('5', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_ed_gigante_n_005_republicao_feverei_1_20260204185842_71b4a1ff5c8a.jpg'),
    ('6', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_006_republicacao_maio_2026_1712071_1_98767cba53e473fff9a0458637a0a204.jpg'),
    ('7', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_ed_gigante_n_007_republicao_agosto2_1_20260805180642_4437f33ba24e.jpg')
), serie_tex_gigante AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Gigante')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
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
    'Tex Gigante #' || capa.numero,
    'Republicacao de Tex Edicao Gigante - numero ' || capa.numero,
    capa.url_capa,
    'MYTHOS',
    'tex-gigante-mythos-v2-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_gigante serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
