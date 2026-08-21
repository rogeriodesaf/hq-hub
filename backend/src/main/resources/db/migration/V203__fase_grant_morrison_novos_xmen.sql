-- Cadastra no guia os sete volumes de Novos X-Men por Grant Morrison e os
-- posiciona depois de X-Men: Amanhecer Violento.

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), dados(numero, texto) AS (VALUES
    ('1', 'Tudo começa nas úmidas selvas da América do Sul e termina nas linhas de frente da guerra pelo nosso futuro genético!'),
    ('2', 'Possuindo o corpo do Professor X, Cassandra Nova revelou ao mundo a identidade dos X-Men e partiu para o espaço com planos de conquista. Agora, ela comanda todo o Império Shi’ar e decide erradicar a raça mutante. Mesmo enfraquecidos por uma doença misteriosa, os X-Men são o único obstáculo no caminho da perigosa vilã!'),
    ('3', 'Cassandra Nova expôs os X-Men ao mundo, e agora é hora de lidar com as consequências dessa revelação! A recém-criada Corporação X se propõe a abrigar mutantes oprimidos ao redor do planeta, dando aos Filhos do Átomo projeção e alcance globais. Entre protestos e manifestações de apoio, o Professor X e seus discípulos enfrentam desafios como a Arma XII, Fantomex, as almas perdidas de Genosha e o crescente poder de Jean Grey!'),
    ('4', 'Mais do que um centro de treinamento, a Escola do Professor Xavier para Jovens Superdotados sempre foi um refúgio. Mas então acontece o impensável: um aluno se reinventa como Kid Ômega e decide tomar o controle do lugar!'),
    ('5', 'Um dos X-Men foi assassinado, e Lucas Bishop precisa esclarecer o mistério. Muitos tinham bons motivos para matar Emma Frost, mas quem fez isso e por quê? Fantomex reaparece prometendo revelar informações sobre o passado de Wolverine se o canadense o ajudar a destruir Ultimaton, a mais recente criação do Programa Arma Extra. Logan, porém, pode não estar preparado para o que vai descobrir.'),
    ('6', 'O geneterrorista conhecido como Magneto está de volta para destruir os X-Men em mais um capítulo da passagem de Grant Morrison pelo título dos mutantes! A equipe já lutou incontáveis vezes contra esse adversário e até o considerava morto, mas esse ataque pode ser demais para os Filhos do Átomo, ameaçando suas vidas e tudo o que construíram nos últimos tempos!'),
    ('7', 'Conheça os X-Men de 150 anos no futuro. Embora alguns rostos pareçam familiares, surgem novos heróis e vilões. Que força ameaça destruir os mutantes do futuro, e como isso afetará os X-Men de hoje? O volume também traz uma edição recheada de extras inéditos pelas premiadas mãos de Marc Silvestri!')
), candidatos AS (
    SELECT dado.numero, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY dado.numero ORDER BY edicao.id) AS prioridade
    FROM dados dado
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Novos X-Men Por Grant Morrison')
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
    edicao_id, url_capa_referencia, status_identificacao, observacao, secao
)
SELECT ordem.id, base.fim + dado.numero::integer,
       'Novos X-Men Por Grant Morrison', 'V1 #' || dado.numero,
       candidato.edicao_id, candidato.url_capa,
       CASE WHEN candidato.edicao_id IS NULL THEN 'PENDENTE_REVISAO' ELSE 'CONFIRMADO' END,
       left('NOVOS X-MEN POR GRANT MORRISON — VOLUME ' || dado.numero || E'\n' || dado.texto, 1000),
       'Fase Grant Morrison: Novos X-Men'
FROM ordem CROSS JOIN base CROSS JOIN dados dado
LEFT JOIN candidatos candidato
  ON candidato.numero = dado.numero AND candidato.prioridade = 1;

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
    WHERE lower(trim(item.titulo_referencia)) = lower('As Maiores Sagas dos X-Men: Amanhecer Violento')
      AND item.detalhe_referencia = 'V1 #2'
), prioridades AS (
    SELECT item.id, substring(item.detalhe_referencia FROM '#([0-9]+)')::integer AS ordem_etapa
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('Novos X-Men Por Grant Morrison')
      AND item.detalhe_referencia IN ('V1 #1', 'V1 #2', 'V1 #3', 'V1 #4', 'V1 #5', 'V1 #6', 'V1 #7')
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
        THEN 'Fase Grant Morrison: Novos X-Men'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
