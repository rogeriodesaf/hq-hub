-- Corrige o total da coleção brasileira da Salvat: são 95 edições, não 90.

UPDATE series serie
SET descricao = regexp_replace(serie.descricao, '\m90\M', '95', 'g'),
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'salvat%'
  AND coalesce(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Coleção Oficial de Graphic Novels Marvel'),
      hqhub_normalizar_titulo_serie('A Coleção Oficial de Graphic Novels Marvel'),
      hqhub_normalizar_titulo_serie('Coleção Oficial de Graphic Novels Marvel, A')
  )
  AND serie.descricao ~ '\m90\M';
