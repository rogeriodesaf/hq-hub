-- Abre a etapa da década atual com Cisma, Magneto e Vingadores vs. X-Men.

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), candidatos AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (ORDER BY edicao.id) AS prioridade
    FROM series serie
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Coleção Oficial de Graphic Novels Marvel')
      AND substring(edicao.numero FROM '([0-9]+)')::integer = 94
), base AS (
    SELECT coalesce(max(item.posicao), 0) AS fim
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, observacao, secao
)
SELECT ordem.id, base.fim + 1,
       'Coleção Oficial de Graphic Novels Marvel', 'V1 #94',
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       'CISMA — Ciclope vê os alunos como soldados. Wolverine os vê como crianças. A tensão entre os dois rivais chega ao ápice, e os mutantes precisam escolher seus líderes.',
       'Guia de Leitura Cronológica dos X-Men: Década atual'
FROM ordem CROSS JOIN base
LEFT JOIN candidatos candidato ON candidato.prioridade = 1;

WITH descricoes(titulo, texto) AS (VALUES
    ('Magneto: Atos de Terror',
     'ATOS DE TERROR — O Mestre do Magnetismo é filmado assassinando integrantes de um grupo antimutante. Por que ele teria descartado tudo o que aprendeu com os X-Men é um mistério que precisa ser solucionado antes que uma nova tragédia aconteça!'),
    ('Marvel Deluxe: Vingadores vs. X-Men',
     'VINGADORES VS. X-MEN — A Força Fênix está voltando para a Terra, e os Vingadores decidem intervir. A provável hospedeira é a garota Esperança, de Complexo de Messias, e os X-Men querem defendê-la.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo);

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
    WHERE lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Segundo Advento')
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Oficial de Graphic Novels Marvel')
                 AND item.detalhe_referencia = 'V1 #94' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Magneto: Atos de Terror') THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('Marvel Deluxe: Vingadores vs. X-Men') THEN 3
        END AS ordem_etapa
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
), ranqueados AS (
    SELECT prioridade.id,
           row_number() OVER (
               ORDER BY CASE
                   WHEN prioridade.ordem_etapa IS NOT NULL
                       THEN marco.posicao_original + prioridade.ordem_etapa / 100.0
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           prioridade.ordem_etapa
    FROM prioridades prioridade
    JOIN itens_ordem_leitura item ON item.id = prioridade.id
    CROSS JOIN marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE WHEN ranqueado.ordem_etapa IS NOT NULL
        THEN 'Guia de Leitura Cronológica dos X-Men: Década atual'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
