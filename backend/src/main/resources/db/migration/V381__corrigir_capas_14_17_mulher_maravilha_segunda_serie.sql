WITH capas(numero, url_capa) AS (
    VALUES
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/476729/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-14.jpg?v=638700659541100000'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/476735/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-2-serie-17.jpg?v=638700659615630000')
)
UPDATE edicoes e
SET url_capa = c.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas c, series s, editoras p
WHERE e.serie_id = s.id
  AND s.editora_id = p.id
  AND lower(p.nome) LIKE '%panini%'
  AND lower(regexp_replace(s.titulo, '[^[:alnum:]ª]+', ' ', 'g')) LIKE 'mulher maravilha 2ª série%'
  AND regexp_replace(e.numero, '^0+', '') = c.numero;
