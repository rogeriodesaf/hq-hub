-- Corrige os marcos narrativos da fase de Claremont e posiciona Guerras
-- Secretas II antes das Guerras Asgardianas.

WITH marco AS (
    SELECT item.posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #11'
)
UPDATE itens_ordem_leitura item SET posicao = item.posicao + 1000
FROM ordens_leitura ordem, marco
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.posicao;

UPDATE itens_ordem_leitura item SET posicao = item.posicao - 998
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 1000;

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao - 2 AS posicao
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #11'
), novos(posicao, titulo, detalhe, observacao, ano) AS (VALUES
    (0, 'Guerras Secretas II', NULL,
     E'IMPORTANTE PARA A CRONOLOGIA MUTANTE\nEste evento acontece antes das Guerras Asgardianas e influencia os Novos Mutantes, especialmente a trajetória de Cristal. Reúne Secret Wars II 1-9.', 2026),
    (1, 'X-Men: Guerras Asgardianas', 'V1',
     E'OUTRA OPÇÃO PARA AS GUERRAS ASGARDIANAS\nReúne X-Men and Alpha Flight 1-2, New Mutants Special Edition 1 e X-Men Annual 9. As duas últimas histórias também aparecem em A Saga dos X-Men vol. 11; X-Men and Alpha Flight 1-2 não está nesse volume.', 2021)
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT ordem.id, marco.posicao + novo.posicao, novo.titulo, novo.detalhe,
       'PENDENTE_REVISAO', novo.observacao, novo.ano,
       'Tempestade sem poderes e o Julgamento de Magneto'
FROM ordem CROSS JOIN marco CROSS JOIN novos novo;

WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id, min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN series serie ON hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(item.titulo_referencia)
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE item.titulo_referencia IN ('Guerras Secretas II', 'X-Men: Guerras Asgardianas')
      AND item.status_identificacao = 'PENDENTE_REVISAO'
    GROUP BY item.id HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id, url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato WHERE item.id = candidato.item_id;

UPDATE itens_ordem_leitura item
SET observacao = CASE item.detalhe_referencia
    WHEN 'V1 #11' THEN left(E'GUERRAS ASGARDIANAS\nReúne New Mutants Special Edition 1, X-Men Annual 9 e histórias complementares de X-Men Classic. New Mutants Special Edition 1 e X-Men Annual 9 também estão em X-Men: Guerras Asgardianas. O encadernado das Guerras Asgardianas acrescenta X-Men and Alpha Flight 1-2; escolha a edição de acordo com o conteúdo que deseja ler.\n\n' || coalesce(item.observacao, ''), 1000)
    WHEN 'V1 #12' THEN left(E'O JULGAMENTO DE MAGNETO\nReúne Uncanny X-Men 200-203 e Marvel Fanfare 33. O julgamento de Magneto começa em Uncanny X-Men 200 e muda sua posição dentro da comunidade mutante.\n\n' || coalesce(item.observacao, ''), 1000)
    WHEN 'V1 #13' THEN left(E'LADY LETAL, NIMROD E O CLUBE DO INFERNO\nReúne Uncanny X-Men 204-209. Wolverine é atacado por Lady Letal e outros ciborgues, enquanto os X-Men e o Clube do Inferno enfrentam a ameaça de Nimrod.\n\n' || coalesce(item.observacao, ''), 1000)
    ELSE item.observacao
END
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
  AND item.detalhe_referencia IN ('V1 #11', 'V1 #12', 'V1 #13');

WITH marcos AS (
    SELECT
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #5') AS inicio_tempestade,
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #13') AS inicio_nimrod,
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #16') AS inicio_queda,
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #24') AS inicio_inferno,
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #27') AS inicio_australia,
        max(posicao) FILTER (WHERE detalhe_referencia = 'V1 #31') AS fim_australia
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
)
UPDATE itens_ordem_leitura item
SET secao = CASE
    WHEN item.posicao >= marco.inicio_tempestade AND item.posicao < marco.inicio_nimrod
        THEN 'Tempestade sem poderes e o Julgamento de Magneto'
    WHEN item.posicao >= marco.inicio_nimrod AND item.posicao < marco.inicio_queda
        THEN 'Nimrod, Lady Letal e o retorno de Jean Grey'
    WHEN item.posicao >= marco.inicio_queda AND item.posicao < marco.inicio_inferno
        THEN 'Queda dos Mutantes e novas formações'
    WHEN item.posicao >= marco.inicio_inferno AND item.posicao < marco.inicio_australia
        THEN 'Inferno'
    WHEN item.posicao >= marco.inicio_australia AND item.posicao < marco.fim_australia
        THEN 'A fase australiana e Wolverine em Madripoor'
    ELSE item.secao
END
FROM ordens_leitura ordem, marcos marco
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.inicio_tempestade AND item.posicao < marco.fim_australia;
