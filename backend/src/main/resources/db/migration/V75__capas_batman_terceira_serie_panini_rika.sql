-- Capas das 58 edicoes regulares de Batman 3a Serie (Panini).
WITH capas(numero, url_capa) AS (
    VALUES
        (1, 'https://rika.vteximg.com.br/arquivos/ids/304487/Batman-3ª-Serie-Panini-1.jpg'),
        (2, 'https://rika.vteximg.com.br/arquivos/ids/304488/Batman-3ª-Serie-Panini-2.jpg'),
        (3, 'https://rika.vteximg.com.br/arquivos/ids/304489/Batman-3ª-Serie-Panini-3.jpg'),
        (4, 'https://rika.vteximg.com.br/arquivos/ids/304490/Batman-3ª-Serie-Panini-4.jpg'),
        (5, 'https://rika.vteximg.com.br/arquivos/ids/304491/Batman-3ª-Serie-Panini-5.jpg'),
        (6, 'https://rika.vteximg.com.br/arquivos/ids/304492/Batman-3ª-Serie-Panini-6.jpg'),
        (7, 'https://rika.vteximg.com.br/arquivos/ids/304493/Batman-3ª-Serie-Panini-7.jpg'),
        (8, 'https://rika.vteximg.com.br/arquivos/ids/304494/Batman-3ª-Serie-Panini-8.jpg'),
        (9, 'https://rika.vteximg.com.br/arquivos/ids/320607/Batman-09.jpg'),
        (10, 'https://rika.vteximg.com.br/arquivos/ids/304496/Batman-3ª-Serie-Panini-10.jpg'),
        (11, 'https://rika.vteximg.com.br/arquivos/ids/320608/Batman-11.jpg'),
        (12, 'https://rika.vteximg.com.br/arquivos/ids/320609/Batman-12.jpg'),
        (13, 'https://rika.vteximg.com.br/arquivos/ids/320610/Batman-13.jpg'),
        (14, 'https://rika.vteximg.com.br/arquivos/ids/320611/Batman-14.jpg'),
        (15, 'https://rika.vteximg.com.br/arquivos/ids/320612/Batman-15.jpg'),
        (16, 'https://rika.vteximg.com.br/arquivos/ids/320972/Batman-3ª-Serie-Panini-16.jpg'),
        (17, 'https://rika.vteximg.com.br/arquivos/ids/320973/Batman-3ª-Serie-Panini-17.jpg'),
        (18, 'https://rika.vteximg.com.br/arquivos/ids/320974/Batman-3ª-Serie-Panini-18.jpg'),
        (19, 'https://rika.vteximg.com.br/arquivos/ids/320975/Batman-3ª-Serie-Panini-19.jpg'),
        (20, 'https://rika.vteximg.com.br/arquivos/ids/320976/Batman-3ª-Serie-Panini-20.jpg'),
        (21, 'https://rika.vteximg.com.br/arquivos/ids/320978/Batman-3ª-Serie-Panini-21.jpg'),
        (22, 'https://rika.vteximg.com.br/arquivos/ids/320979/Batman-3ª-Serie-Panini-22.jpg'),
        (23, 'https://rika.vteximg.com.br/arquivos/ids/320980/Batman-3ª-Serie-Panini-23.jpg'),
        (24, 'https://rika.vteximg.com.br/arquivos/ids/323207/Batman-3serie-24.jpg'),
        (25, 'https://rika.vteximg.com.br/arquivos/ids/418605/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-25.jpg'),
        (26, 'https://rika.vteximg.com.br/arquivos/ids/443244/batman-3-serie-26.jpg'),
        (27, 'https://rika.vteximg.com.br/arquivos/ids/340901/Batman-3ª-Serie-27.jpg'),
        (28, 'https://rika.vteximg.com.br/arquivos/ids/340902/Batman-3ª-Serie-28.jpg'),
        (29, 'https://rika.vteximg.com.br/arquivos/ids/340903/Batman-3ª-Serie-29.jpg'),
        (30, 'https://rika.vteximg.com.br/arquivos/ids/345616/Batman-3-Serie-Panini-30.jpg'),
        (31, 'https://rika.vteximg.com.br/arquivos/ids/345617/Batman-3-Serie-Panini-31.jpg'),
        (32, 'https://rika.vteximg.com.br/arquivos/ids/418693/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-32.jpg'),
        (33, 'https://rika.vteximg.com.br/arquivos/ids/418695/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-33.jpg'),
        (34, 'https://rika.vteximg.com.br/arquivos/ids/418697/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-34.jpg'),
        (35, 'https://rika.vteximg.com.br/arquivos/ids/418699/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-35.jpg'),
        (36, 'https://rika.vteximg.com.br/arquivos/ids/418701/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-36.jpg'),
        (37, 'https://rika.vteximg.com.br/arquivos/ids/406258/Batman-3-Serie-37.jpg'),
        (38, 'https://rika.vteximg.com.br/arquivos/ids/406259/Batman-3-Serie-38.jpg'),
        (39, 'https://rika.vteximg.com.br/arquivos/ids/406260/Batman-3-Serie-39.jpg'),
        (40, 'https://rika.vteximg.com.br/arquivos/ids/406261/Batman-3-Serie-40.jpg'),
        (41, 'https://rika.vteximg.com.br/arquivos/ids/406262/Batman-3-Serie-41.jpg'),
        (42, 'https://rika.vteximg.com.br/arquivos/ids/406263/Batman-3-Serie-42.jpg'),
        (43, 'https://rika.vteximg.com.br/arquivos/ids/406264/Batman-3-Serie-43.jpg'),
        (44, 'https://rika.vteximg.com.br/arquivos/ids/406265/Batman-3-Serie-44.jpg'),
        (45, 'https://rika.vteximg.com.br/arquivos/ids/406266/Batman-3-Serie-45.jpg'),
        (46, 'https://rika.vteximg.com.br/arquivos/ids/406267/Batman-3-Serie-46.jpg'),
        (47, 'https://rika.vteximg.com.br/arquivos/ids/406268/Batman-3-Serie-47.jpg'),
        (48, 'https://rika.vteximg.com.br/arquivos/ids/406269/Batman-3-Serie-48.jpg'),
        (49, 'https://rika.vteximg.com.br/arquivos/ids/418805/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-49.jpg'),
        (50, 'https://rika.vteximg.com.br/arquivos/ids/418807/https---www.artesequencial.com.br-imagens-bruno-batman-3-serie-50.jpg'),
        (51, 'https://rika.vteximg.com.br/arquivos/ids/411246/Batman-3-Serie-51.jpg'),
        (52, 'https://rika.vteximg.com.br/arquivos/ids/445696/batman-3-serie-52.jpg'),
        (53, 'https://rika.vteximg.com.br/arquivos/ids/445697/batman-3-serie-53.jpg'),
        (54, 'https://rika.vteximg.com.br/arquivos/ids/445698/batman-3-serie-54.jpg'),
        (55, 'https://rika.vteximg.com.br/arquivos/ids/445699/batman-3-serie-55.jpg'),
        (56, 'https://rika.vteximg.com.br/arquivos/ids/421811/batman-3-serie-56.jpg'),
        (57, 'https://rika.vteximg.com.br/arquivos/ids/421812/batman-3-serie-57.jpg'),
        (58, 'https://rika.vteximg.com.br/arquivos/ids/421813/batman-3-serie-58.jpg')
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
       (lower(trim(serie.titulo)) = 'batman' AND serie.volume = 3)
       OR regexp_replace(
           translate(
               lower(coalesce(serie.titulo, '')),
               'áàâãäéèêëíìîïóòôõöúùûüçª',
               'aaaaaeeeeiiiiooooouuuuca'),
           '[^a-z0-9]+', '', 'g'
       ) IN ('batman3aserie', 'batmanterceiraserie')
   )
   AND edicao.numero ~ '^0*[0-9]+$'
   AND CAST(edicao.numero AS INTEGER) = capas.numero;
