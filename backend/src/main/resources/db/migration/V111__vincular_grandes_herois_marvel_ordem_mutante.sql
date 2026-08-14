-- Vincula as referências de Grandes Heróis Marvel da Ordem de Leitura
-- Mutante às edições Panini que já possuem capas armazenadas no HQ-HUB.
WITH referencias(titulo_ordem, numero) AS (VALUES
    ('Grandes Heróis Marvel: X-Force — Sexo e Violência', '4'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '6'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '7'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '11'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '12'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '13'),
    ('Grandes Heróis Marvel: Surpreendentes X-Men', '14')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
     AND (
          referencia.numero = '4'
          OR ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = referencia.numero
     )
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Grandes Heróis Marvel')
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
