-- Vincula a edição Panini ISBN 978-85-8368-103-1 à posição 98.
WITH ordem_alvo AS (
    SELECT id FROM ordens_leitura WHERE slug = 'batman-ordem-cronologica'
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'Batman e Robin: Cavaleiro das Trevas vs. Cavaleiro Branco',
    detalhe_referencia = 'Batman & Robin: Cavaleiro das Trevas vs. Cavaleiro Branco · Panini · ISBN 9788583681031',
    url_capa_referencia = 'https://rika.vteximg.com.br/arquivos/ids/278571/batman-robin-cavaleiro-das-trevas-vs-cavaleiro-branco.jpg?v=635877218321370000',
    observacao = 'Edição Panini correspondente ao ISBN 9788583681031, indicada pela página da Amazon.',
    status_identificacao = 'PENDENTE_REVISAO'
FROM ordem_alvo ordem
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 98;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa,
           coalesce(extract(year FROM edicao.data_publicacao)::integer,
                    extract(year FROM edicao.data_cobertura)::integer,
                    serie.ano_inicio) AS ano
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND (
          regexp_replace(coalesce(edicao.codigo_barras, ''), '[^0-9]', '', 'g') = '9788583681031'
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) = hqhub_normalizar_titulo_serie('Batman e Robin - Cavaleiro das Trevas Versus Cavaleiro Branco')
      )
    ORDER BY CASE WHEN regexp_replace(coalesce(edicao.codigo_barras, ''), '[^0-9]', '', 'g') = '9788583681031' THEN 0 ELSE 1 END, edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.id,
    url_capa_referencia = coalesce(alvo.url_capa, item.url_capa_referencia),
    status_identificacao = 'CONFIRMADO',
    ano_referencia = alvo.ano
FROM edicao_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 98;
