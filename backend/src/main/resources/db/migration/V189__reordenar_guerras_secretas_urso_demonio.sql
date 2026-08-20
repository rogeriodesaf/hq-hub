-- Reordena os especiais clássicos e acrescenta descrições aos volumes pedidos.

DO $$
DECLARE
    ordem_id BIGINT;
    item_id BIGINT;
    origem INTEGER;
    destino INTEGER;
BEGIN
    SELECT id INTO ordem_id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante';
    SELECT id, posicao INTO item_id, origem
    FROM itens_ordem_leitura
    WHERE ordem_leitura_id = ordem_id
      AND lower(trim(titulo_referencia)) = lower('Guerras Secretas - Edição Especial');
    SELECT posicao INTO destino
    FROM itens_ordem_leitura
    WHERE ordem_leitura_id = ordem_id
      AND lower(trim(titulo_referencia)) = lower('A Saga dos X-Men')
      AND detalhe_referencia = 'V1 #3';

    IF item_id IS NOT NULL AND origem > destino THEN
        UPDATE itens_ordem_leitura SET posicao = -1000 WHERE id = item_id;
        UPDATE itens_ordem_leitura SET posicao = posicao + 10000
        WHERE ordem_leitura_id = ordem_id AND posicao BETWEEN destino AND origem - 1;
        UPDATE itens_ordem_leitura SET posicao = posicao - 9999
        WHERE ordem_leitura_id = ordem_id AND posicao BETWEEN destino + 10000 AND origem + 9999;
        UPDATE itens_ordem_leitura SET posicao = destino WHERE id = item_id;
    END IF;
END $$;

-- Abre uma posição antes do volume 5 para a Saga do Urso-Demônio.
WITH marco AS (
    SELECT item.posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #5'
)
UPDATE itens_ordem_leitura item SET posicao = item.posicao + 10000
FROM ordens_leitura ordem, marco
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.posicao;

UPDATE itens_ordem_leitura item SET posicao = item.posicao - 9999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 10000;

WITH ordem AS (SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'),
marco AS (
    SELECT item.posicao - 1 AS posicao, item.secao
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #5'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT ordem.id, marco.posicao, 'Marvel Essenciais: Novos Mutantes - A Saga do Urso-Demônio', 'V1',
       'PENDENTE_REVISAO',
       E'A SAGA DO URSO-DEMÔNIO\nDani Moonstar e os Novos Mutantes enfrentam a criatura ligada aos maiores medos dela. Reúne New Mutants 18-21. Essas histórias também aparecem parcialmente em Os Novos Mutantes: Entre a Luz e a Escuridão, que reúne New Mutants 18-25 e New Mutants Annual 1.',
       2023, marco.secao
FROM ordem CROSS JOIN marco;

-- Abre uma posição imediatamente antes do volume 11 para Guerras Secretas II.
WITH marco AS (
    SELECT item.posicao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #11'
)
UPDATE itens_ordem_leitura item SET posicao = item.posicao + 10000
FROM ordens_leitura ordem, marco
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= marco.posicao;

UPDATE itens_ordem_leitura item SET posicao = item.posicao - 9999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 10000;

WITH ordem AS (SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'),
marco AS (
    SELECT item.posicao - 1 AS posicao, item.secao
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #11'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT ordem.id, marco.posicao, 'Guerras Secretas II', '#UNICA',
       'PENDENTE_REVISAO',
       E'GUERRAS SECRETAS II\nEvento posicionado imediatamente antes das Guerras Asgardianas nesta ordem de leitura.',
       2026, marco.secao
FROM ordem CROSS JOIN marco;

-- Vincula os três especiais às edições já existentes no catálogo.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id, min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN series serie ON
      hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(item.titulo_referencia)
      OR (item.titulo_referencia LIKE '%Urso-Demônio%' AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%urso demonio%')
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    WHERE item.titulo_referencia IN (
        'Marvel Essenciais: Novos Mutantes - A Saga do Urso-Demônio', 'Guerras Secretas II'
    ) AND item.status_identificacao = 'PENDENTE_REVISAO'
    GROUP BY item.id HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id, url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato WHERE item.id = candidato.item_id;

UPDATE itens_ordem_leitura item
SET edicao_id = 15661,
    url_capa_referencia = (SELECT url_capa FROM edicoes WHERE id = 15661),
    status_identificacao = 'CONFIRMADO'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Guerras Secretas - Edição Especial');

WITH descricoes(detalhe, texto) AS (VALUES
    ('V1 #5', E'KITTY PRYDE E WOLVERINE\nKitty vai ao Japão tentar salvar seu pai da Yakuza, mas se defronta com um homem do passado de Wolverine.'),
    ('V1 #7', E'X-MEN E VINGADORES CONTRA KULAN GATH\nUm feiticeiro transforma Nova York na Era Hiboriana. Os Vingadores e os X-Men se juntam para enfrentar a ameaça.'),
    ('V1 #9', E'ORORO NO QUÊNIA\nDepois de perder seus poderes, Ororo retorna às suas origens no Quênia. Sua jornada de reconexão a força a confrontar inimigos do passado, expectativas sobre seus poderes e novos perigos.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
  AND item.detalhe_referencia = descricao.detalhe;
