-- Capa oficial Mythos de Dragonero & Zagor: Aventura em Darkwood (2025).
UPDATE edicoes edicao
   SET url_capa = 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_dragonero_e_zagor_agosto_2025_1711701_1_ae47c0e324fb3f9166d9f0b9d18e5a77.jpg',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM series serie, editoras editora
 WHERE edicao.serie_id = serie.id
   AND serie.editora_id = editora.id
   AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
       hqhub_normalizar_titulo_serie('Dragonero & Zagor'),
       hqhub_normalizar_titulo_serie('Dragonero e Zagor')
   )
   AND coalesce(serie.volume, 1) = 1
   AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
   AND (
       hqhub_normalizar_identidade(edicao.numero) IN ('1', 'unica')
       OR (SELECT count(*) FROM edicoes existente WHERE existente.serie_id = serie.id) = 1
   );
