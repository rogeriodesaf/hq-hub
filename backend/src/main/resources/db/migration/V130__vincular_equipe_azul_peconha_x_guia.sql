-- Vincula ao guia mutante as edições Panini já cadastradas de
-- X-Men: Equipe Azul V1 e Venom/X-Men: Peçonha-X.

WITH vinculos(posicao, id_externo) AS (VALUES
    (417, 'panini|venom/ x-men: peçonha-x|1|1'),
    (418, 'panini|x-men: equipe azul|1|1'),
    (419, 'panini|x-men: equipe azul|1|2')
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
