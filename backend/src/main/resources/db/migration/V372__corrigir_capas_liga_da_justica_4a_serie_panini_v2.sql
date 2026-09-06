-- Corrige exclusivamente Liga da Justiça 4ª Série, Panini, volume 2 (#1 a #22).
WITH capas(numero, url_capa) AS (VALUES
  (1, 'https://rika.vteximg.com.br/arquivos/ids/340914/Liga-da-Justica-4ª-Serie-1.jpg?v=637051776290770000'),
  (2, 'https://rika.vteximg.com.br/arquivos/ids/340915/Liga-da-Justica-4ª-Serie-2.jpg?v=637051776299330000'),
  (3, 'https://rika.vteximg.com.br/arquivos/ids/340916/Liga-da-Justica-4ª-Serie-3.jpg?v=637051776307930000'),
  (4, 'https://rika.vteximg.com.br/arquivos/ids/340917/Liga-da-Justica-4ª-Serie-4.jpg?v=637051776317930000'),
  (5, 'https://rika.vteximg.com.br/arquivos/ids/340918/Liga-da-Justica-4ª-Serie-5.jpg?v=637051776327730000'),
  (6, 'https://rika.vteximg.com.br/arquivos/ids/497452/15006844.jpg?v=638882063958000000'),
  (7, 'https://rika.vteximg.com.br/arquivos/ids/345655/Liga-da-Justica-4-Serie-7.jpg?v=637235311886570000'),
  (8, 'https://rika.vteximg.com.br/arquivos/ids/479320/15007200.jpg?v=638723884819100000'),
  (9, 'https://rika.vteximg.com.br/arquivos/ids/345657/Liga-da-Justica-4-Serie-9.jpg?v=637235311905600000'),
  (10, 'https://rika.vteximg.com.br/arquivos/ids/345658/Liga-da-Justica-4-Serie-10.jpg?v=637235311916000000'),
  (11, 'https://rika.vteximg.com.br/arquivos/ids/345659/Liga-da-Justica-4-Serie-11.jpg?v=637235311925430000'),
  (12, 'https://rika.vteximg.com.br/arquivos/ids/497453/15007204.jpg?v=638882064746130000'),
  (13, 'https://rika.vteximg.com.br/arquivos/ids/418727/https---www.artesequencial.com.br-imagens-bruno-liga-da-justica-4-serie-13.jpg?v=638006653479230000'),
  (14, 'https://rika.vteximg.com.br/arquivos/ids/406366/Liga-da-Justica-4-Serie-14.jpg?v=637598293404430000'),
  (15, 'https://rika.vteximg.com.br/arquivos/ids/406367/Liga-da-Justica-4-Serie-15.jpg?v=637598293415400000'),
  (16, 'https://rika.vteximg.com.br/arquivos/ids/406368/Liga-da-Justica-4-Serie-16.jpg?v=637598293425230000'),
  (17, 'https://rika.vteximg.com.br/arquivos/ids/406369/Liga-da-Justica-4-Serie-17.jpg?v=637598293435100000'),
  (18, 'https://rika.vteximg.com.br/arquivos/ids/406370/Liga-da-Justica-4-Serie-18.jpg?v=637598293445100000'),
  (19, 'https://rika.vteximg.com.br/arquivos/ids/406371/Liga-da-Justica-4-Serie-19.jpg?v=637598293455770000'),
  (20, 'https://rika.vteximg.com.br/arquivos/ids/406372/Liga-da-Justica-4-Serie-20.jpg?v=637598293466330000'),
  (21, 'https://rika.vteximg.com.br/arquivos/ids/406373/Liga-da-Justica-4-Serie-21.jpg?v=637598293476030000'),
  (22, 'https://rika.vteximg.com.br/arquivos/ids/406374/Liga-da-Justica-4-Serie-22.jpg?v=637598293487430000')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa
FROM capas capa
WHERE hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero::text)
  AND EXISTS (
    SELECT 1
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id = edicao.serie_id
      AND hqhub_normalizar_identidade(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 2
      AND hqhub_normalizar_identidade(serie.titulo) IN (
        hqhub_normalizar_identidade('Liga da Justiça 4ª Série'),
        hqhub_normalizar_identidade('Liga da Justiça - 4ª Série')
      )
  );
