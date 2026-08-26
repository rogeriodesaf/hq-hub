-- Acrescenta os nove titulos Marvel Omnibus ausentes e corrige a capa do
-- primeiro volume de Quarteto Fantastico por Jonathan Hickman.

UPDATE edicoes
SET url_capa = 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/i/m/iminibus.jpg',
    url_origem = 'https://www.comix.com.br/quarteto-fantastico-por-jonathan-hickman-omnibus.html',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE id = (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Quarteto Fantastico por Jonathan Hickman')
      AND COALESCE(serie.volume, 0) = 1
    ORDER BY edicao.id
    LIMIT 1
);

WITH titulos(titulo) AS (
    VALUES
        ('Dinossauro Demonio por Jack Kirby'),
        ('O Espetacular Homem-Aranha Por David Michelinie e Todd McFarlane'),
        ('Homem-Aranha Por David Michelinie e Erik Larsen'),
        ('Os Eternos Por Jack Kirby'),
        ('Rom: A Era Marvel'),
        ('Tropa Alfa Por John Byrne'),
        ('Universo Marvel Por Frank Miller'),
        ('Vingadores Por Kurt Busiek e George Perez'),
        ('X-Taticos')
), series_alvo AS (
    SELECT serie.id, serie.titulo
    FROM titulos titulo
    JOIN series serie
      ON hqhub_normalizar_titulo_serie(serie.titulo) =
         hqhub_normalizar_titulo_serie(titulo.titulo)
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND COALESCE(serie.volume, 0) = 1
), representantes AS (
    SELECT DISTINCT ON (serie.id)
        serie.id AS serie_id,
        serie.titulo AS titulo_serie,
        edicao.id AS edicao_id,
        edicao.url_capa,
        edicao.data_publicacao
    FROM series_alvo serie
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    ORDER BY
        serie.id,
        CASE WHEN edicao.url_capa IS NOT NULL AND trim(edicao.url_capa) <> '' THEN 0 ELSE 1 END,
        CASE
            WHEN hqhub_normalizar_identidade(edicao.numero) ~ '^[0-9]+$'
            THEN hqhub_normalizar_identidade(edicao.numero)::integer
            ELSE 2147483647
        END,
        edicao.data_publicacao NULLS LAST,
        edicao.id
), novos AS (
    SELECT
        representante.*,
        row_number() OVER (
            ORDER BY hqhub_normalizar_titulo_serie(representante.titulo_serie), representante.serie_id
        )::integer AS incremento
    FROM representantes representante
    WHERE NOT EXISTS (
        SELECT 1
        FROM itens_ordem_leitura item
        JOIN ordens_leitura guia ON guia.id = item.ordem_leitura_id
        JOIN edicoes edicao_item ON edicao_item.id = item.edicao_id
        WHERE guia.slug = 'marvel-omnibus'
          AND edicao_item.serie_id = representante.serie_id
    )
), ultima_posicao AS (
    SELECT COALESCE(MAX(item.posicao), 0) AS posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia ON guia.id = item.ordem_leitura_id
    WHERE guia.slug = 'marvel-omnibus'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    guia.id,
    ultima.posicao + novo.incremento,
    'Marvel Omnibus',
    novo.edicao_id,
    novo.titulo_serie,
    'Panini',
    novo.url_capa,
    'CONFIRMADO',
    'Titulo brasileiro da linha Marvel Omnibus.',
    CASE
        WHEN novo.data_publicacao IS NOT NULL THEN extract(year FROM novo.data_publicacao)::integer
        ELSE NULL
    END
FROM novos novo
CROSS JOIN ultima_posicao ultima
JOIN ordens_leitura guia ON guia.slug = 'marvel-omnibus';

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao, series serie, ordens_leitura guia
WHERE item.ordem_leitura_id = guia.id
  AND guia.slug = 'marvel-omnibus'
  AND item.edicao_id = edicao.id
  AND edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Quarteto Fantastico por Jonathan Hickman');

WITH itens AS (
    SELECT
        item.id,
        row_number() OVER (
            ORDER BY hqhub_normalizar_titulo_serie(item.titulo_referencia), item.id
        )::integer AS nova_posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia ON guia.id = item.ordem_leitura_id
    WHERE guia.slug = 'marvel-omnibus'
)
UPDATE itens_ordem_leitura item
SET posicao = 1000 + itens.nova_posicao
FROM itens
WHERE item.id = itens.id;

UPDATE itens_ordem_leitura item
SET posicao = item.posicao - 1000
FROM ordens_leitura guia
WHERE guia.id = item.ordem_leitura_id
  AND guia.slug = 'marvel-omnibus';

UPDATE ordens_leitura
SET descricao = 'Os 33 titulos brasileiros da linha Marvel Omnibus cadastrados no HQ-HUB, organizados em ordem alfabetica.',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE slug = 'marvel-omnibus';
