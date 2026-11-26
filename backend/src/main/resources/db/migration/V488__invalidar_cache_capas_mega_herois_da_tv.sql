-- Invalida caches de navegador/CDN das capas substituidas pelos scans do Mega.
-- O parametro nao altera o arquivo servido; apenas garante uma URL nova.

UPDATE edicoes
   SET url_capa = CASE hqhub_normalizar_identidade(numero)
       WHEN '1'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/001.jpg?versao=mega-20261126'
       WHEN '2'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/002.jpg?versao=mega-20261126'
       WHEN '3'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/003.jpg?versao=mega-20261126'
       WHEN '4'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/004.jpg?versao=mega-20261126'
       WHEN '5'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/005.jpg?versao=mega-20261126'
       WHEN '6'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/006.jpg?versao=mega-20261126'
       WHEN '8'  THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/008.jpg?versao=mega-20261126'
       WHEN '12' THEN 'https://hqhub-backend.onrender.com/api/capas/herois-da-tv-2-serie/012.jpg?versao=mega-20261126'
       ELSE url_capa
       END,
       data_atualizacao = CURRENT_TIMESTAMP
 WHERE serie_id = 5014
   AND hqhub_normalizar_identidade(numero) IN
       ('1', '2', '3', '4', '5', '6', '8', '12');

UPDATE itens_ordem_leitura item
   SET url_capa_referencia = e.url_capa
  FROM edicoes e
 WHERE item.edicao_id = e.id
   AND e.serie_id = 5014
   AND hqhub_normalizar_identidade(e.numero) IN
       ('1', '2', '3', '4', '5', '6', '8', '12');
