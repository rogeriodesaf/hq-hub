-- Segundo lote de capas brasileiras de Tex publicadas pela Mythos, numeros 371 a 390.
-- Fonte: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('371', 'https://rika.vteximg.com.br/arquivos/ids/157153/-bonelli-tex-371.jpg?v=635312868316830000'),
    ('372', 'https://rika.vteximg.com.br/arquivos/ids/157154/-bonelli-tex-372.jpg?v=635312868332200000'),
    ('373', 'https://rika.vteximg.com.br/arquivos/ids/157155/-bonelli-tex-373.jpg?v=635312868371330000'),
    ('374', 'https://rika.vteximg.com.br/arquivos/ids/157156/-bonelli-tex-374.jpg?v=635312868392130000'),
    ('375', 'https://rika.vteximg.com.br/arquivos/ids/157157/-bonelli-tex-375.jpg?v=635312868416730000'),
    ('376', 'https://rika.vteximg.com.br/arquivos/ids/157158/-bonelli-tex-376.jpg?v=635312868432230000'),
    ('377', 'https://rika.vteximg.com.br/arquivos/ids/157159/-bonelli-tex-377.jpg?v=635312868450530000'),
    ('378', 'https://rika.vteximg.com.br/arquivos/ids/157160/-bonelli-tex-378.jpg?v=635312868475130000'),
    ('379', 'https://rika.vteximg.com.br/arquivos/ids/157161/-bonelli-tex-379.jpg?v=635312868493370000'),
    ('380', 'https://rika.vteximg.com.br/arquivos/ids/157162/-bonelli-tex-380.jpg?v=635312868512130000'),
    ('381', 'https://rika.vteximg.com.br/arquivos/ids/157163/-bonelli-tex-381.jpg?v=635312868547130000'),
    ('382', 'https://rika.vteximg.com.br/arquivos/ids/157164/-bonelli-tex-382.jpg?v=635312868565570000'),
    ('383', 'https://rika.vteximg.com.br/arquivos/ids/157165/-bonelli-tex-383.jpg?v=635312868580030000'),
    ('384', 'https://rika.vteximg.com.br/arquivos/ids/157166/-bonelli-tex-384.jpg?v=635312868601900000'),
    ('385', 'https://rika.vteximg.com.br/arquivos/ids/157167/-bonelli-tex-385.jpg?v=635312868620070000'),
    ('386', 'https://rika.vteximg.com.br/arquivos/ids/157168/-bonelli-tex-386.jpg?v=635312868637170000'),
    ('387', 'https://rika.vteximg.com.br/arquivos/ids/157169/-bonelli-tex-387.jpg?v=635312868657500000'),
    ('388', 'https://rika.vteximg.com.br/arquivos/ids/157170/-bonelli-tex-388.jpg?v=635312868677030000'),
    ('389', 'https://rika.vteximg.com.br/arquivos/ids/157171/-bonelli-tex-389.jpg?v=635312868696930000'),
    ('390', 'https://rika.vteximg.com.br/arquivos/ids/157172/-bonelli-tex-390.jpg?v=635312868719870000')
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
