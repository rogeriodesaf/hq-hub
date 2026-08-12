-- Alguns cadastros antigos representam o primeiro volume como NULL e podem
-- armazenar o numero com zero a esquerda. Trate ambos sem atingir outra serie.
UPDATE edicoes edicao
SET url_capa = CASE ltrim(edicao.numero, '0')
        WHEN '4' THEN 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pc2be4n8s102p9liej746s3m1f/-S897-f.webp'
        WHEN '13' THEN 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vp75tqtogp3udd6nrhq9ie8m0e/-S897-f.webp'
        WHEN '22' THEN 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r60kvol83t2qb6qt4uiorhu367/-S897-f.webp'
    END,
    url_origem = CASE ltrim(edicao.numero, '0')
        WHEN '4' THEN 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-04-x-men-5-divididos-perderemos'
        WHEN '13' THEN 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-13-x-men-quando-titas-colidem'
        WHEN '22' THEN 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-22-x-men-7-o-homem-de-cobalto'
    END,
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.id = edicao.serie_id
  AND lower(trim(serie.titulo)) = lower('Coleção Clássica Marvel: Nova Fase')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(edicao.numero, '0') IN ('4', '13', '22');

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Coleção Clássica Marvel: Nova Fase')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(edicao.numero, '0') = substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE item.edicao_id IS NULL
      AND lower(trim(item.titulo_referencia)) = lower('Coleção Clássica Marvel: Nova Fase')
      AND item.detalhe_referencia IN ('V1 #4', 'V1 #13', 'V1 #22')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
