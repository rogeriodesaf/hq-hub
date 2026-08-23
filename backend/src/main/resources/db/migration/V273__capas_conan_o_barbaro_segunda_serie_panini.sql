-- Cadastra a segunda serie brasileira de Conan, O Barbaro publicada pela Panini,
-- iniciada em 2024 com material da Titan Comics. Capas obtidas da Panini.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan, O Barbaro',
    'Segunda serie de Conan, O Barbaro publicada pela Panini no Brasil, iniciada em 2024 com material da Titan Comics.',
    2,
    'PANINI',
    'conan-o-barbaro-panini-2024',
    'https://panini.com.br/conan-o-barbaro-2024-01',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
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
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_mfbdnpe2t12rnc50f5tdv7611j/-S1200-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nbf0895a3d34145pdr6hqt602f/-S1200-FWEBP'),
    ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_cpju66kvb10freelqlo79qft1e/-S1200-FWEBP'),
    ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_grpafcktjd0l7aubq9ljrcsa2i/-S1200-FWEBP'),
    ('5', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_guhor37v9l72d1io4t20tu0v4m/-S1200-FWEBP'),
    ('6', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gq21ohgj4l07b0preul7jdra51/-S1200-FWEBP'),
    ('7', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ovhcb27n2p37n5ilp1bl8t7a7l/-S1200-FWEBP'),
    ('8', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_hhuh4gpoeh5gv49i8a1l773136/-S1200-FWEBP'),
    ('9', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vemgdskjll5lb92dcdaavafo0a/-S1200-FWEBP'),
    ('10', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_o3bkm169nl4hvbktgvt6oj4s2u/-S1200-FWEBP'),
    ('11', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gr5napnfb52olafai9h983ua71/-S1200-FWEBP'),
    ('12', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ommdh16jf90mh735ch26ee9b6t/-S1200-FWEBP'),
    ('13', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_eu8e02fgdt02v5khp32beu8812/-S1200-FWEBP'),
    ('14', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_noh9tg6v2929f54jbat5sqbv2j/-S1200-FWEBP')
), serie_conan AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'conan-o-barbaro-panini-2024'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Conan, O Barbaro (2024) ' || LPAD(capa.numero, 2, '0'),
    'Volume ' || capa.numero || ' da segunda serie de Conan, O Barbaro publicada pela Panini.',
    'Volume ' || capa.numero,
    capa.url_capa,
    'PANINI',
    'conan-o-barbaro-panini-2024-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_conan serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

