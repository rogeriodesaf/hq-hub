-- Vincula os encadernados Panini V1 da fase de Brian Michael Bendis e dois
-- especiais relacionados às posições já existentes do guia mutante.

WITH vinculos(posicao, titulo_serie) AS (VALUES
    (207, 'Novíssimos X-Men: X-Men de Ontem'),
    (183, 'Wolverine: Logan'),
    (184, 'Magneto: Testamento'),
    (215, 'Fabulosos X-Men: Revolução'),
    (216, 'Novíssimos X-Men: Criando Raízes'),
    (221, 'Novíssimos X-Men: Deslocados'),
    (222, 'Fabulosos X-Men: Destroçados'),
    (223, 'X-Men: A Batalha do Átomo'),
    (233, 'Fabulosos X-Men: O Bom, O Mau e O Inumano'),
    (246, 'Fabulosos X-Men Vs. Shield'),
    (256, 'Novíssimos X-Men: A Aventura Suprema')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (
            PARTITION BY vinculo.posicao
            ORDER BY
                CASE WHEN lower(trim(edicao.numero)) IN ('única', 'unica', '1') THEN 0 ELSE 1 END,
                edicao.id
        ) AS prioridade
    FROM vinculos vinculo
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower(vinculo.titulo_serie)
     AND serie.volume = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = 'panini'
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
