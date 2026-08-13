-- Vincula publicacoes que ja existem no catalogo aos itens da ordem mutante.

-- Series com numero explicitamente indicado na ordem.
WITH referencias(titulo_ordem, titulo_catalogo, editora_nome, volume, numero) AS (VALUES
    ('X-Factor Omnibus', 'X-Factor Por Peter David', 'Panini', 1, '1'),
    ('Cable: Sangue & Metal', 'Cable - Sangue & Metal', 'Abril', 1, '1'),
    ('Cable: Sangue & Metal', 'Cable - Sangue & Metal', 'Abril', 1, '2')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
     AND substring(item.detalhe_referencia FROM '#([0-9]+)') = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower(referencia.editora_nome)
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = referencia.volume
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

-- Volumes unicos: exige uma unica edicao na serie para impedir associacao ambigua.
WITH referencias(titulo_ordem, titulo_catalogo, editora_nome, volume) AS (VALUES
    ('Dentes-de-Sabre: Caçada Mortal', 'Dentes-De-Sabre: Caçada Mortal', 'Panini', 1),
    ('Wolverine & Nick Fury: Conexão Scorpio', 'Wolverine & Nick Fury: Conexão Scorpio', 'Panini', 1),
    ('Wolverine & Gambit: Vítimas', 'Wolverine & Gambit: Vítimas', 'Abril', 1),
    ('X-Men: As Aventuras de Ciclope e Fênix', 'X-Men: As Aventuras de Ciclope e Fênix', 'Panini', 1)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower(referencia.editora_nome)
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = referencia.volume
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

-- Exibe na ordem os mesmos nomes canonicos usados no catalogo.
UPDATE itens_ordem_leitura
SET titulo_referencia = CASE titulo_referencia
    WHEN 'X-Factor Omnibus' THEN 'X-Factor Por Peter David'
    WHEN 'Cable: Sangue & Metal' THEN 'Cable - Sangue & Metal'
    WHEN 'Dentes-de-Sabre: Caçada Mortal' THEN 'Dentes-De-Sabre: Caçada Mortal'
    ELSE titulo_referencia
END
WHERE titulo_referencia IN (
    'X-Factor Omnibus',
    'Cable: Sangue & Metal',
    'Dentes-de-Sabre: Caçada Mortal'
);
