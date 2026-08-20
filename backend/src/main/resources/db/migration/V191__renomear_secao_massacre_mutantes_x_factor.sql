-- Ajusta o título editorial da etapa sem alterar sua ordem ou seus itens.

UPDATE itens_ordem_leitura item
SET secao = 'Massacre de Mutantes e formação do X-Factor'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.secao = 'Queda dos Mutantes e novas formações';
