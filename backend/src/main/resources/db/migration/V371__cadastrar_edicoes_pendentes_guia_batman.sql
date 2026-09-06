-- Cadastra e vincula as publicações do guia do Batman que ainda não possuem edição no catálogo.
-- O processo é idempotente e reutiliza séries/edições existentes pela identidade normalizada.

WITH editora_padrao AS (
    SELECT id
    FROM editoras
    WHERE hqhub_normalizar_identidade(nome) LIKE 'panini%'
    ORDER BY id
    LIMIT 1
), referencias AS (
    SELECT DISTINCT
        trim(item.titulo_referencia) AS titulo_serie
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'batman-ordem-cronologica'
      AND item.edicao_id IS NULL
      AND nullif(trim(item.titulo_referencia), '') IS NOT NULL
)
INSERT INTO series (
    titulo, descricao, volume, tipo_serie, fonte_externa, editora_id,
    data_criacao, data_atualizacao
)
SELECT
    ref.titulo_serie,
    'Publicação incluída a partir do guia cronológico de leitura do Batman.',
    1,
    'BRASILEIRA',
    'GUIA_BATMAN',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias ref
CROSS JOIN editora_padrao editora
WHERE NOT EXISTS (
    SELECT 1
    FROM series existente
    WHERE existente.editora_id = editora.id
      AND coalesce(existente.volume, 1) = 1
      AND hqhub_normalizar_identidade(existente.titulo)
            = hqhub_normalizar_identidade(ref.titulo_serie)
);

WITH referencias AS (
    SELECT
        item.id AS item_id,
        trim(item.titulo_referencia) AS titulo_serie,
        CASE
            WHEN coalesce(item.detalhe_referencia, '') ~* 'volume[[:space:]]+[0-9]+'
            THEN substring(item.detalhe_referencia FROM '(?i)volume[[:space:]]+([0-9]+)')
            ELSE '1'
        END AS numero_edicao,
        item.url_capa_referencia AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'batman-ordem-cronologica'
      AND item.edicao_id IS NULL
      AND nullif(trim(item.titulo_referencia), '') IS NOT NULL
), series_alvo AS (
    SELECT DISTINCT ON (ref.item_id)
        ref.item_id,
        ref.numero_edicao,
        ref.url_capa,
        serie.id AS serie_id,
        ref.titulo_serie
    FROM referencias ref
    JOIN series serie
      ON hqhub_normalizar_identidade(serie.titulo)
           = hqhub_normalizar_identidade(ref.titulo_serie)
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_identidade(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY ref.item_id, serie.id
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, serie_id,
    data_criacao, data_atualizacao
)
SELECT DISTINCT ON (alvo.serie_id, hqhub_normalizar_identidade(alvo.numero_edicao))
    alvo.numero_edicao,
    alvo.titulo_serie,
    alvo.url_capa,
    'GUIA_BATMAN',
    'guia-batman-' || alvo.item_id,
    alvo.serie_id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM series_alvo alvo
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = alvo.serie_id
      AND hqhub_normalizar_identidade(existente.numero)
            = hqhub_normalizar_identidade(alvo.numero_edicao)
)
ORDER BY alvo.serie_id, hqhub_normalizar_identidade(alvo.numero_edicao), alvo.item_id;

WITH candidatos AS (
    SELECT DISTINCT ON (item.id)
        item.id AS item_id,
        edicao.id AS edicao_id,
        edicao.url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    JOIN series serie
      ON hqhub_normalizar_identidade(serie.titulo)
           = hqhub_normalizar_identidade(item.titulo_referencia)
    JOIN editoras editora ON editora.id = serie.editora_id
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE ordem.slug = 'batman-ordem-cronologica'
      AND item.edicao_id IS NULL
      AND hqhub_normalizar_identidade(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(
          CASE
              WHEN coalesce(item.detalhe_referencia, '') ~* 'volume[[:space:]]+[0-9]+'
              THEN substring(item.detalhe_referencia FROM '(?i)volume[[:space:]]+([0-9]+)')
              ELSE '1'
          END
      )
    ORDER BY item.id, serie.id, edicao.id
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(item.url_capa_referencia, candidato.url_capa),
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
WHERE item.id = candidato.item_id;
