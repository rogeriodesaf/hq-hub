-- Acrescenta os volumes 6 e 7 da Edição Definitiva como alternativas
-- editoriais contínuas e identifica os arcos clássicos reunidos neles.

-- Abre duas posições depois do volume 5. O deslocamento em duas etapas evita
-- conflitos com a restrição única (ordem_leitura_id, posicao).
UPDATE itens_ordem_leitura item
SET posicao = posicao + 1000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 23;

UPDATE itens_ordem_leitura item
SET posicao = posicao - 998
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao >= 1023;

WITH ordem AS (
    SELECT id
    FROM ordens_leitura
    WHERE slug = 'ordem-de-leitura-mutante'
), referencias(posicao, numero, observacao, ano) AS (VALUES
    (
        23,
        6,
        'Alternativa editorial contínua ao volume 5. Reúne Uncanny X-Men 111-128, Incredible Hulk Annual 7, Marvel Team-Up 89 e X-Men Annual 3. A Saga de Proteus acontece em Uncanny X-Men 125-128, quando os X-Men e Moira MacTaggert enfrentam o mutante Proteus. Não é necessário reler os itens equivalentes seguintes.',
        2023
    ),
    (
        24,
        7,
        'Alternativa editorial contínua ao volume 6. Reúne Uncanny X-Men 129-143, Uncanny X-Men Annual 4, Marvel Treasury Edition 26-27, Marvel Team-Up 100 e Phoenix: The Untold Story. A Saga da Fênix Negra ocorre em Uncanny X-Men 129-137; Dias de um Futuro Esquecido ocorre em Uncanny X-Men 141-142, quando a Kitty Pryde do futuro tenta impedir o assassinato do senador Robert Kelly. Não é necessário reler os itens equivalentes seguintes.',
        2023
    )
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT
    ordem.id,
    referencia.posicao,
    'Os Fabulosos X-Men: Edição Definitiva',
    'V1 #' || referencia.numero,
    'PENDENTE_REVISAO',
    referencia.observacao,
    referencia.ano,
    'Nova Equipe e os anos de Chris Claremont'
FROM ordem
CROSS JOIN referencias referencia;

WITH candidatos AS (
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
     AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') =
         (item.posicao - 17)::text
    WHERE item.ordem_leitura_id = ordem.id
      AND item.posicao BETWEEN 23 AND 24
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    status_identificacao = 'CONFIRMADO'
FROM candidatos candidato
WHERE item.id = candidato.item_id;

-- Destaca a cobertura alternativa da saga já presente no guia.
UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Reúne a Saga da Fênix Negra, publicada originalmente em Uncanny X-Men 129-137. Este material também está em Os Fabulosos X-Men: Edição Definitiva vol. 7; não é necessário ler as duas opções.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) =
      lower('Marvel Essenciais: X-Men — A Saga da Fênix Negra');

-- O especial de Guerras Secretas reutiliza o nome do arco clássico, mas é uma
-- história posterior e não republica Uncanny X-Men 141-142.
UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Não confundir com o arco clássico Dias de um Futuro Esquecido, de Uncanny X-Men 141-142, reunido em Os Fabulosos X-Men: Edição Definitiva vol. 7.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) =
      lower('Guerras Secretas: X-Men — Dias de um Futuro Esquecido');

UPDATE itens_ordem_leitura item
SET secao = 'Nova Equipe e os anos de Chris Claremont'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao BETWEEN 22 AND 131;
