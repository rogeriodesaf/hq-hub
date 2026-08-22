-- Primeiro lote de capas brasileiras de Tex publicadas pela Mythos, numeros 351 a 370.
-- Fonte: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('351', 'https://rika.vteximg.com.br/arquivos/ids/157133/-bonelli-tex-351.jpg?v=635312867854570000'),
    ('352', 'https://rika.vteximg.com.br/arquivos/ids/157134/-bonelli-tex-352.jpg?v=635312867875800000'),
    ('353', 'https://rika.vteximg.com.br/arquivos/ids/157135/-bonelli-tex-353.jpg?v=635312867891100000'),
    ('354', 'https://rika.vteximg.com.br/arquivos/ids/157136/-bonelli-tex-354.jpg?v=635312867911200000'),
    ('355', 'https://rika.vteximg.com.br/arquivos/ids/157137/-bonelli-tex-355.jpg?v=635312867932000000'),
    ('356', 'https://rika.vteximg.com.br/arquivos/ids/157138/-bonelli-tex-356.jpg?v=635312867953570000'),
    ('357', 'https://rika.vteximg.com.br/arquivos/ids/157139/-bonelli-tex-357.jpg?v=635312867973630000'),
    ('358', 'https://rika.vteximg.com.br/arquivos/ids/157140/-bonelli-tex-358.jpg?v=635312867988430000'),
    ('359', 'https://rika.vteximg.com.br/arquivos/ids/157141/-bonelli-tex-359.jpg?v=635312868007330000'),
    ('360', 'https://rika.vteximg.com.br/arquivos/ids/157142/-bonelli-tex-360.jpg?v=635312868026500000'),
    ('361', 'https://rika.vteximg.com.br/arquivos/ids/157143/-bonelli-tex-361.jpg?v=635312868045270000'),
    ('362', 'https://rika.vteximg.com.br/arquivos/ids/157144/-bonelli-tex-362.jpg?v=635312868076070000'),
    ('363', 'https://rika.vteximg.com.br/arquivos/ids/157145/-bonelli-tex-363.jpg?v=635312868094300000'),
    ('364', 'https://rika.vteximg.com.br/arquivos/ids/157146/-bonelli-tex-364.jpg?v=635312868113400000'),
    ('365', 'https://rika.vteximg.com.br/arquivos/ids/157147/-bonelli-tex-365.jpg?v=635312868135130000'),
    ('366', 'https://rika.vteximg.com.br/arquivos/ids/157148/-bonelli-tex-366.jpg?v=635312868153430000'),
    ('367', 'https://rika.vteximg.com.br/arquivos/ids/157149/-bonelli-tex-367.jpg?v=635312868206900000'),
    ('368', 'https://rika.vteximg.com.br/arquivos/ids/157150/-bonelli-tex-368.jpg?v=635312868256130000'),
    ('369', 'https://rika.vteximg.com.br/arquivos/ids/157151/-bonelli-tex-369.jpg?v=635312868274370000'),
    ('370', 'https://rika.vteximg.com.br/arquivos/ids/157152/-bonelli-tex-370.jpg?v=635312868296500000')
), alvos AS (
    SELECT edicao.id, capas.url_capa
    FROM capas
    JOIN editoras editora
      ON hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Mythos'),
          hqhub_normalizar_titulo_serie('Mythos Editora')
      )
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') = capas.numero
)
UPDATE edicoes edicao
SET url_capa = alvo.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM alvos alvo
WHERE edicao.id = alvo.id;
