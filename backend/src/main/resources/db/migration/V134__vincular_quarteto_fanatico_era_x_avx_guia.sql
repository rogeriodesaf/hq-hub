-- Vincula quatro especiais já cadastrados às posições correspondentes do guia mutante.

WITH vinculos(posicao, id_externo) AS (VALUES
    (202, 'panini|x-men especial: a era x|1|unica'),
    (205, 'panini|marvel deluxe: vingadores vs. x-men|1|unica'),
    (441, 'panini|x-men + quarteto fantástico|1|unica'),
    (442, 'panini|fanático|1|unica')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
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
