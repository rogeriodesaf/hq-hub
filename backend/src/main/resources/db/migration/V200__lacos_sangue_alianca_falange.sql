-- Cria a etapa de Laços de Sangue, As Aventuras de Ciclope e Fênix
-- e Aliança Falange logo após Atrações Fatais.

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), dados(ordem_item, numero) AS (VALUES
    (1, '207'),
    (2, '208')
), candidatos AS (
    SELECT dado.ordem_item, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY dado.ordem_item ORDER BY edicao.id) AS prioridade
    FROM dados dado
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Capitão América')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)') = dado.numero
), base AS (
    SELECT coalesce(max(item.posicao), 0) AS fim
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, secao
)
SELECT ordem.id, base.fim + dado.ordem_item,
       'Capitão América', 'V1 #' || dado.numero,
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       'X-Men e Vingadores: Laços de Sangue e Aliança Falange'
FROM ordem CROSS JOIN base CROSS JOIN dados dado
LEFT JOIN candidatos candidato
  ON candidato.ordem_item = dado.ordem_item AND candidato.prioridade = 1;

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('Capitão América', 'V1 #207',
     'LAÇOS DE SANGUE — Após Atrações Fatais, Fabian Cortez invade Genosha e instiga a população mutante e mutóide da ilha a uma revolução violenta, utilizando-se da fé em Magneto. Um arco com consequências importantes.'),
    ('X-Men: As Aventuras de Ciclope e Fênix', NULL,
     'AS AVENTURAS DE CICLOPE E FÊNIX — Transportados para um futuro distópico, o mesmo para o qual seu filho Nathan fora enviado, Scott e Jean precisam viver numa realidade de terror e, ao mesmo tempo, criar Nathan para que ele se torne o homem destinado a ser.'),
    ('X-Men: Aliança Falange', NULL,
     'ALIANÇA FALANGE — A forma tecnorgânica extraterrestre Falange chega à Terra e entra em conflito com os X-Men, que não podem ser assimilados por ela.')
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
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V2 #13'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Capitão América') AND item.detalhe_referencia = 'V1 #207' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Capitão América') AND item.detalhe_referencia = 'V1 #208' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Men: As Aventuras de Ciclope e Fênix') THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Men: Aliança Falange') THEN 4
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
        THEN 'X-Men e Vingadores: Laços de Sangue e Aliança Falange'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
