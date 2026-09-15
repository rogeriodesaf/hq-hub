-- Capa principal de Batman/Flash: O Boton (capa dura), Panini, 2018.
UPDATE edicoes edicao
SET url_capa = 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/9/3/93346_900x900batmanflashb_toncapa_dura.jpg',
    fonte_externa = 'COMIX',
    id_externo = coalesce(edicao.id_externo, '9788583682776'),
    url_origem = 'https://www.comix.com.br/batman-flash-o-boton-capa-dura.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2018) = 2018
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman/Flash: O Boton'),
      hqhub_normalizar_titulo_serie('Batman/Flash: O Boton (Capa Dura)'),
      hqhub_normalizar_titulo_serie('Batman & Flash: O Boton'),
      hqhub_normalizar_titulo_serie('Batman e Flash: O Boton')
  );

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2018) = 2018
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman/Flash: O Boton'),
      hqhub_normalizar_titulo_serie('Batman/Flash: O Boton (Capa Dura)'),
      hqhub_normalizar_titulo_serie('Batman & Flash: O Boton'),
      hqhub_normalizar_titulo_serie('Batman e Flash: O Boton')
  )
  AND edicao.url_capa IS NOT NULL;
