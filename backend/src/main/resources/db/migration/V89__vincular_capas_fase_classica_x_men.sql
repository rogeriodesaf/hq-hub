-- Vinculos por referência explícita aos títulos cadastrados no HQ-HUB.

-- Os Heróis Mais Poderosos da Marvel: item específico nº 15.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Os Heróis Mais Poderosos da Marvel')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND regexp_replace(edicao.numero, '[^0-9]', '', 'g') = '15'
    WHERE lower(trim(item.titulo_referencia)) = lower('Os Heróis Mais Poderosos da Marvel')
      AND item.detalhe_referencia = 'V1 #15'
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

-- Publicações de volume único: só vincula quando há uma única edição com capa.
WITH referencias(titulo_ordem, titulo_catalogo) AS (VALUES
    ('Marvel Essenciais: X-Men — A Saga da Fênix Negra', 'Marvel Essenciais: X-Men - A Saga da Fênix Negra'),
    ('Os Novos Mutantes: Entre a Luz e a Escuridão', 'Novos Mutantes, Os: Entre A Luz e A Escuridão'),
    ('Os Novos Mutantes: Legião', 'Os Novos Mutantes : Legião'),
    ('X-Men: A Ascensão da Fênix', 'X-Men: A Ascensão da Fênix')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND edicao.url_capa IS NOT NULL
     AND trim(edicao.url_capa) <> ''
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

-- Mantém os nomes apresentados na ordem iguais aos nomes canônicos do catálogo.
UPDATE itens_ordem_leitura
SET titulo_referencia = CASE titulo_referencia
    WHEN 'Marvel Essenciais: X-Men — A Saga da Fênix Negra' THEN 'Marvel Essenciais: X-Men - A Saga da Fênix Negra'
    WHEN 'Os Novos Mutantes: Entre a Luz e a Escuridão' THEN 'Novos Mutantes, Os: Entre A Luz e A Escuridão'
    WHEN 'Os Novos Mutantes: Legião' THEN 'Os Novos Mutantes : Legião'
    ELSE titulo_referencia
END
WHERE titulo_referencia IN (
    'Marvel Essenciais: X-Men — A Saga da Fênix Negra',
    'Os Novos Mutantes: Entre a Luz e a Escuridão',
    'Os Novos Mutantes: Legião'
);
