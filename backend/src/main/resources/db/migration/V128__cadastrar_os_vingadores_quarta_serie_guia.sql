-- Cadastra Os Vingadores (4ª série Panini), suas 32 edições e capas oficiais,
-- e vincula ao guia mutante as edições utilizadas na ordem de leitura.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Os Vingadores',
    'Quarta série brasileira de Os Vingadores, publicada pela Panini em 32 edições.',
    2024,
    2026,
    4,
    'PANINI',
    'PANINI-OS-VINGADORES-V4',
    'https://panini.com.br/os-vingadores-01-58',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Panini')
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

WITH referencias(numero, legado, url_capa) AS (VALUES
    (1, 58, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ceohfu56j139h2jl7tru0civ24/-S265-FWEBP'),
    (2, 59, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5k61cgj0111cbd70bssvtvb77q/-S265-FWEBP'),
    (3, 60, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_imc5pm9bfp3dtcdjp6n0njg16l/-S265-FWEBP'),
    (4, 61, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ohl9dr3pb95vn87fjtds7vr92r/-S265-FWEBP'),
    (5, 62, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1geeq4o4g51o93b0nhisi0q20q/-S265-FWEBP'),
    (6, 63, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c3b8fuj0tl135beaptrns9fj0i/-S265-FWEBP'),
    (7, 64, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ulcgjsc0op3bpfm680b3nfa212/-S265-FWEBP'),
    (8, 65, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_tt9t61sl2t4pbabpor0bdfrl3a/-S265-FWEBP'),
    (9, 66, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_klm9fupc495237gnokikqfhm7v/-S265-FWEBP'),
    (10, 67, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ae5jo30met1a530u8m87qafl44/-S265-FWEBP'),
    (11, 68, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_g2ntl0soah65v2n1lpg9r6d34j/-S265-FWEBP'),
    (12, 69, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_56r775ak3p0b96ivr08f7p6503/-S265-FWEBP'),
    (13, 70, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_snopbtb0f17i912nmep1t0hl43/-S265-FWEBP'),
    (14, 71, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_on5qvrkljt1nb3003br39e1h3e/-S265-FWEBP'),
    (15, 72, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0bd6ajh5h5563dlenehjnll059/-S265-FWEBP'),
    (16, 73, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qpujeifhut01vds0q1a9crni07/-S265-FWEBP'),
    (17, 74, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3qtnbb7a3d2i557atucpqo4u1d/-S265-FWEBP'),
    (18, 75, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_v3fidvgem939bbilnskrafps55/-S265-FWEBP'),
    (19, 76, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lluj9m9col23hbo3cu9u1l5t7h/-S265-FWEBP'),
    (20, 77, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_sdlch7bq9t5j9f96krdaiitk63/-S265-FWEBP'),
    (21, 78, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5p91bkum597tt9540cmhkvct1p/-S265-FWEBP'),
    (22, 79, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ueou34ajj51grad9hh38mgjg1p/-S265-FWEBP'),
    (23, 80, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rkr8bj122l7u12ucdk1aq0t84h/-S265-FWEBP'),
    (24, 81, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0905j9gk4l7cj594qccmdd0u41/-S265-FWEBP'),
    (25, 82, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_cuu61ukeuh7m99mgm78obal20l/-S265-FWEBP'),
    (26, 83, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8thhisvokl2jh6dipvrs96eh22/-S265-FWEBP'),
    (27, 84, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5in704lhil4njaj2l1g7f23c5g/-S265-FWEBP'),
    (28, 85, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_te34pc77d53h758u8voco1s51s/-S265-FWEBP'),
    (29, 86, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5g0j25tolp2bn7nsfjlhf2sd3d/-S265-FWEBP'),
    (30, 87, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7slbp4a35d0vben3o1pqva456g/-S265-FWEBP'),
    (31, 88, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0qtc2a292d745f6503lnq4qk6g/-S265-FWEBP'),
    (32, 89, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8mlnnp1fbp41309si21sl5bn6v/-S265-FWEBP')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Os Vingadores')
      AND coalesce(serie.volume, 0) = 4
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    referencia.numero::text,
    'Os Vingadores Vol. ' || lpad(referencia.numero::text, 2, '0'),
    referencia.url_capa,
    'PANINI',
    'AMVJW' || lpad(referencia.legado::text, 3, '0'),
    'https://panini.com.br/os-vingadores-' ||
        lpad(referencia.numero::text, 2, '0') || '-' || lpad(referencia.legado::text, 2, '0'),
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

-- Corrige Caçada Sangrenta: X-Men e vincula os números de Os Vingadores V4
-- presentes no guia mutante.
WITH vinculos(posicao, id_externo) AS (VALUES
    (563, 'panini|caçada sangrenta: x-men|1|unica'),
    (546, 'AMVJW066'),
    (547, 'AMVJW069'),
    (548, 'AMVJW070'),
    (564, 'AMVJW071'),
    (565, 'AMVJW072'),
    (566, 'AMVJW073'),
    (575, 'AMVJW074')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON lower(trim(edicao.id_externo)) = lower(vinculo.id_externo)
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
