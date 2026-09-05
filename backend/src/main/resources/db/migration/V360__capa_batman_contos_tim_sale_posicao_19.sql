-- Adiciona a capa de Batman: Contos por Tim Sale à posição 19.
-- Mantém título, posição e vínculo do guia inalterados.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = 'https://m.media-amazon.com/images/I/51APXKxQV4L._SL1000_.jpg'
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'batman-ordem-cronologica'
  AND item.posicao = 19
  AND hqhub_normalizar_identidade(item.titulo_referencia) = hqhub_normalizar_identidade('Batman: Contos')
  AND item.edicao_id IS NULL;
