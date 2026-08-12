-- Capas conferidas nas páginas da Rika (nº 1) e Comix (nº 2).
UPDATE edicoes edicao
SET url_capa = CASE ltrim(edicao.numero, '0')
        WHEN '1' THEN 'https://rika.vtexassets.com/arquivos/ids/221000/-herois_panini-maiores-classicos-tropa-01.jpg?v=635316191274230000'
        WHEN '2' THEN 'https://www.comix.com.br/media/catalog/product/P/a/Panini_MaioresClas_TropA_02.jpg'
    END,
    url_origem = CASE ltrim(edicao.numero, '0')
        WHEN '1' THEN 'https://www.rika.com.br/maiores-classicos-da-tropa-alfa--0115001187/p'
        WHEN '2' THEN 'https://www.comix.com.br/os-maiores-classicos-da-tropa-alfa-vol-02.html'
    END,
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.id = edicao.serie_id
  AND lower(trim(serie.titulo)) = lower('Os Maiores Clássicos da Tropa Alfa')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(edicao.numero, '0') IN ('1', '2');

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Os Maiores Clássicos da Tropa Alfa')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(edicao.numero, '0') = substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('Os Maiores Clássicos da Tropa Alfa')
      AND item.detalhe_referencia IN ('V1 #1', 'V1 #2')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
