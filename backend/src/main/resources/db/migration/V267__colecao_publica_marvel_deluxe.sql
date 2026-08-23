-- Piloto de colecao editorial fechada acessivel como pagina publica compartilhavel.
INSERT INTO ordens_leitura (
    slug, titulo, descricao, publicada, data_criacao, data_atualizacao
)
VALUES (
    'colecao-marvel-deluxe-capa-preta',
    'Marvel Deluxe — Coleção Completa',
    'Coleção brasileira Marvel Deluxe da Panini, conhecida pelas capas pretas. Reúne todas as edições cadastradas no HQ-HUB, organizadas por título e número.',
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
    SELECT id FROM ordens_leitura WHERE slug = 'colecao-marvel-deluxe-capa-preta'
);

WITH edicoes_marvel_deluxe AS (
    SELECT
        edicao.id AS edicao_id,
        serie.titulo AS secao,
        edicao.numero,
        edicao.titulo,
        edicao.nome_volume,
        edicao.url_capa,
        edicao.data_publicacao,
        row_number() OVER (
            ORDER BY
                hqhub_normalizar_titulo_serie(serie.titulo),
                CASE
                    WHEN hqhub_normalizar_identidade(edicao.numero) ~ '^[0-9]+$'
                    THEN hqhub_normalizar_identidade(edicao.numero)::integer
                    ELSE 2147483647
                END,
                hqhub_normalizar_identidade(edicao.numero),
                edicao.id
        )::integer AS posicao
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
      AND serie.id_externo LIKE 'marvel-deluxe-%-panini-v1'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    ordem.id,
    item.posicao,
    item.secao,
    item.edicao_id,
    coalesce(item.titulo, item.secao || ' #' || item.numero),
    coalesce(item.nome_volume, item.secao),
    item.url_capa,
    'CONFIRMADO',
    'Edição da coleção Marvel Deluxe de capa preta publicada pela Panini.',
    CASE
        WHEN item.data_publicacao IS NOT NULL THEN extract(year FROM item.data_publicacao)::integer
        ELSE NULL
    END
FROM edicoes_marvel_deluxe item
JOIN ordens_leitura ordem ON ordem.slug = 'colecao-marvel-deluxe-capa-preta';

UPDATE ordens_leitura ordem
SET url_capa = primeira.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM (
    SELECT item.ordem_leitura_id, edicao.url_capa
    FROM itens_ordem_leitura item
    JOIN edicoes edicao ON edicao.id = item.edicao_id
    JOIN ordens_leitura colecao ON colecao.id = item.ordem_leitura_id
    WHERE colecao.slug = 'colecao-marvel-deluxe-capa-preta'
      AND edicao.url_capa IS NOT NULL
      AND trim(edicao.url_capa) <> ''
    ORDER BY item.posicao
    LIMIT 1
) primeira
WHERE ordem.id = primeira.ordem_leitura_id;
