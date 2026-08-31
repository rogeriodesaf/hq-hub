-- Vincula a edição Panini V1 de Batman: As Dez Noites da Besta e Outras
-- Histórias à posição 46 do guia cronológico do Batman.

WITH edicao_alvo AS (
    SELECT
        edicao.id,
        edicao.url_capa,
        coalesce(
            extract(year FROM edicao.data_publicacao)::integer,
            extract(year FROM edicao.data_cobertura)::integer,
            serie.ano_inicio
        ) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND (
          hqhub_normalizar_titulo_serie(serie.titulo)
              = hqhub_normalizar_titulo_serie('Batman: As Dez Noites da Besta e Outras Histórias')
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, ''))
              = hqhub_normalizar_titulo_serie('Batman: As Dez Noites da Besta e Outras Histórias')
      )
    ORDER BY
        CASE
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1') THEN 0
            WHEN hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA') THEN 1
            ELSE 2
        END,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    titulo_referencia = 'Batman: As Dez Noites da Besta e Outras Histórias',
    detalhe_referencia = 'Panini · V1',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a Batman: As Dez Noites da Besta e Outras Histórias, Panini, V1.',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 46;
