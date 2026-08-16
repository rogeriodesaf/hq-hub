-- Cadastra X-Men: Lendas (Panini), suas nove edicoes e capas, e substitui
-- no guia a referencia generica de Gambit pela edicao 6 da colecao.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Men: Lendas',
    'Colecao brasileira da Panini que revisita eras classicas dos X-Men em historias ineditas.',
    2022,
    2024,
    1,
    'PANINI',
    'PANINI-X-MEN-LENDAS',
    'https://panini.com.br/marvel/universo-x-men?collection=X-MEN+-+LENDAS',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, url_capa, url_origem) AS (VALUES
    (1, 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/3/3/333673_900x900.jpg', 'https://www.comix.com.br/x-men-lendas-vol-01.html'),
    (2, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qgjtr8nrt12cnc2eago7s0c67b/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-2'),
    (3, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gg5mgtvnfl579de14jj8akdm4q/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-3'),
    (4, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vj4artulv119d80eijnbbfd603/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-4'),
    (5, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_tfodk7dcb13dba1bvklt1mni15/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-5'),
    (6, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8rq0c2r9cp5sd6ddmib36sg56i/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-6'),
    (7, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qpgf5nhsct26b2b32ii3k8kf39/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-7'),
    (8, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_t19f0cu2cl0312uoib0ni2h67a/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-8'),
    (9, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8t8k1o9bu50q99l2hn5cpkfo39/-S265-FWEBP', 'https://panini.com.br/x-men-lendas-vol-9')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men: Lendas')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero::text,
    'X-Men: Lendas Vol. ' || capa.numero::text,
    capa.url_capa,
    CASE WHEN capa.numero = 1 THEN 'COMIX' ELSE 'PANINI' END,
    'AXMLE' || lpad(capa.numero::text, 3, '0'),
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH candidato AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men: Lendas')
      AND coalesce(serie.volume, 0) = 1
      AND trim(edicao.numero) = '6'
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'X-Men: Lendas',
    detalhe_referencia = 'V1 #6 - Gambit',
    edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 117;
