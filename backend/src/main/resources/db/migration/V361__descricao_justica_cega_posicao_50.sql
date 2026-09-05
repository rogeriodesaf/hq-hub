-- Acrescenta a história identificada na descrição da posição 50.
-- Mantém o vínculo com A Saga do Batman, Panini V1, edição 12.
UPDATE itens_ordem_leitura item
SET detalhe_referencia = 'Batman: Justiça Cega · Panini · V1 · Edição 12'
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'batman-ordem-cronologica'
  AND item.posicao = 50
  AND hqhub_normalizar_identidade(item.titulo_referencia) = hqhub_normalizar_identidade('A Saga do Batman')
  AND item.edicao_id IS NOT NULL;
