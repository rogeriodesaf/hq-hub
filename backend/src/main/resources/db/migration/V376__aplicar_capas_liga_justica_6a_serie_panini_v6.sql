-- Aplica as capas exclusivamente em Liga da Justiça 6ª Série, Panini, V6.
-- A publicação adicional contabilizada nas fontes é uma capa variante da #1.
WITH capas(numero, url_capa) AS (VALUES
  ('1', 'https://rika.vteximg.com.br/arquivos/ids/517479/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-01.jpg.jpg?v=639211092517900000'),
  ('2', 'https://rika.vteximg.com.br/arquivos/ids/424516/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-02.jpg?v=638165059586670000'),
  ('3', 'https://rika.vteximg.com.br/arquivos/ids/424518/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-03.jpg?v=638165059614230000'),
  ('4', 'https://rika.vteximg.com.br/arquivos/ids/424520/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-04.jpg?v=638165059642270000'),
  ('5', 'https://rika.vteximg.com.br/arquivos/ids/424522/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-05.jpg?v=638165059687670000'),
  ('6', 'https://rika.vteximg.com.br/arquivos/ids/424524/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-06.jpg?v=638165059717230000'),
  ('7', 'https://rika.vteximg.com.br/arquivos/ids/424526/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-07.jpg?v=638165059748330000'),
  ('8', 'https://rika.vteximg.com.br/arquivos/ids/424528/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-08.jpg?v=638165059778000000'),
  ('9', 'https://rika.vteximg.com.br/arquivos/ids/424530/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-09.jpg?v=638165059802430000'),
  ('10', 'https://rika.vteximg.com.br/arquivos/ids/424532/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-10.jpg?v=638165059872800000'),
  ('11', 'https://rika.vteximg.com.br/arquivos/ids/424534/https---www.artesequencial.com.br-imagens-2023-04-liga-da-justica-6-serie-11.jpg?v=638165059899000000')
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
      AND coalesce(serie.volume, 1) = 6
      AND hqhub_normalizar_identidade(serie.titulo) IN (
        hqhub_normalizar_identidade('Liga da Justiça 6ª Série'),
        hqhub_normalizar_identidade('Liga da Justiça - 6ª Série')
      )
  );
