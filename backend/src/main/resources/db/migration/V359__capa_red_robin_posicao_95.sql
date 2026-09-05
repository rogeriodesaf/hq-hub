-- Adiciona a capa de Red Robin indicada pelo usuário à posição 95.
-- Mantém título, posição e vínculo do guia inalterados.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = 'https://m.media-amazon.com/images/I/91xNVOITppL._SL1500_.jpg'
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'batman-ordem-cronologica'
  AND item.posicao = 95
  AND hqhub_normalizar_identidade(item.titulo_referencia) = hqhub_normalizar_identidade('Robin Vermelho')
  AND item.edicao_id IS NULL;
