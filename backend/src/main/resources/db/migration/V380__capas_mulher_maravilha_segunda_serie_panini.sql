-- Mulher-Maravilha 2ª Série (Panini): 17 capas regulares conferidas na Rika.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1','https://rika.vteximg.com.br/arquivos/ids/424406/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-01.jpg?v=638165057905470000'),
    ('2','https://rika.vteximg.com.br/arquivos/ids/424410/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-02.jpg?v=638165057960230000'),
    ('3','https://rika.vteximg.com.br/arquivos/ids/424412/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-03.jpg?v=638165058098170000'),
    ('4','https://rika.vteximg.com.br/arquivos/ids/424414/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-04.jpg?v=638165058123570000'),
    ('5','https://rika.vteximg.com.br/arquivos/ids/424416/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-05.jpg?v=638165058151100000'),
    ('6','https://rika.vteximg.com.br/arquivos/ids/424418/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-06.jpg?v=638165058177300000'),
    ('7','https://rika.vteximg.com.br/arquivos/ids/424420/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-07.jpg?v=638165058204800000'),
    ('8','https://rika.vteximg.com.br/arquivos/ids/424422/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-08.jpg?v=638165058232370000'),
    ('9','https://rika.vteximg.com.br/arquivos/ids/424424/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-09.jpg?v=638165058262770000'),
    ('10','https://rika.vteximg.com.br/arquivos/ids/424426/https---www.artesequencial.com.br-imagens-2023-04-mulher-maravilha-2-serie-10.jpg?v=638165058292100000'),
    ('11','https://rika.vteximg.com.br/arquivos/ids/476723/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-11.jpg?v=638700659464930000'),
    ('12','https://rika.vteximg.com.br/arquivos/ids/476725/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-12.jpg?v=638700659492200000'),
    ('13','https://rika.vteximg.com.br/arquivos/ids/476727/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-13.jpg?v=638700659515800000'),
    ('14','https://rika.vteximg.com.br/arquivos/ids/476729/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-14.jpg?v=638700659541100000'),
    ('15','https://rika.vteximg.com.br/arquivos/ids/476731/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-15.jpg?v=638700659568470000'),
    ('16','https://rika.vteximg.com.br/arquivos/ids/476733/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-16.jpg?v=638700659592370000'),
    ('17','https://rika.vteximg.com.br/arquivos/ids/476735/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-17.jpg?v=638700659615630000')
), serie_alvo AS (
    SELECT s.id
    FROM series s
    JOIN editoras p ON p.id = s.editora_id
    WHERE lower(s.titulo) IN ('mulher-maravilha 2ª série', 'mulher-maravilha 2a série')
      AND lower(p.nome) LIKE '%panini%'
      AND COALESCE(s.volume, 2) = 2
)
UPDATE edicoes e
SET url_capa = c.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas c
WHERE e.serie_id IN (SELECT id FROM serie_alvo)
  AND regexp_replace(e.numero, '^0+', '') = c.numero;
