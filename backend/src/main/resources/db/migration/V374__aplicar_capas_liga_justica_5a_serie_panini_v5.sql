-- Aplica as 13 capas exclusivamente em Liga da Justiça 5ª Série, Panini, V5.
WITH capas(numero, url_capa) AS (VALUES
  ('1', 'https://rika.vteximg.com.br/arquivos/ids/406375/Liga-da-Justica-5-Serie-1.jpg?v=637598293497130000'),
  ('2', 'https://rika.vteximg.com.br/arquivos/ids/406376/Liga-da-Justica-5-Serie-2.jpg?v=637598293507470000'),
  ('3', 'https://rika.vteximg.com.br/arquivos/ids/406377/Liga-da-Justica-5-Serie-3.jpg?v=637598293518270000'),
  ('4', 'https://rika.vteximg.com.br/arquivos/ids/497454/15007648.jpg?v=638882068882570000'),
  ('5', 'https://rika.vteximg.com.br/arquivos/ids/418823/https---www.artesequencial.com.br-imagens-bruno-liga-da-justica-5-serie-05.jpg?v=638006654929570000'),
  ('6', 'https://rika.vteximg.com.br/arquivos/ids/424496/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-06.jpg?v=638165059294100000'),
  ('7', 'https://rika.vteximg.com.br/arquivos/ids/424498/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-07.jpg?v=638165059318230000'),
  ('8', 'https://rika.vteximg.com.br/arquivos/ids/424500/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-08.jpg?v=638165059349900000'),
  ('9', 'https://rika.vteximg.com.br/arquivos/ids/424502/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-09.jpg?v=638165059379030000'),
  ('10', 'https://rika.vteximg.com.br/arquivos/ids/424504/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-10.jpg?v=638165059407700000'),
  ('56', 'https://rika.vteximg.com.br/arquivos/ids/424506/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-56.jpg?v=638165059439330000'),
  ('57', 'https://rika.vteximg.com.br/arquivos/ids/424508/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-57.jpg?v=638165059468070000'),
  ('58', 'https://rika.vteximg.com.br/arquivos/ids/424510/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-5-serie-58.jpg?v=638165059497370000')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa
FROM capas capa
WHERE hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero)
  AND EXISTS (
    SELECT 1
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id = edicao.serie_id
      AND hqhub_normalizar_identidade(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 5
      AND hqhub_normalizar_identidade(serie.titulo) IN (
        hqhub_normalizar_identidade('Liga da Justiça 5ª Série'),
        hqhub_normalizar_identidade('Liga da Justiça - 5ª Série')
      )
  );
