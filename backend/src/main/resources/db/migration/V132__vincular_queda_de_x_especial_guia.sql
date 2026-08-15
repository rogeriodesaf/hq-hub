-- Vincula ao guia mutante as três edições Panini já cadastradas de
-- Queda de X Especial V1.

WITH vinculos(posicao, id_externo) AS (VALUES
    (557, 'panini|queda de x especial|1|1'),
    (558, 'panini|queda de x especial|1|2'),
    (559, 'panini|queda de x especial|1|3')
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
