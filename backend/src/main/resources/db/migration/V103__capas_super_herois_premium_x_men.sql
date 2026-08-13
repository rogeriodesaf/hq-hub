-- Capas das 17 edicoes de Super-Herois Premium: X-Men (Abril).
-- A migracao atualiza somente edicoes que ja existem no catalogo.
WITH referencias(numero, url_capa) AS (VALUES
    ('1',  'https://tudohqemanga.com.br/wp-content/uploads/2024/05/super-herois-premium-x-men-01.jpg'),
    ('2',  'https://tudohqemanga.com.br/wp-content/uploads/2024/05/super-herois-premium-x-men-02.jpg'),
    ('3',  'https://tudohqemanga.com.br/wp-content/uploads/2024/05/super-herois-premium-x-men-03.jpg'),
    ('4',  'https://tudohqemanga.com.br/wp-content/uploads/2024/05/super-herois-premium-x-men-04.jpg'),
    ('5',  'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-05.jpg'),
    ('6',  'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-06.jpg'),
    ('7',  'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-07.jpg'),
    ('8',  'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-08.jpg'),
    ('9',  'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-09.jpg'),
    ('10', 'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-10.jpg'),
    ('11', 'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-11.jpg'),
    ('12', 'https://tudohqemanga.com.br/wp-content/uploads/2024/06/super-herois-premium-x-men-12.jpg'),
    ('13', 'https://tudohqemanga.com.br/wp-content/uploads/2024/07/super-herois-premium-x-men-13.jpg'),
    ('14', 'https://tudohqemanga.com.br/wp-content/uploads/2024/07/super-herois-premium-x-men-14.jpg'),
    ('15', 'https://tudohqemanga.com.br/wp-content/uploads/2024/07/super-herois-premium-x-men-15.jpg'),
    ('16', 'https://tudohqemanga.com.br/wp-content/uploads/2024/07/super-herois-premium-x-men-16.jpg'),
    ('17', 'https://tudohqemanga.com.br/wp-content/uploads/2024/07/super-herois-premium-x-men-17.jpg')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'TUDO_HQ_E_MANGA',
    url_origem = 'https://tudohqemanga.com.br/super-herois-premium-x-men-editora-abril/',
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(serie.titulo)) IN (
      lower('Super-Heróis Premium: X-Men'),
      lower('Super-Herois Premium: X-Men'),
      lower('Super Heróis Premium X-Men'),
      lower('Super Herois Premium X-Men'),
      lower('Série Premium - X-Men'),
      lower('Serie Premium - X-Men')
  )
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Abril')
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

-- Vincula as edicoes presentes na ordem cronologica mutante (numeros 1 a 14).
WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM itens_ordem_leitura item
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Abril')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) IN (
          lower('Super-Heróis Premium: X-Men'),
          lower('Super-Herois Premium: X-Men'),
          lower('Super Heróis Premium X-Men'),
          lower('Super Herois Premium X-Men'),
          lower('Série Premium - X-Men'),
          lower('Serie Premium - X-Men')
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('Super-Heróis Premium: X-Men')
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
