-- Capas das duas edicoes avulsas usadas na ordem de leitura mutante.
WITH referencias(editora, titulo_catalogo, titulo_edicao, url_capa, url_origem, fonte) AS (VALUES
    ('Abril', 'Wolverine: A Maldição do Milênio', 'Wolverine: A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Abril', 'Wolverine - A Maldição do Milênio', 'Wolverine: A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Abril', 'A Maldição do Milênio', 'Wolverine: A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Panini', 'Wolverine & Destrutor: Fusão', 'Wolverine & Destrutor: Fusão',
     'https://panini.com.br/media/catalog/product/A/W/AWOMV001.jpg',
     'https://panini.com.br/wolverine-e-destrutor-fusao', 'PANINI'),
    ('Panini', 'Wolverine e Destrutor: Fusão', 'Wolverine & Destrutor: Fusão',
     'https://panini.com.br/media/catalog/product/A/W/AWOMV001.jpg',
     'https://panini.com.br/wolverine-e-destrutor-fusao', 'PANINI')
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    '1', referencia.titulo_edicao, referencia.url_capa, referencia.fonte,
    referencia.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM referencias referencia
JOIN editoras editora
  ON lower(trim(editora.nome)) = lower(referencia.editora)
JOIN series serie
  ON serie.editora_id = editora.id
 AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
 AND coalesce(serie.volume, 1) = 1
WHERE NOT EXISTS (
    SELECT 1 FROM edicoes existente WHERE existente.serie_id = serie.id
);

WITH referencias(editora, titulo_catalogo, url_capa, url_origem, fonte) AS (VALUES
    ('Abril', 'Wolverine: A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Abril', 'Wolverine - A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Abril', 'A Maldição do Milênio',
     'https://www.comix.com.br/media/catalog/product/m/a/maldi_ao_1.jpg',
     'https://www.comix.com.br/wolverine-a-maldic-o-do-milenio.html', 'COMIX'),
    ('Panini', 'Wolverine & Destrutor: Fusão',
     'https://panini.com.br/media/catalog/product/A/W/AWOMV001.jpg',
     'https://panini.com.br/wolverine-e-destrutor-fusao', 'PANINI'),
    ('Panini', 'Wolverine e Destrutor: Fusão',
     'https://panini.com.br/media/catalog/product/A/W/AWOMV001.jpg',
     'https://panini.com.br/wolverine-e-destrutor-fusao', 'PANINI')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = referencia.fonte,
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(editora.nome)) = lower(referencia.editora)
  AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
  AND coalesce(serie.volume, 1) = 1;

WITH referencias(titulo_ordem, editora_nome, titulo_catalogo) AS (VALUES
    ('Wolverine: A Maldição do Milênio', 'Abril', 'Wolverine: A Maldição do Milênio'),
    ('Wolverine: A Maldição do Milênio', 'Abril', 'Wolverine - A Maldição do Milênio'),
    ('Wolverine: A Maldição do Milênio', 'Abril', 'A Maldição do Milênio'),
    ('Wolverine & Destrutor: Fusão', 'Panini', 'Wolverine & Destrutor: Fusão'),
    ('Wolverine & Destrutor: Fusão', 'Panini', 'Wolverine e Destrutor: Fusão')
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
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    GROUP BY item.id
    HAVING count(DISTINCT edicao.id) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
