-- Reúne os principais eventos da dizimação mutante em uma etapa própria.

WITH descricoes(titulo, texto) AS (VALUES
    ('Coleção Oficial de Graphic Novels Marvel — Dinastia M',
     'DINASTIA M — Após os eventos de Vingadores: A Queda, surge repentinamente um mundo onde a supremacia é mutante e Magneto é um dos líderes mundiais. Será sonho ou realidade? Os eventos desta HQ mudaram para sempre o mundo dos mutantes.'),
    ('As Maiores Sagas dos X-Men: Complexo de Messias',
     'COMPLEXO DE MESSIAS — Alguns anos após Dinastia M, as leituras indicam que uma nova mutante nasceu. Essa criança passa a ser caçada por heróis e vilões. O destino da raça mutante está em jogo!'),
    ('As Maiores Sagas dos X-Men: Guerra Messiânica',
     'GUERRA MESSIÂNICA — Meses atrás, Ciclope deu a Cable a custódia da primeira mutante nascida desde o Dia M, uma criança que muitos veem como a última esperança da humanidade mutante. Cable a levou para o futuro, mas ficou preso lá, com o implacável Bishop em sua perseguição e decidido a matar a criança.'),
    ('As Maiores Sagas dos X-Men: Utopia',
     'UTOPIA — Os X-Men acabam de se estabelecer em sua nova casa, em São Francisco, mas a tranquilidade não dura. Uma coalizão humana liderada por Simon Trask propõe obrigar toda pessoa com o gene X a se submeter a controle reprodutivo químico, provocando protestos e revoltas.'),
    ('As Maiores Sagas dos X-Men: Necrosha',
     'NECROSHA — A vampírica Selene devora almas para se tornar uma deusa e iniciar seu reino de terror. Os X-Men, a X-Force e os Novos Mutantes tentam impedi-la, mas a Rainha Negra ergue ao seu lado amigos e inimigos mortos dos X-Men!'),
    ('As Maiores Sagas dos X-Men: Segundo Advento',
     'SEGUNDO ADVENTO — Cable e Hope retornam para salvar o restante da população mutante do extermínio promovido por Bastion!')
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
    WHERE lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men')
      AND item.detalhe_referencia = 'V1 #3'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Vingadores: A Queda') THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Oficial de Graphic Novels Marvel — Dinastia M') THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Complexo de Messias') THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Guerra Messiânica') THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Utopia') THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Necrosha') THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Segundo Advento') THEN 7
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
        THEN 'Fase da dizimação mutante'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
