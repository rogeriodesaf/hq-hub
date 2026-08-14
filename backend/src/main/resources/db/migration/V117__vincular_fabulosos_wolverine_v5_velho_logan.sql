-- Resolve os itens ainda marcados como "Catalogo em revisao" para as fases
-- atuais dos Fabulosos X-Men e Wolverine e para a serie O Velho Logan.
-- Aceita os titulos com ano e a forma invertida usada em alguns cadastros.

WITH referencias(titulo_item, volume_item, numero, grupo) AS (
    SELECT 'Os Fabulosos X-Men', 2, generate_series(11, 12), 'FABULOSOS'
    UNION ALL
    SELECT 'Wolverine', 5, generate_series(1, 12), 'WOLVERINE'
    UNION ALL
    SELECT 'O Velho Logan', 1, generate_series(1, 38), 'VELHO_LOGAN'
), candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (
            PARTITION BY item.id
            ORDER BY
                CASE
                    WHEN lower(trim(serie.titulo)) = lower(referencia.titulo_item)
                     AND serie.volume = referencia.volume_item THEN 0
                    ELSE 1
                END,
                CASE
                    WHEN edicao.url_capa IS NOT NULL AND trim(edicao.url_capa) <> '' THEN 0
                    ELSE 1
                END,
                edicao.id
        ) AS prioridade
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_item)
     AND substring(item.detalhe_referencia FROM 'V([0-9]+)')::integer = referencia.volume_item
     AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND (
          (referencia.grupo = 'FABULOSOS'
           AND lower(trim(serie.titulo)) IN (
               lower('Os Fabulosos X-Men'),
               lower('Fabulosos X-Men, Os'),
               lower('Os Fabulosos X-Men (2025)')
           )
           AND coalesce(serie.volume, 2) IN (1, 2))
       OR (referencia.grupo = 'WOLVERINE'
           AND lower(trim(serie.titulo)) IN (
               lower('Wolverine'),
               lower('Wolverine (2025)')
           )
           AND coalesce(serie.volume, 5) IN (1, 5))
       OR (referencia.grupo = 'VELHO_LOGAN'
           AND lower(trim(serie.titulo)) IN (
               lower('O Velho Logan'),
               lower('Velho Logan, O'),
               lower('Velho Logan')
           )
           AND coalesce(serie.volume, 1) = 1)
     )
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)')::integer = referencia.numero
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
