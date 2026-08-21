-- Renomeia somente a primeira parte da antiga etapa Massacre e fase dos anos 1990.
-- Os itens posteriores à posição 180 permanecem nela até o próximo remanejamento.

UPDATE itens_ordem_leitura item
SET secao = 'Massacre, Operação Tolerância Zero, X-Men: A Guerra Magnética e X-Men: Amanhecer Violento'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.secao = 'Massacre e fase dos anos 1990'
  AND item.posicao <= 180;
