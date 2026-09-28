-- Corrige a colecao Homem-Aranha 1a Serie/Abril (1983-2000), volume 1.
-- Numeracao e correspondencia das capas conferidas na galeria ha00401 do
-- Guia dos Quadrinhos. As imagens corrigidas usam o CDN do GCD.

WITH dados(numero, data_publicacao, url_capa) AS (VALUES
    (1,   DATE '1983-07-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697011.jpg'),
    (11,  DATE '1984-05-01', 'https://files2.comics.org/img/gcd/covers_by_id/1063/w400/1063544.jpg'),
    (12,  DATE '1984-06-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697022.jpg'),
    (14,  DATE '1984-08-01', 'https://files2.comics.org/img/gcd/covers_by_id/853/w400/853475.jpg'),
    (15,  DATE '1984-09-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697025.jpg'),
    (18,  DATE '1984-12-01', 'https://files2.comics.org/img/gcd/covers_by_id/1063/w400/1063547.jpg'),
    (20,  DATE '1985-02-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697030.jpg'),
    (21,  DATE '1985-03-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697031.jpg'),
    (71,  DATE '1989-05-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697081.jpg'),
    (105, DATE '1992-03-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697115.jpg'),
    (135, DATE '1994-09-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697145.jpg'),
    (141, DATE '1995-03-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697151.jpg'),
    (142, DATE '1995-04-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697152.jpg'),
    (143, DATE '1995-05-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697153.jpg'),
    (147, DATE '1995-09-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697157.jpg'),
    (198, DATE '1999-12-01', 'https://files2.comics.org/img/gcd/covers_by_id/697/w400/697208.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Abril')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Homem-Aranha 1ª Série')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, data_publicacao, url_capa, fonte_externa,
    id_externo, url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero::text,
    'Homem-Aranha nº ' || dado.numero::text,
    'Edição brasileira de Homem-Aranha 1ª Série, publicada pela Abril.',
    dado.data_publicacao,
    dado.url_capa,
    'GUIA_DOS_QUADRINHOS',
    'abril|homem-aranha 1ª série|1|' || dado.numero::text,
    'https://www.guiadosquadrinhos.com/edicao/homem-aranha-1-serie-n-' ||
        dado.numero::text || '/ha00401/' || (6399 + dado.numero)::text,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM dados dado
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    url_capa = EXCLUDED.url_capa,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

-- Normaliza o link de origem das 205 edicoes. Parte do cadastro anterior
-- apontava varios numeros para a pagina da edicao 1.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Abril')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Homem-Aranha 1ª Série')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_origem =
        'https://www.guiadosquadrinhos.com/edicao/homem-aranha-1-serie-n-' ||
        trim(edicao.numero) || '/ha00401/' ||
        (6399 + trim(edicao.numero)::integer)::text,
    data_atualizacao = CURRENT_TIMESTAMP
WHERE edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 205
  AND edicao.url_origem IS DISTINCT FROM
        'https://www.guiadosquadrinhos.com/edicao/homem-aranha-1-serie-n-' ||
        trim(edicao.numero) || '/ha00401/' ||
        (6399 + trim(edicao.numero)::integer)::text;

-- Mantem capas armazenadas em guias de leitura sincronizadas com as edicoes.
WITH numeros(numero) AS (VALUES
    (1), (11), (12), (14), (15), (18), (20), (21), (71), (105), (135),
    (141), (142), (143), (147), (198)
), edicoes_corrigidas AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    JOIN numeros numero
      ON trim(edicao.numero) ~ '^[0-9]+$'
     AND trim(edicao.numero)::integer = numero.numero
    WHERE hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Abril')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Homem-Aranha 1ª Série')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes_corrigidas edicao
WHERE item.edicao_id = edicao.id
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
