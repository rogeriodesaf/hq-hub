-- Inclui a Edição Definitiva vol. 5 como alternativa editorial para o início
-- da Segunda Gênese e separa visualmente a fase conduzida por Chris Claremont.

-- Abre uma posicao depois de Tesouros Ocultos. O deslocamento em duas etapas
-- evita conflitos com a restricao unica (ordem_leitura_id, posicao).
UPDATE itens_ordem_leitura item
SET posicao = posicao + 1000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 22;

UPDATE itens_ordem_leitura item
SET posicao = posicao - 999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 1022;

WITH ordem AS (
    SELECT id
    FROM ordens_leitura
    WHERE slug = 'ordem-de-leitura-mutante'
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT
    ordem.id,
    22,
    'Os Fabulosos X-Men: Edição Definitiva',
    'V1 #5',
    'PENDENTE_REVISAO',
    'Alternativa editorial para o início da Segunda Gênese. Reúne Giant-Size X-Men 1, X-Men 94-110, Iron Fist 14-15, Marvel Team-Up Annual 1 e Marvel Team-Up 53 e 69-70. Chris Claremont assume a série em X-Men 94, Jean Grey surge como Fênix em X-Men 101, a trama dos Shi''ar e do Cristal M''Krann avança em X-Men 104-108 e o Arma Alpha estreia em X-Men 109. Não é necessário reler os itens equivalentes seguintes.',
    2023,
    'Nova Equipe e os anos de Chris Claremont'
FROM ordem;

WITH candidato AS (
    SELECT
        item.id AS item_id,
        min(edicao.id) AS edicao_id,
        min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem
      ON ordem.id = item.ordem_leitura_id
     AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND coalesce(serie.volume, 1) = 1
     AND hqhub_normalizar_titulo_serie(serie.titulo) =
         hqhub_normalizar_titulo_serie('Os Fabulosos X-Men: Edição Definitiva')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') = '5'
    WHERE item.ordem_leitura_id = ordem.id
      AND item.posicao = 22
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidato
WHERE item.id = candidato.item_id;

-- Explicita os recortes das outras edições do guia que compartilham histórias
-- com a Edição Definitiva vol. 5 e evita atribuir a Tropa Alfa ao intervalo
-- incorreto de X-Men 104-110.
UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Seleção parcial da Segunda Gênese: reúne Giant-Size X-Men 1, X-Men 94-95 e X-Men 104-108. Chris Claremont assume a série em X-Men 94; a transformação de Jean Grey em Fênix ocorre em X-Men 101, edição não incluída neste volume.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Os X-Men')
  AND item.detalhe_referencia = 'V1 #2';

UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Reúne X-Men 109 e 111-124, mas não X-Men 110. O Arma Alpha estreia em X-Men 109; a formação completa da Tropa Alfa enfrenta os X-Men nas edições 120-121.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('X-Men: Magneto Triunfa');

UPDATE itens_ordem_leitura item
SET secao = 'Nova Equipe e os anos de Chris Claremont'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao BETWEEN 22 AND 129;
