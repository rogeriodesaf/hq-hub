-- Completa a primeira serie mensal de Wolverine publicada pela Panini no Brasil:
-- 107 edicoes, de dezembro de 2004 a 2013. O catalogo da Rika cadastrou esse
-- lote em sequencia (produtos 15003112..15003218 e imagens 222918..223024).
-- Apenas a edicao 1 integra a Ordem de Leitura Mutante.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Wolverine')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE series serie
SET descricao = 'Primeira serie mensal brasileira de Wolverine publicada pela Panini, com 107 edicoes.',
    ano_inicio = 2004,
    ano_fim = 2013,
    fonte_externa = 'RIKA',
    id_externo = 'RIKA-WOLVERINE-2004-107',
    url_origem = 'https://www.rika.com.br/wolverine--00115003112/p',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Wolverine')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
), referencias AS (
    SELECT
        numero,
        lpad(numero::text, 3, '0') AS numero_formatado,
        (15003111 + numero)::text AS produto_id,
        (222917 + numero)::text AS imagem_id
    FROM generate_series(1, 107) numero
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    referencia.numero::text,
    'Wolverine ' || referencia.numero_formatado,
    'Wolverine ' || referencia.numero_formatado,
    'https://rika.vtexassets.com/arquivos/ids/' || referencia.imagem_id
        || '/-herois_panini-wolverine-' || referencia.numero_formatado || '.jpg',
    '17 x 26 cm, colorido',
    'RIKA',
    referencia.produto_id,
    'https://www.rika.com.br/wolverine--' || referencia.numero_formatado
        || referencia.produto_id || '/p',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH edicao_um AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Wolverine')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    titulo_referencia = 'Wolverine',
    detalhe_referencia = 'V1 #1'
FROM edicao_um edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 495;
