-- Atualiza as quatro edições de Doutor Estranho V5 com capas oficiais da Panini
-- e vincula ao guia mutante a edição #4, presente na ordem de leitura.

WITH referencias(numero, id_externo, url_capa, url_origem) AS (VALUES
    ('1', 'panini|doutor estranho|5|1',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0op32vcijh0ht4rtplc7pijc4e/-S265-FWEBP',
     'https://panini.com.br/doutor-estranho-2024-01'),
    ('2', 'panini|doutor estranho|5|2',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c599e3pjo11l567qmite17lv3c/-S265-FWEBP',
     'https://panini.com.br/doutor-estranho-2024-02'),
    ('3', 'panini|doutor estranho|5|3',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pe7eush4ll55v351fh2o856c2u/-S265-FWEBP',
     'https://panini.com.br/doutor-estranho-2024-03'),
    ('4', 'panini|doutor estranho|5|4',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_4li8b56aat4u9549unmv4vl44c/-S265-FWEBP',
     'https://panini.com.br/doutor-estranho-2024-04')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    url_origem = referencia.url_origem,
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia
WHERE lower(trim(edicao.id_externo)) = lower(referencia.id_externo);

WITH candidato AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa
    FROM edicoes edicao
    WHERE lower(trim(edicao.id_externo)) = lower('panini|doutor estranho|5|4')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 567;
