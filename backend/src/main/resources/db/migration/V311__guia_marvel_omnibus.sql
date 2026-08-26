-- Cria a vitrine publica dos titulos brasileiros da linha Marvel Omnibus.
-- Fonte de conferencia: https://www.guiadosquadrinhos.com/titulos/marvel%20omnibus

INSERT INTO ordens_leitura (
    slug, titulo, descricao, publicada, data_criacao, data_atualizacao
)
VALUES (
    'marvel-omnibus',
    'Marvel Omnibus',
    'Titulos da linha Marvel Omnibus publicados no Brasil e cadastrados no HQ-HUB, organizados em ordem alfabetica.',
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (slug) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    publicada = TRUE,
    data_atualizacao = CURRENT_TIMESTAMP;

DELETE FROM itens_ordem_leitura
WHERE ordem_leitura_id = (
    SELECT id FROM ordens_leitura WHERE slug = 'marvel-omnibus'
);

WITH series_omnibus AS (
    SELECT DISTINCT serie.id, serie.titulo
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND (
          hqhub_normalizar_titulo_serie(COALESCE(serie.titulo, '')) LIKE '%omnibus%'
          OR hqhub_normalizar_titulo_serie(COALESCE(serie.descricao, '')) LIKE '%omnibus%'
          OR EXISTS (
              SELECT 1
              FROM edicoes edicao
              WHERE edicao.serie_id = serie.id
                AND (
                    hqhub_normalizar_titulo_serie(COALESCE(edicao.formato, '')) LIKE '%omnibus%'
                    OR hqhub_normalizar_titulo_serie(COALESCE(edicao.titulo, '')) LIKE '%omnibus%'
                    OR hqhub_normalizar_titulo_serie(COALESCE(edicao.descricao, '')) LIKE '%marvel omnibus%'
                    OR lower(COALESCE(edicao.url_origem, '')) LIKE '%omnibus%'
                )
          )
          OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Aniquilacao'),
              hqhub_normalizar_titulo_serie('Aniquilacao: A Conquista'),
              hqhub_normalizar_titulo_serie('Capitao America Por Jack Kirby'),
              hqhub_normalizar_titulo_serie('Classicos X-Men'),
              hqhub_normalizar_titulo_serie('Conan O Barbaro: A Era Marvel')
          )
      )
), representantes AS (
    SELECT
        serie.id AS serie_id,
        serie.titulo AS titulo_serie,
        edicao.id AS edicao_id,
        edicao.url_capa,
        edicao.data_publicacao,
        row_number() OVER (
            PARTITION BY serie.id
            ORDER BY
                CASE WHEN edicao.url_capa IS NOT NULL AND trim(edicao.url_capa) <> '' THEN 0 ELSE 1 END,
                CASE
                    WHEN hqhub_normalizar_identidade(edicao.numero) ~ '^[0-9]+$'
                    THEN hqhub_normalizar_identidade(edicao.numero)::integer
                    ELSE 2147483647
                END,
                edicao.data_publicacao NULLS LAST,
                edicao.id
        ) AS escolha
    FROM series_omnibus serie
    JOIN edicoes edicao ON edicao.serie_id = serie.id
), itens AS (
    SELECT
        representante.*,
        row_number() OVER (
            ORDER BY hqhub_normalizar_titulo_serie(representante.titulo_serie), representante.serie_id
        )::integer AS posicao
    FROM representantes representante
    WHERE representante.escolha = 1
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    guia.id,
    item.posicao,
    'Marvel Omnibus',
    item.edicao_id,
    item.titulo_serie,
    'Panini',
    item.url_capa,
    'CONFIRMADO',
    'Titulo brasileiro da linha Marvel Omnibus.',
    CASE
        WHEN item.data_publicacao IS NOT NULL THEN extract(year FROM item.data_publicacao)::integer
        ELSE NULL
    END
FROM itens item
JOIN ordens_leitura guia ON guia.slug = 'marvel-omnibus';

UPDATE ordens_leitura guia
SET url_capa = primeira.url_capa_referencia,
    data_atualizacao = CURRENT_TIMESTAMP
FROM (
    SELECT item.ordem_leitura_id, item.url_capa_referencia
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'marvel-omnibus'
      AND item.url_capa_referencia IS NOT NULL
      AND trim(item.url_capa_referencia) <> ''
    ORDER BY item.posicao
    LIMIT 1
) primeira
WHERE guia.id = primeira.ordem_leitura_id;
