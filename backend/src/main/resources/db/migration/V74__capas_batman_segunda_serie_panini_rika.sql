-- Capas das 52 edicoes regulares de Batman 2a Serie (Panini).
WITH capas(numero, url_capa) AS (
    VALUES
        (1, 'https://rika.vteximg.com.br/arquivos/ids/221349/-herois_panini-batman-2s-01.jpg'),
        (2, 'https://rika.vteximg.com.br/arquivos/ids/221350/-herois_panini-batman-2s-02.jpg'),
        (3, 'https://rika.vteximg.com.br/arquivos/ids/221351/-herois_panini-batman-2s-03.jpg'),
        (4, 'https://rika.vteximg.com.br/arquivos/ids/221352/-herois_panini-batman-2s-04.jpg'),
        (5, 'https://rika.vteximg.com.br/arquivos/ids/221353/-herois_panini-batman-2s-05.jpg'),
        (6, 'https://rika.vteximg.com.br/arquivos/ids/221354/-herois_panini-batman-2s-06.jpg'),
        (7, 'https://rika.vteximg.com.br/arquivos/ids/221355/-herois_panini-batman-2s-07.jpg'),
        (8, 'https://rika.vteximg.com.br/arquivos/ids/289097/batman-2-serie-008.jpg'),
        (9, 'https://rika.vteximg.com.br/arquivos/ids/221339/-herois_panini-batman-2s-09.jpg'),
        (10, 'https://rika.vteximg.com.br/arquivos/ids/221358/-herois_panini-batman-2s-10.jpg'),
        (11, 'https://rika.vteximg.com.br/arquivos/ids/289146/batman-2-serie-011.jpg'),
        (12, 'https://rika.vteximg.com.br/arquivos/ids/289147/batman-2-serie-012.jpg'),
        (13, 'https://rika.vteximg.com.br/arquivos/ids/404895/Batman-2-Serie-13.jpg'),
        (14, 'https://rika.vteximg.com.br/arquivos/ids/223294/-panini_herois-batman-2s-14.jpg'),
        (15, 'https://rika.vteximg.com.br/arquivos/ids/223295/-panini_herois-batman-2s-15.jpg'),
        (16, 'https://rika.vteximg.com.br/arquivos/ids/223310/-panini_herois-batman-2s-16.jpg'),
        (17, 'https://rika.vteximg.com.br/arquivos/ids/223311/-panini_herois-batman-2s-17.jpg'),
        (18, 'https://rika.vteximg.com.br/arquivos/ids/270814/batman-2s-18.jpg'),
        (19, 'https://rika.vteximg.com.br/arquivos/ids/270815/batman-2s-19.jpg'),
        (20, 'https://rika.vteximg.com.br/arquivos/ids/270816/batman-2s-20.jpg'),
        (21, 'https://rika.vteximg.com.br/arquivos/ids/270817/batman-2s-21.jpg'),
        (22, 'https://rika.vteximg.com.br/arquivos/ids/270818/batman-2s-22.jpg'),
        (23, 'https://rika.vteximg.com.br/arquivos/ids/270819/batman-2s-23.jpg'),
        (24, 'https://rika.vteximg.com.br/arquivos/ids/270828/batman-2s-24.jpg'),
        (25, 'https://rika.vteximg.com.br/arquivos/ids/270829/batman-2s-25.jpg'),
        (26, 'https://rika.vteximg.com.br/arquivos/ids/289148/batman-2-serie-026.jpg'),
        (27, 'https://rika.vteximg.com.br/arquivos/ids/289149/batman-2-serie-027.jpg'),
        (28, 'https://rika.vteximg.com.br/arquivos/ids/289098/batman-2-serie-028.jpg'),
        (29, 'https://rika.vteximg.com.br/arquivos/ids/289099/batman-2-serie-029.jpg'),
        (30, 'https://rika.vteximg.com.br/arquivos/ids/289150/batman-2-serie-030.jpg'),
        (31, 'https://rika.vteximg.com.br/arquivos/ids/289151/batman-2-serie-031.jpg'),
        (32, 'https://rika.vteximg.com.br/arquivos/ids/286171/batman-2-serie-032.jpg'),
        (33, 'https://rika.vteximg.com.br/arquivos/ids/278545/batman-2s-33.jpg'),
        (34, 'https://rika.vteximg.com.br/arquivos/ids/286172/batman-2-serie-034.jpg'),
        (35, 'https://rika.vteximg.com.br/arquivos/ids/278990/batman-2s-35.jpg'),
        (36, 'https://rika.vteximg.com.br/arquivos/ids/278991/batman-2s-36.jpg'),
        (37, 'https://rika.vteximg.com.br/arquivos/ids/278992/batman-2s-37.jpg'),
        (38, 'https://rika.vteximg.com.br/arquivos/ids/404900/Batman-2-Serie-38.jpg'),
        (39, 'https://rika.vteximg.com.br/arquivos/ids/278994/batman-2s-39.jpg'),
        (40, 'https://rika.vteximg.com.br/arquivos/ids/405169/Batman-2-Serie-40.jpg'),
        (41, 'https://rika.vteximg.com.br/arquivos/ids/289152/batman-2-serie-041.jpg'),
        (42, 'https://rika.vteximg.com.br/arquivos/ids/284005/batman-2-serie-42.jpg'),
        (43, 'https://rika.vteximg.com.br/arquivos/ids/284006/batman-2-serie-43-capa-comum.jpg'),
        (44, 'https://rika.vteximg.com.br/arquivos/ids/284008/batman-2-serie-44.jpg'),
        (45, 'https://rika.vteximg.com.br/arquivos/ids/285498/batman-2-serie-panini-45.jpg'),
        (46, 'https://rika.vteximg.com.br/arquivos/ids/285499/batman-2-serie-panini-46.jpg'),
        (47, 'https://rika.vteximg.com.br/arquivos/ids/286173/batman-2-serie-047.jpg'),
        (48, 'https://rika.vteximg.com.br/arquivos/ids/286174/batman-2-serie-048.jpg'),
        (49, 'https://rika.vteximg.com.br/arquivos/ids/445695/batman-2-serie-49.jpg'),
        (50, 'https://rika.vteximg.com.br/arquivos/ids/304483/Batman-2ª-Serie-Panini-50.jpg'),
        (51, 'https://rika.vteximg.com.br/arquivos/ids/304484/Batman-2ª-Serie-Panini-51.jpg'),
        (52, 'https://rika.vteximg.com.br/arquivos/ids/304485/Batman-2ª-Serie-Panini-52.jpg')
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
       (lower(trim(serie.titulo)) = 'batman' AND serie.volume = 2)
       OR regexp_replace(
           translate(
               lower(coalesce(serie.titulo, '')),
               'áàâãäéèêëíìîïóòôõöúùûüçª',
               'aaaaaeeeeiiiiooooouuuuca'),
           '[^a-z0-9]+', '', 'g'
       ) IN ('batman2aserie', 'batmansegundaserie')
   )
   AND edicao.numero ~ '^0*[0-9]+$'
   AND CAST(edicao.numero AS INTEGER) = capas.numero;
