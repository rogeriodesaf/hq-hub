-- Vincula ao guia mutante as edições Panini de Caçada Sangrenta já existentes
-- no catálogo. Usa os identificadores reais do HQ-HUB para evitar ambiguidades.

WITH vinculos(posicao, id_externo) AS (VALUES
    (562, 'panini|caçada sangrenta|1|1'),
    (568, 'panini|caçada sangrenta: homem-aranha|1|unica'),
    (569, 'panini|caçada sangrenta: filhos da meia-noite|1|unica'),
    (570, 'panini|caçada sangrenta|1|2'),
    (571, 'panini|caçada sangrenta|1|3')
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
