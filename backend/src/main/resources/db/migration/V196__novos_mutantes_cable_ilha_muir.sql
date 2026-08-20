-- Cria a etapa da chegada de Cable, do fim dos Novos Mutantes e da Saga da Ilha Muir.

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), dados(ordem_item, titulo, detalhe, observacao) AS (VALUES
    (1, 'Essential X-Factor (2005)', 'V1',
     'Neste derradeiro confronto, Ciclope toma a decisão mais difícil de sua vida.'),
    (2, 'New Mutants Epic Collection (2017)', 'V1',
     'O FIM DOS NOVOS MUTANTES — Após várias aventuras sob a liderança de Cable, a equipe dos Novos Mutantes é dissolvida, dando início a outra!'),
    (3, 'Os Heróis Mais Poderosos da Marvel', 'V1 #22',
     'A SAGA DA ILHA MUIR — Xavier enfrenta o Rei das Sombras, um nêmesis de seu passado!')
), candidatos AS (
    SELECT dado.ordem_item, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY dado.ordem_item ORDER BY edicao.id) AS prioridade
    FROM dados dado
    JOIN series serie
      ON hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie(dado.titulo),
          hqhub_normalizar_titulo_serie(replace(dado.titulo, ' (2005)', '')),
          hqhub_normalizar_titulo_serie(replace(dado.titulo, ' (2017)', ''))
      )
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE (dado.ordem_item IN (1, 2) AND edicao.numero IN ('1', 'ÚNICA', 'UNICA'))
       OR (dado.ordem_item = 3 AND substring(edicao.numero FROM '([0-9]+)')::integer = 22)
), base AS (
    SELECT coalesce(max(item.posicao), 0) AS fim
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    edicao_id, url_capa_referencia, status_identificacao, observacao, secao
)
SELECT ordem.id, base.fim + dado.ordem_item, dado.titulo, dado.detalhe,
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       NULL,
       'Novos Mutantes: a chegada de Cable e Saga da Ilha Muir'
FROM ordem CROSS JOIN base CROSS JOIN dados dado
LEFT JOIN candidatos candidato
  ON candidato.ordem_item = dado.ordem_item AND candidato.prioridade = 1;

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('Guerras Secretas: X-Men — Programa de Extermínio', NULL,
     'PROGRAMA DE EXTERMÍNIO — Aqui conhecemos a farsa por trás da terra de “paz” para os mutantes de Genosha.'),
    ('Essential X-Factor (2005)', 'V1',
     'Neste derradeiro confronto, Ciclope toma a decisão mais difícil de sua vida.'),
    ('New Mutants Epic Collection (2017)', 'V1',
     'O FIM DOS NOVOS MUTANTES — Após várias aventuras sob a liderança de Cable, a equipe dos Novos Mutantes é dissolvida, dando início a outra!'),
    ('Os Heróis Mais Poderosos da Marvel', 'V1 #22',
     'A SAGA DA ILHA MUIR — Xavier enfrenta o Rei das Sombras, um nêmesis de seu passado!')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia IS NOT DISTINCT FROM descricao.detalhe;

-- Afasta todas as posições para permitir a renumeração completa sem colisões.
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
      AND item.detalhe_referencia = 'V1 #31'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Cable V1: Conquista') THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Cable V1: Os Mais Novos Mutantes') THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('Cable: Medos Passados') THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('Guerras Secretas: X-Men — Programa de Extermínio') THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('Essential X-Factor (2005)') THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('New Mutants Epic Collection (2017)') THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('Os Heróis Mais Poderosos da Marvel') AND item.detalhe_referencia = 'V1 #22' THEN 7
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #32' THEN 8
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #34' THEN 9
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #35' THEN 10
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
        THEN 'Novos Mutantes: a chegada de Cable e Saga da Ilha Muir'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
