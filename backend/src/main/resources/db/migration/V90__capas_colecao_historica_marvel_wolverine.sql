-- Capas dos volumes 1 a 5 conferidas no catálogo da Comix.
UPDATE edicoes edicao
SET url_capa = CASE regexp_replace(edicao.numero, '[^0-9]', '', 'g')
        WHEN '1' THEN 'https://www.comix.com.br/media/catalog/product/1/5/152320-CAPANOVA.PANINI.png'
        WHEN '2' THEN 'https://www.comix.com.br/media/catalog/product/w/o/wolvwrine.capa.02.png'
        WHEN '3' THEN 'https://www.comix.com.br/media/catalog/product/C/H/CHM_WOLVERINE_VOL_3_zpsywy1bqhc.jpg'
        WHEN '4' THEN 'https://www.comix.com.br/media/catalog/product/c/o/colhistmarvel_wolverine04_22052017_1_.jpg'
        WHEN '5' THEN 'https://www.comix.com.br/media/catalog/product/1/0/102641_900x900.jpg'
    END,
    url_origem = 'https://www.comix.com.br/colec-o-historica-marvel-wolverine-vol-'
        || regexp_replace(edicao.numero, '[^0-9]', '', 'g') || '.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.id = edicao.serie_id
  AND lower(trim(serie.titulo)) = lower('Coleção Histórica Marvel: Wolverine')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND regexp_replace(edicao.numero, '[^0-9]', '', 'g') IN ('1', '2', '3', '4', '5');

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Coleção Histórica Marvel: Wolverine')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND regexp_replace(edicao.numero, '[^0-9]', '', 'g') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
      AND substring(item.detalhe_referencia FROM '#([0-9]+)') IN ('1', '2', '3', '4', '5')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
