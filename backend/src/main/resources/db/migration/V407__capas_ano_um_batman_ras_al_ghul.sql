-- Capas das duas edicoes da minisserie Ano Um: Batman/Ra's Al Ghul,
-- publicada pela Panini em 2006.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://rika.vteximg.com.br/arquivos/ids/220307/-herois_panini-batman-ras-ano-um-01.jpg?v=639083367989870000',
         'https://www.rika.com.br/batman---ra-s-al-ghul--0115000486/p'),
        (2,
         'https://rika.vteximg.com.br/arquivos/ids/220308/-herois_panini-batman-ras-ano-um-02.jpg?v=639083368483770000',
         'https://www.rika.com.br/batman---ra-s-al-ghul--0215000487/p')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) LIKE
          hqhub_normalizar_titulo_serie('Ano Um: Batman/Ra''s Al Ghul') || '%'
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'RIKA',
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE
      hqhub_normalizar_titulo_serie('Ano Um: Batman/Ra''s Al Ghul') || '%'
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND edicao.url_capa IS NOT NULL;
