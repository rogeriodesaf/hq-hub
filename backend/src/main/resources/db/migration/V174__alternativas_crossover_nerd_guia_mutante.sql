-- Acrescenta as edicoes brasileiras nomeadas diretamente no guia cronologico
-- do Crossover NERD sem remover as alternativas editoriais ja existentes.
-- Fonte consultada: https://www.crossovernerd.com/guia-de-leitura-cronologica-dos-x-men/

-- Abre cinco posicoes antes da fase Claremont. O deslocamento em duas etapas
-- evita conflitos com a restricao unica (ordem_leitura_id, posicao).
UPDATE itens_ordem_leitura item
SET posicao = posicao + 1000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 17;

UPDATE itens_ordem_leitura item
SET posicao = posicao - 995
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 1017;

WITH ordem AS (
    SELECT id
    FROM ordens_leitura
    WHERE slug = 'ordem-de-leitura-mutante'
), referencias(posicao, titulo, detalhe, observacao, ano) AS (VALUES
    (17, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #1',
        'Alternativa editorial contínua aos itens 1 a 16, indicada pela matéria do Crossover NERD. Não é necessário ler as duas opções.', 2025),
    (18, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #2',
        'Alternativa editorial contínua aos itens 1 a 16, indicada pela matéria do Crossover NERD. Não é necessário ler as duas opções.', 2025),
    (19, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #3',
        'Alternativa editorial contínua aos itens 1 a 16, indicada pela matéria do Crossover NERD. Não é necessário ler as duas opções.', 2025),
    (20, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #4',
        'Alternativa editorial contínua aos itens 1 a 16, indicada pela matéria do Crossover NERD. A ficha foi conferida na edição oficial da Panini.', 2025),
    (21, 'X-Men: Tesouros Ocultos (Omnibus)', 'V1 #UNICA',
        'Leitura complementar situada entre o cancelamento da série clássica e a Segunda Gênese, indicada pela matéria do Crossover NERD.', 2023)
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT
    ordem.id, referencia.posicao, referencia.titulo, referencia.detalhe,
    'PENDENTE_REVISAO', referencia.observacao, referencia.ano,
    'Era clássica e primeiras histórias'
FROM ordem
CROSS JOIN referencias referencia;

WITH candidatos AS (
    SELECT
        item.id AS item_id,
        min(edicao.id) AS edicao_id,
        min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem
      ON ordem.id = item.ordem_leitura_id
     AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND coalesce(serie.volume, 1) = 1
     AND (
          (item.posicao BETWEEN 17 AND 20
           AND hqhub_normalizar_titulo_serie(serie.titulo) =
               hqhub_normalizar_titulo_serie('Os Fabulosos X-Men: Edição Definitiva'))
          OR
          (item.posicao = 21
           AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
               hqhub_normalizar_titulo_serie('X-Men: Tesouros Ocultos'),
               hqhub_normalizar_titulo_serie('X-Men: Tesouros Ocultos (Omnibus)')
           ))
     )
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND (
          (item.posicao BETWEEN 17 AND 20
           AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') =
               (item.posicao - 16)::text)
          OR
          (item.posicao = 21
           AND (upper(trim(edicao.numero)) IN ('UNICA', 'ÚNICA', '1', '01')
                OR edicao.numero IS NULL))
     )
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
WHERE item.id = candidato.item_id;
