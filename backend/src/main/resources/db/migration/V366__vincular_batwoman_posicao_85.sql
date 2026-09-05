-- Vincula Batwoman por Greg Rucka e J.H. Williams III (ISBN 9788542621693)
-- à entrada correspondente do guia.
WITH ordem_alvo AS (
    SELECT id FROM ordens_leitura WHERE slug = 'batman-ordem-cronologica'
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'Batwoman',
    detalhe_referencia = 'Batwoman por Greg Rucka e J.H. Williams III · Panini · ISBN 9788542621693',
    url_capa_referencia = 'https://rika.vteximg.com.br/arquivos/ids/305935/Batwoman-Elegy-HC-.jpg?v=636659739912000000',
    observacao = 'Edição Panini de 2019, correspondente ao ISBN informado pelo usuário; reúne Detective Comics #854–863.',
    status_identificacao = 'PENDENTE_REVISAO'
FROM ordem_alvo ordem
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 85;

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
          regexp_replace(coalesce(edicao.codigo_barras, ''), '[^0-9]', '', 'g') = '9788542621693'
          OR regexp_replace(coalesce(edicao.codigo_barras, ''), '[^0-9]', '', 'g') = '8542621697'
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) = hqhub_normalizar_titulo_serie('Batwoman por Greg Rucka e J.H. Williams III')
      )
    ORDER BY CASE WHEN regexp_replace(coalesce(edicao.codigo_barras, ''), '[^0-9]', '', 'g') = '9788542621693' THEN 0 ELSE 1 END, edicao.id
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
  AND item.posicao = 85;
