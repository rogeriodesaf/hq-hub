-- Capas das 25 edicoes regulares de Batman 5a Serie (Panini).
WITH capas(numero, url_capa) AS (
    VALUES
        (1, 'https://rika.vteximg.com.br/arquivos/ids/453754/batman-5-serie-01.jpg'),
        (2, 'https://rika.vteximg.com.br/arquivos/ids/453755/batman-5-serie-02.jpg'),
        (3, 'https://rika.vteximg.com.br/arquivos/ids/476587/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-03.jpg'),
        (4, 'https://rika.vteximg.com.br/arquivos/ids/476589/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-04.jpg'),
        (5, 'https://rika.vteximg.com.br/arquivos/ids/476591/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-05.jpg'),
        (6, 'https://rika.vteximg.com.br/arquivos/ids/476593/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-06.jpg'),
        (7, 'https://rika.vteximg.com.br/arquivos/ids/476595/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-07.jpg'),
        (8, 'https://rika.vteximg.com.br/arquivos/ids/476597/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-08.jpg'),
        (9, 'https://rika.vteximg.com.br/arquivos/ids/476599/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-09.jpg'),
        (10, 'https://rika.vteximg.com.br/arquivos/ids/476601/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-10.jpg'),
        (11, 'https://rika.vteximg.com.br/arquivos/ids/476603/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-11.jpg'),
        (12, 'https://rika.vteximg.com.br/arquivos/ids/476866/batman-5-serie-12.jpg'),
        (13, 'https://rika.vteximg.com.br/arquivos/ids/476607/https---www.artesequencial.com.br-imagens-bruno-batman-5-serie-13.jpg'),
        (14, 'https://rika.vteximg.com.br/arquivos/ids/479338/15010003.jpg'),
        (15, 'https://rika.vteximg.com.br/arquivos/ids/484499/https---www.artesequencial.com.br-imagens-sku-15010147.jpg'),
        (16, 'https://rika.vteximg.com.br/arquivos/ids/484501/https---www.artesequencial.com.br-imagens-sku-15010148.jpg'),
        (17, 'https://rika.vteximg.com.br/arquivos/ids/484503/https---www.artesequencial.com.br-imagens-sku-15010149.jpg'),
        (18, 'https://rika.vteximg.com.br/arquivos/ids/484505/https---www.artesequencial.com.br-imagens-sku-15010150.jpg'),
        (19, 'https://rika.vteximg.com.br/arquivos/ids/484507/https---www.artesequencial.com.br-imagens-sku-15010151.jpg'),
        (20, 'https://rika.vteximg.com.br/arquivos/ids/494859/15010152.jpg'),
        (21, 'https://rika.vteximg.com.br/arquivos/ids/494860/15010153.jpg'),
        (22, 'https://rika.vteximg.com.br/arquivos/ids/494861/15010154.jpg'),
        (23, 'https://rika.vteximg.com.br/arquivos/ids/494862/15010155.jpg'),
        (24, 'https://rika.vteximg.com.br/arquivos/ids/494863/15010156.jpg'),
        (25, 'https://rika.vteximg.com.br/arquivos/ids/494864/15010157.jpg')
)
UPDATE edicoes edicao
   SET url_capa = capas.url_capa,
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas,
       series serie,
       editoras editora
 WHERE edicao.serie_id = serie.id
   AND serie.editora_id = editora.id
   AND lower(trim(editora.nome)) = 'panini'
   AND (
       (lower(trim(serie.titulo)) = 'batman' AND serie.volume = 5)
       OR regexp_replace(
           translate(
               lower(coalesce(serie.titulo, '')),
               'áàâãäéèêëíìîïóòôõöúùûüçª',
               'aaaaaeeeeiiiiooooouuuuca'),
           '[^a-z0-9]+', '', 'g'
       ) IN ('batman5aserie', 'batmanquintaserie')
   )
   AND edicao.numero ~ '^0*[0-9]+$'
   AND CAST(edicao.numero AS INTEGER) = capas.numero;
