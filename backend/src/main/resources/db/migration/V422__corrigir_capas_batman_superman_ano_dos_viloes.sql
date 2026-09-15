-- Corrige as seis capas de Batman/Superman, Panini, volume 1 (Ano dos Viloes, 2020).
WITH capas(numero, referencia, url_capa, url_origem) AS (
    VALUES
        (1, '9540786258001',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/2/1/219760_900x900batmansuper.jpg',
         'https://www.comix.com.br/batman-superman-n-01.html'),
        (2, '9540786258002',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/b/a/batman_2.jpg',
         'https://www.comix.com.br/batman-superman-n-02.html'),
        (3, '9540786258003',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/b/a/batman.sup.jpg',
         'https://www.comix.com.br/batman-superman-n-03.html'),
        (4, '9540786258004',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/b/a/batman_1_3.jpg',
         'https://www.comix.com.br/batman-superman-n-04.html'),
        (5, '9540786258005',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/s/u/superman5.jpg',
         'https://www.comix.com.br/batman-superman-n-05.html'),
        (6, '540786258006',
         'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/2/4/24batmansuper.jpg',
         'https://www.comix.com.br/batman-superman-n-06.html')
), edicoes_alvo AS (
    SELECT
        edicao.id,
        substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman/Superman'),
              hqhub_normalizar_titulo_serie('Batman / Superman')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.volume, 1) = 1
      AND coalesce(serie.ano_inicio, 2020) = 2020
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'COMIX',
    id_externo = coalesce(edicao.id_externo, capa.referencia),
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
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman/Superman'),
          hqhub_normalizar_titulo_serie('Batman / Superman')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.volume, 1) = 1
  AND coalesce(serie.ano_inicio, 2020) = 2020
  AND edicao.url_capa IS NOT NULL;
