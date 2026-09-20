-- Substitui as imagens protegidas contra hotlink do Guia pelas capas da
-- colecao completa de Secret Wars (Guerras Secretas), Abril, volume 1.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-01.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-1/'),
        (2,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-02.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-2/'),
        (3,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-03.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-3/'),
        (4,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-04.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-4/'),
        (5,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-05.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-5/'),
        (6,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-06.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-6/'),
        (7,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-07.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-7/'),
        (8,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-08.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-8/'),
        (9,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-09.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-9/'),
        (10,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-10.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-10/'),
        (11,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-11.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-11/'),
        (12,
         'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/10/guerras-secretas-abril-12.jpg',
         'https://excelsiorcomics.com.br/produto/secret-wars-guerras-secretas-abril-12/')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'EXCELSIOR',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Secret Wars (Guerras Secretas) - Minisserie')
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Abril')
  AND coalesce(serie.volume, 1) = 1
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND edicao.url_capa IS DISTINCT FROM capa.url_capa;
