-- Usa o primeiro grupo numérico para aceitar "5", "05", "Vol. 5" e "5 (de 8)".
UPDATE edicoes edicao
SET url_capa = 'https://www.comix.com.br/media/catalog/product/1/0/102641_900x900.jpg',
    url_origem = 'https://www.comix.com.br/colec-o-historica-marvel-wolverine-vol-5.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.id = edicao.serie_id
  AND lower(trim(serie.titulo)) = lower('Coleção Histórica Marvel: Wolverine')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '5';

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
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '5'
    WHERE lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
      AND item.detalhe_referencia = 'V1 #5'
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
