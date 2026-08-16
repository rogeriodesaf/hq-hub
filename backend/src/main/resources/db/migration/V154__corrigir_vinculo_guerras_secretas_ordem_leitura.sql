-- Corrige o vínculo de Guerras Secretas quando o volume do catálogo não está
-- preenchido como 2. Prioriza V2, mas aceita a edição Panini numerada com capa.

WITH itens_alvo AS (
    SELECT item.id,
           substring(item.detalhe_referencia FROM '#([0-9]+)')::integer AS numero
    FROM itens_ordem_leitura item
    WHERE lower(trim(item.titulo_referencia)) = lower('Guerras Secretas')
      AND item.detalhe_referencia ~* '^V2 #[1-9]$'
), candidatos AS (
    SELECT alvo.id AS item_id,
           edicao.id AS edicao_id,
           row_number() OVER (
               PARTITION BY alvo.id
               ORDER BY CASE WHEN serie.volume = 2 THEN 0 ELSE 1 END,
                        serie.id,
                        edicao.id
           ) AS prioridade
    FROM itens_alvo alvo
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Guerras Secretas')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)')::integer = alvo.numero
     AND edicao.url_capa IS NOT NULL
     AND trim(edicao.url_capa) <> ''
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
