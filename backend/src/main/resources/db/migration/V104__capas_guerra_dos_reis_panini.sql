-- Capas dos seis volumes de Guerra dos Reis (Panini).
-- Atualiza apenas as edicoes que ja existem; o prologo nao faz parte deste lote.
WITH referencias(numero, url_capa) AS (VALUES
    ('1', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-01.jpg'),
    ('2', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-02.jpg'),
    ('3', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-03.jpg'),
    ('4', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-04.jpg'),
    ('5', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-05.jpg'),
    ('6', 'https://tudohqemanga.com.br/wp-content/uploads/2025/08/Guerra-dos-Reis-06.jpg')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'TUDO_HQ_E_MANGA',
    url_origem = 'https://tudohqemanga.com.br/guerra-dos-reis/',
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(serie.titulo)) IN (
      lower('Guerra dos Reis'),
      lower('A Guerra dos Reis'),
      lower('Guerra dos Reis, A')
  )
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

-- Associa as seis edicoes aos itens correspondentes da ordem mutante.
WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM itens_ordem_leitura item
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) IN (
          lower('Guerra dos Reis'),
          lower('A Guerra dos Reis'),
          lower('Guerra dos Reis, A')
     )
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE lower(trim(item.titulo_referencia)) = lower('Guerra dos Reis')
      AND substring(item.detalhe_referencia FROM '#([0-9]+)') IN ('1', '2', '3', '4', '5', '6')
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
