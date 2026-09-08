-- Capas da Panini para Espada Selvagem de Conan, A 1ª Série (2019-2020), volume 1.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9788542623567.jpg'),
    ('2', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9788542623574.jpg'),
    ('3', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9788542623581.jpg'),
    ('4', 'https://fl-storage.bookinfometadados.com.br/uploads/book/first_cover/9788542630053.jpg'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/406338/Espada-Selvagem-de-Conan-5.jpg?v=637598293106530000'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/406339/Espada-Selvagem-de-Conan-6.jpg?v=637598293117200000'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/406340/Espada-Selvagem-de-Conan-7.jpg?v=637598293126870000')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Espada Selvagem de Conan, A 1ª Série')
  AND COALESCE(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
