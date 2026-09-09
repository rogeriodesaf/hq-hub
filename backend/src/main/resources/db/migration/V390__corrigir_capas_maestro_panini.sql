-- Capas corretas da Panini para Maestro (2021-2022), volume 1.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9786559600472.jpg'),
    ('2', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9786559603770.jpg'),
    ('3', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9786559826063.jpg')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  -- A comparação exata evita atingir o mangá distinto chamado "O Maestro".
  AND lower(btrim(serie.titulo)) = lower('Maestro')
  AND COALESCE(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
