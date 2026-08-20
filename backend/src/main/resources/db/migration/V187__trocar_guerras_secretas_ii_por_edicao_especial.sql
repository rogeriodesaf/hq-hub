-- Substitui, na posição solicitada, o omnibus Guerras Secretas II pela edição
-- especial da Panini já cadastrada no catálogo.

UPDATE itens_ordem_leitura item
SET titulo_referencia = 'Guerras Secretas - Edição Especial',
    detalhe_referencia = 'V1',
    edicao_id = NULL,
    url_capa_referencia = NULL,
    status_identificacao = 'PENDENTE_REVISAO',
    observacao = E'GUERRAS SECRETAS\nEdição especial da Panini posicionada antes das Guerras Asgardianas nesta cronologia.'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao = 51
  AND lower(trim(item.titulo_referencia)) = lower('Guerras Secretas II');

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id,
           min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem
      ON ordem.id = item.ordem_leitura_id
     AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) =
         hqhub_normalizar_titulo_serie('Guerras Secretas - Edição Especial')
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE item.posicao = 51
      AND lower(trim(item.titulo_referencia)) = lower('Guerras Secretas - Edição Especial')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
WHERE item.id = candidato.item_id;
