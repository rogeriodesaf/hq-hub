-- Define a capa para a posição 116 do guia do Batman.
-- A obra O Cavaleiro das Trevas é de Frank Miller; Alan Moore é o autor de A Piada Mortal.
-- Mantém o título/posição do guia e altera somente a referência visual.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = 'https://rika.vteximg.com.br/arquivos/ids/237721/-herois_abril_etc-batman-cav-trevas-enc.jpg?v=635316673304430000'
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'batman-ordem-cronologica'
  AND item.posicao = 116
  AND hqhub_normalizar_identidade(item.titulo_referencia) = hqhub_normalizar_identidade('Batman — Cavaleiro das Trevas')
  AND item.edicao_id IS NULL;
