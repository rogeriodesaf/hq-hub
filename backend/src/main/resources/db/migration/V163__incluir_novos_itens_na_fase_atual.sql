-- Inclui na ultima secao os itens acrescentados ao guia depois da lista-base
-- de 600 posicoes, preservando todos os registros existentes.

UPDATE itens_ordem_leitura item
SET secao = 'Fase atual — Doze Destinos e Além das Cinzas'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao > 600;
