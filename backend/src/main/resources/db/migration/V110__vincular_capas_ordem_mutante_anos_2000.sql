-- Vincula as referências da Ordem de Leitura Mutante às edições que já
-- possuem capas no catálogo. Os critérios incluem editora, série e número
-- para impedir vínculos acidentais com republicações homônimas.

WITH referencias(titulo_ordem, titulo_catalogo, numero) AS (VALUES
    ('Hulk & Wolverine: Seis Horas', 'Hulk & Wolverine - Seis Horas', '1'),
    ('Hulk & Wolverine: Seis Horas', 'Hulk & Wolverine - Seis Horas', '2'),
    ('Ícones: Homem de Gelo', 'Icones: Homem de Gelo', '1'),
    ('Ícones: Homem de Gelo', 'Icones: Homem de Gelo', '2'),
    ('Ícones: Noturno', 'Ícones: Noturno', '1'),
    ('Ícones: Noturno', 'Ícones: Noturno', '2'),
    ('Vampira', 'Vampira', '1'),
    ('Vampira', 'Vampira', '2'),
    ('Vampira', 'Vampira', '3'),
    ('Vampira', 'Vampira', '4')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
     AND ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
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

WITH referencias(titulo_ordem, titulo_catalogo) AS (VALUES
    ('X-Treme X-Men: Um Novo Início', 'X-Treme X-Men: Um Novo Início (Lendas Marvel)'),
    ('Origem II', 'Origem II')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND upper(trim(edicao.numero)) = 'UNICA'
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

WITH referencias(titulo_ordem, titulo_edicao, numero) AS (VALUES
    ('Coleção Oficial de Graphic Novels Marvel — Wolverine: Origem', 'Wolverine: Origem', '26'),
    ('Coleção Oficial de Graphic Novels Marvel — Dinastia M', 'Dinastia M', '40'),
    ('Coleção Oficial de Graphic Novels Marvel — Dinastia M: O Herdeiro', 'Dinastia M: O Herdeiro', '41')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Salvat')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Coleção Oficial de Graphic Novels Marvel')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero
     AND lower(trim(edicao.titulo)) = lower(referencia.titulo_edicao)
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
