-- Vincula as capas ausentes dos volumes 1 e 4 de Hellboy Omnibus (Mythos, V1).

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Hellboy Omnibus')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'mythos%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY (
        SELECT count(*)
        FROM edicoes edicao
        WHERE edicao.serie_id = serie.id
    ) DESC, serie.id
    LIMIT 1
), capas(numero, url_capa, url_origem) AS (VALUES
    ('1',
     'https://images.tcdn.com.br/img/img_prod/1119494/hellboy_omnibus_vol_1_1710885_1_50dd960d4d9ae896b6fea76fa2f6a141.jpg',
     'https://www.lojamythos.com.br/hq-s/hellboy-omnibus-vol-1'),
    ('4',
     'https://images.tcdn.com.br/img/img_prod/1119494/hellboy_omnibus_vol_4_6479_1_104bee035eecfc0f2ce5ca8272e09b73.jpg',
     'https://www.lojamythos.com.br/hq-s/hellboy-omnibus-vol-4')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'MYTHOS',
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
CROSS JOIN capas capa
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) =
      hqhub_normalizar_identidade(capa.numero);
