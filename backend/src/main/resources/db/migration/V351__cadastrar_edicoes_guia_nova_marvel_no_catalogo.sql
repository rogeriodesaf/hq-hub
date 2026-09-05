-- Transforma as referências editoriais do guia Nova Marvel em edições reais
-- do catálogo. Reutiliza primeiro os cadastros Panini que coincidirem de forma
-- exata e cria somente os títulos ainda ausentes.

WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (
            PARTITION BY item.id
            ORDER BY
                CASE
                    WHEN hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, ''))
                         = hqhub_normalizar_titulo_serie(item.titulo_referencia) THEN 0
                    ELSE 1
                END,
                edicao.id
        ) AS prioridade
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia
      ON guia.id = item.ordem_leitura_id
     AND guia.slug = 'colecao-nova-marvel'
    JOIN edicoes edicao ON TRUE
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE item.edicao_id IS NULL
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND (
          hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, ''))
              = hqhub_normalizar_titulo_serie(item.titulo_referencia)
          OR hqhub_normalizar_titulo_serie(serie.titulo)
              = hqhub_normalizar_titulo_serie(item.titulo_referencia)
      )
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;

WITH faltantes AS (
    SELECT item.posicao, item.titulo_referencia, item.url_capa_referencia
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia
      ON guia.id = item.ordem_leitura_id
     AND guia.slug = 'colecao-nova-marvel'
    WHERE item.edicao_id IS NULL
), editora_panini AS (
    SELECT id
    FROM editoras
    WHERE hqhub_normalizar_titulo_serie(nome) LIKE 'panini%'
    ORDER BY id
    LIMIT 1
)
INSERT INTO series (
    titulo,
    descricao,
    volume,
    tipo_serie,
    fonte_externa,
    id_externo,
    url_origem,
    editora_id,
    data_criacao,
    data_atualizacao
)
SELECT
    faltante.titulo_referencia,
    'Encadernado brasileiro da fase Nova Marvel, publicado pela Panini.',
    1,
    'BRASILEIRA',
    'PLANETA_GIBI',
    'PLANETA-GIBI-NOVA-MARVEL-SERIE-' || lpad(faltante.posicao::text, 3, '0'),
    'https://www.planetagibiblog.com.br/2016/06/guia-planeta-gibi-colecao-nova-marvel.html#more',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM faltantes faltante
CROSS JOIN editora_panini editora
WHERE NOT EXISTS (
    SELECT 1
    FROM series existente
    WHERE existente.editora_id = editora.id
      AND coalesce(existente.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(existente.titulo)
          = hqhub_normalizar_titulo_serie(faltante.titulo_referencia)
);

WITH faltantes AS (
    SELECT item.posicao, item.titulo_referencia, item.url_capa_referencia
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia
      ON guia.id = item.ordem_leitura_id
     AND guia.slug = 'colecao-nova-marvel'
    WHERE item.edicao_id IS NULL
), series_alvo AS (
    SELECT DISTINCT ON (faltante.posicao)
        faltante.posicao,
        faltante.titulo_referencia,
        faltante.url_capa_referencia,
        serie.id AS serie_id
    FROM faltantes faltante
    JOIN series serie
      ON coalesce(serie.volume, 1) = 1
     AND hqhub_normalizar_titulo_serie(serie.titulo)
         = hqhub_normalizar_titulo_serie(faltante.titulo_referencia)
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
    ORDER BY faltante.posicao, serie.id
)
INSERT INTO edicoes (
    numero,
    titulo,
    nome_volume,
    url_capa,
    fonte_externa,
    id_externo,
    url_origem,
    serie_id,
    data_criacao,
    data_atualizacao
)
SELECT
    'UNICA',
    alvo.titulo_referencia,
    alvo.titulo_referencia,
    alvo.url_capa_referencia,
    'PLANETA_GIBI',
    'PLANETA-GIBI-NOVA-MARVEL-EDICAO-' || lpad(alvo.posicao::text, 3, '0'),
    'https://www.planetagibiblog.com.br/2016/06/guia-planeta-gibi-colecao-nova-marvel.html#more',
    alvo.serie_id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM series_alvo alvo
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = alvo.serie_id
      AND hqhub_normalizar_identidade(existente.numero)
          = hqhub_normalizar_identidade('UNICA')
);

WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM itens_ordem_leitura item
    JOIN ordens_leitura guia
      ON guia.id = item.ordem_leitura_id
     AND guia.slug = 'colecao-nova-marvel'
    JOIN series serie
      ON coalesce(serie.volume, 1) = 1
     AND hqhub_normalizar_titulo_serie(serie.titulo)
         = hqhub_normalizar_titulo_serie(item.titulo_referencia)
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND (
         hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, ''))
             = hqhub_normalizar_titulo_serie(item.titulo_referencia)
         OR hqhub_normalizar_identidade(edicao.numero)
             = hqhub_normalizar_identidade('UNICA')
     )
    WHERE item.edicao_id IS NULL
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(item.url_capa_referencia, edicao.url_capa),
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
JOIN edicoes edicao ON edicao.id = candidato.edicao_id
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
