-- Capas da colecao brasileira Excalibur, publicada pela Panini em quatro volumes.
-- As imagens foram conferidas nas paginas de produto da Comix.
WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
    ('1', 'Excalibur Vol. 1',
     'https://www.comix.com.br/media/catalog/product/p/a/panini_excalibur.jpg',
     'https://www.comix.com.br/excalibur-panini.html'),
    ('2', 'Excalibur: A Espada de Dois Gumes',
     'https://www.comix.com.br/media/catalog/product/e/x/excalibur-2-300x460.jpg',
     'https://www.comix.com.br/excalibur-a-espada-de-dois-gumes.html'),
    ('3', 'Excalibur: Uma Viagem no Tempo Vol. 1',
     'https://www.comix.com.br/media/catalog/product/E/x/Excalibur-Uma-Viagem-no-Tempo-1_1.jpg',
     'https://www.comix.com.br/excalibur-uma-viagem-no-tempo-vol-1.html'),
    ('4', 'Excalibur: Uma Aventura no Tempo Vol. 2',
     'https://www.comix.com.br/media/catalog/product/9/0/90072_900x900.jpg',
     'https://www.comix.com.br/excalibur-uma-aventura-no-tempo-vol-2.html')
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    referencia.numero,
    referencia.titulo,
    referencia.url_capa,
    'COMIX',
    referencia.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
JOIN series serie
  ON lower(trim(serie.titulo)) = lower('Excalibur')
 AND coalesce(serie.volume, 1) = 1
JOIN editoras editora
  ON editora.id = serie.editora_id
 AND lower(trim(editora.nome)) = lower('Panini')
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = referencia.numero
);

WITH referencias(numero, url_capa, url_origem) AS (VALUES
    ('1',
     'https://www.comix.com.br/media/catalog/product/p/a/panini_excalibur.jpg',
     'https://www.comix.com.br/excalibur-panini.html'),
    ('2',
     'https://www.comix.com.br/media/catalog/product/e/x/excalibur-2-300x460.jpg',
     'https://www.comix.com.br/excalibur-a-espada-de-dois-gumes.html'),
    ('3',
     'https://www.comix.com.br/media/catalog/product/E/x/Excalibur-Uma-Viagem-no-Tempo-1_1.jpg',
     'https://www.comix.com.br/excalibur-uma-viagem-no-tempo-vol-1.html'),
    ('4',
     'https://www.comix.com.br/media/catalog/product/9/0/90072_900x900.jpg',
     'https://www.comix.com.br/excalibur-uma-aventura-no-tempo-vol-2.html')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'COMIX',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(serie.titulo)) = lower('Excalibur')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Excalibur')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('Excalibur')
      AND substring(item.detalhe_referencia FROM '#([0-9]+)') IN ('1', '2', '3', '4')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
