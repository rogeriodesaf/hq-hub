-- Reúne as leituras de Fabulosos X-Men e Novíssimos X-Men posteriores a AvX.

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), dados(ordem_item, titulo, detalhe, volume) AS (VALUES
    (1, 'Fabulosos X-Men', 'V1', 1),
    (2, 'Os Fabulosos X-Men', 'V2', 2),
    (3, 'Os Fabulosos X-Men - Edição Definitiva', 'V1', 1),
    (4, 'Novíssimos X-Men', 'V1', 1),
    (5, 'X-Men: Chega de Humanos', '#UNICA', 1)
), candidatos AS (
    SELECT dado.ordem_item, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (
               PARTITION BY dado.ordem_item
               ORDER BY CASE WHEN upper(edicao.numero) IN ('UNICA', 'ÚNICA') THEN 0 ELSE 1 END, edicao.id
           ) AS prioridade
    FROM dados dado
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(dado.titulo)
     AND coalesce(serie.volume, 1) = dado.volume
    JOIN edicoes edicao ON edicao.serie_id = serie.id
), base AS (
    SELECT coalesce(max(item.posicao), 0) AS fim
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, secao
)
SELECT ordem.id, base.fim + dado.ordem_item,
       dado.titulo, dado.detalhe,
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       'FABULOSOS X-MEN E NOVÍSSIMOS X-MEN'
FROM ordem CROSS JOIN base CROSS JOIN dados dado
LEFT JOIN candidatos candidato
  ON candidato.ordem_item = dado.ordem_item AND candidato.prioridade = 1;

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('Fabulosos X-Men', 'V1',
     'FABULOSOS X-MEN — Após Vingadores vs. X-Men, Ciclope torna-se um revolucionário, alia-se a Magneto e declara guerra contra os humanos.'),
    ('Novíssimos X-Men', 'V1',
     'NOVÍSSIMOS X-MEN — Vendo a decadência de Ciclope, Fera viaja ao passado e traz os cinco X-Men originais para o futuro, para que confrontem Ciclope e façam o antigo líder se lembrar de seus valores morais.'),
    ('X-Men: A Batalha do Átomo', NULL,
     'A BATALHA DO ÁTOMO — As consequências da viagem no tempo dos cinco X-Men originais fazem uma equipe de X-Men do futuro voltar ao presente para evitar uma catástrofe.'),
    ('X-Men: Chega de Humanos', '#UNICA',
     'CHEGA DE HUMANOS — Inexplicavelmente, os humanos somem do planeta. Os mutantes se unem para tentar trazê-los de volta, mas nem todos querem isso.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia IS NOT DISTINCT FROM descricao.detalhe;

-- Afasta todas as posições para permitir a renumeração sem colisões.
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 100000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante';

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao - 100000 AS posicao_original
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('Marvel Deluxe: Vingadores vs. X-Men')
), referencias(ordem_etapa, titulo, detalhe) AS (VALUES
    (1, 'Fabulosos X-Men', 'V1'),
    (2, 'Fabulosos X-Men: A Queda', '#1'),
    (3, 'Fabulosos X-Men: A Queda', '#2'),
    (4, 'Fabulosos X-Men: Destraçados', NULL),
    (5, 'Fabulosos X-Men: Isto é para sempre', NULL),
    (6, 'Fabulosos X-Men: O Bom, o Mau e o Inumano', NULL),
    (7, 'Fabulosos X-Men: O Mutante Ômega', NULL),
    (8, 'Fabulosos X-Men: Revolução', NULL),
    (9, 'Fabulosos X-Men: Sempre fomos', NULL),
    (10, 'Fabulosos X-Men: Storyville', NULL),
    (11, 'Fabulosos X-Men vs. S.H.I.E.L.D.', NULL),
    (12, 'Os Fabulosos X-Men', 'V2'),
    (13, 'Os Fabulosos X-Men - Edição Definitiva', 'V1'),
    (14, 'Novíssimos X-Men', 'V1'),
    (15, 'Novíssimos X-Men: A Aventura Suprema', NULL),
    (16, 'Novíssimos X-Men: Criando Raízes', NULL),
    (17, 'Novíssimos X-Men: Deslocados', NULL),
    (18, 'Novíssimos X-Men: Os Utopianos', NULL),
    (19, 'Novíssimos X-Men: X-Men de Ontem', NULL),
    (20, 'X-Men: A Batalha do Átomo', NULL),
    (21, 'X-Men: Chega de Humanos', '#UNICA')
), prioridades AS (
    SELECT item.id, referencia.ordem_etapa
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    JOIN referencias referencia
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
     AND item.detalhe_referencia IS NOT DISTINCT FROM referencia.detalhe
), ranqueados AS (
    SELECT item.id,
           row_number() OVER (
               ORDER BY CASE
                   WHEN prioridade.ordem_etapa IS NOT NULL
                       THEN marco.posicao_original + prioridade.ordem_etapa / 100.0
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           prioridade.ordem_etapa
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    LEFT JOIN prioridades prioridade ON prioridade.id = item.id
    CROSS JOIN marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE WHEN ranqueado.ordem_etapa IS NOT NULL
        THEN 'FABULOSOS X-MEN E NOVÍSSIMOS X-MEN'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
