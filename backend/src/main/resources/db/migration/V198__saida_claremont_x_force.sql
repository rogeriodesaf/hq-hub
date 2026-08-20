-- Organiza a saída de Chris Claremont, a formação da X-Force e a sequência
-- das fases dos X-Men e de Wolverine no início dos anos 1990.

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('A Saga dos X-Men', 'V2 #1',
     'GÊNESE MUTANTE E A CHEGADA DE BISHOP — Xavier volta à liderança dos X-Men e separa a equipe entre Azul e Dourada. Magneto volta a ser um vilão temido. O volume também traz a primeira aparição de Bishop, um importante membro da equipe.'),
    ('A Saga dos X-Men', 'V2 #2',
     'SURGE ÔMEGA VERMELHO — Os X-Men tentam descobrir a verdade sobre o mutante chamado Bishop. Enquanto isso, o Tentáculo ressuscita o mutante russo Ômega Vermelho, e a luta se torna pessoal quando Logan enfrenta velhos inimigos e futuras ameaças!'),
    ('A Saga dos X-Men', 'V2 #3',
     'A MISSÃO DE BISHOP E O MOTOQUEIRO FANTASMA — Após serem sugados pelo vácuo, os X-Men são teleportados para outro mundo devastado pela guerra, mas acabam separados. Na Terra, Bishop e os demais continuam a eliminar criminosos vindos para impedir que seu futuro horrível se concretize. Além disso, os mutantes cruzam o caminho do Motoqueiro Fantasma!'),
    ('A Saga dos X-Men', 'V2 #5',
     'O IRMÃO DE COLOSSUS — Qual é a causa da insanidade que varreu os túneis Morlocks, infectando os mutantes subterrâneos e levando-os a enlouquecer? Bishop, Colossus e Jean Grey lutam contra a loucura dos túneis. Enquanto isso, Calisto desafia Xavier para uma luta até a morte, Wolverine descobre um segredo obscuro do passado do Professor X e os X-Men são atacados pelos Cavaleiros do Apocalipse!'),
    ('A Saga dos X-Men', 'V2 #6',
     'A SAGA DOS X-MEN — Continuação do arco do irmão de Colossus, a verdade sobre Shatterstar e o retorno de Betsy Braddock.'),
    ('A Saga do Wolverine', 'V1 #5',
     'SURGE MAVERICK E A MORTE DE MARIKO YASHIDA'),
    ('A Saga do Wolverine', 'V1 #6',
     'Wolverine e Jubileu partem para ajudar uma amiga do Professor Xavier cuja filha foi sequestrada. Shiva vai atrás de Dentes-de-Sabre enquanto Wolverine precisa lidar com a morte de Mariko. Os pecados do passado do Projeto Arma X retornam para atormentar os envolvidos!'),
    ('A Saga do Wolverine', 'V1 #7',
     'Uma regressão realizada por Xavier em Wolverine falha, causando perigo para todos ao redor de Logan.'),
    ('A Saga do Wolverine', 'V1 #8',
     'Os X-Men precisam encontrar Maverick para impedir uma matança provocada por um Wolverine desorientado!')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia = descricao.detalhe;

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
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
      AND item.detalhe_referencia = 'V1 #4'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #1' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #2' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #3' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #4' THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #5' THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V2 #6' THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #5' THEN 7
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #6' THEN 8
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #7' THEN 9
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #8' THEN 10
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
        THEN 'A saída de Chris Claremont e a X-Force'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
