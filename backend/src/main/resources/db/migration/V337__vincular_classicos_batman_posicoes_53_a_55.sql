-- Vincula as edições Panini V1 às posições 53 a 55 do guia do Batman.

WITH referencias(posicao, titulo) AS (VALUES
    (53, 'Batman - Asilo Arkham'),
    (54, 'Batman: Um Cavaleiro das Trevas'),
    (55, 'Batman: Guerra ao Crime')
), alvos AS (
    SELECT DISTINCT ON (referencia.posicao)
        referencia.posicao,
        referencia.titulo,
        edicao.id,
        edicao.url_capa,
        coalesce(extract(year FROM edicao.data_publicacao)::integer,
                 extract(year FROM edicao.data_cobertura)::integer,
                 serie.ano_inicio) AS ano
    FROM referencias referencia
    JOIN edicoes edicao ON TRUE
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND (
          hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(referencia.titulo)
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) = hqhub_normalizar_titulo_serie(referencia.titulo)
      )
    ORDER BY referencia.posicao, edicao.id
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    titulo_referencia = alvo.titulo,
    detalhe_referencia = 'Panini · V1',
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a ' || alvo.titulo || ', Panini, V1.',
    ano_referencia = alvo.ano
FROM alvos alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = alvo.posicao;
