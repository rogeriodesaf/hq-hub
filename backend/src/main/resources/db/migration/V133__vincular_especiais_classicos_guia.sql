-- Vincula quatro especiais já cadastrados às posições correspondentes do guia
-- mutante e corrige a capa do volume Fênix de Os Anos 2000 com a imagem Panini.

UPDATE edicoes
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_39df0tu4ip6e56t1vb7n34985b/-S265-FWEBP',
    url_origem = 'https://panini.com.br/anos-2000-o-renascimento-da-marvel-vol-07-de-10-fenix',
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE lower(trim(id_externo)) =
      lower('panini|anos 2000, os: o renascimento da marvel|1|7');

WITH vinculos(posicao, id_externo) AS (VALUES
    (132, 'abril|wolverine/cable: coragem e glória|1|unica'),
    (170, 'panini|surpreendentes x-men: edição especial|1|1'),
    (173, 'panini|vingadores - a queda|1|unica'),
    (176, 'panini|anos 2000, os: o renascimento da marvel|1|7')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (
            PARTITION BY vinculo.posicao
            ORDER BY edicao.id
        ) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao
      ON lower(trim(edicao.id_externo)) = lower(vinculo.id_externo)
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
