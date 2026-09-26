-- Marvel Essenciais: Homem-Aranha - Aranhaverso (Capa Metalizada),
-- edicao unica Panini de dezembro de 2025.
-- A imagem oficial em portugues usa o caminho minusculo no catalogo da Panini.
UPDATE edicoes edicao
SET url_capa = 'https://panini.com.br/media/catalog/product/a/h/ahoar001.jpg',
    url_origem = 'https://panini.com.br/homem-aranha-aranhaverso-marvel-essenciais',
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE
      hqhub_normalizar_titulo_serie('Panini') || '%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie(
          'Marvel Essenciais: Homem-Aranha - Aranhaverso (Capa Metalizada)')
  AND (edicao.url_capa IS DISTINCT FROM
           'https://panini.com.br/media/catalog/product/a/h/ahoar001.jpg'
       OR edicao.url_origem IS DISTINCT FROM
           'https://panini.com.br/homem-aranha-aranhaverso-marvel-essenciais');
