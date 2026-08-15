-- Cadastra Avante, Vingadores! (5ª série Panini), suas 26 edições e capas,
-- vinculando ao guia mutante os números 6 a 9 usados na ordem de leitura.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Avante, Vingadores!',
    'Quinta série brasileira de Avante, Vingadores!, publicada pela Panini em 26 edições.',
    2024,
    2026,
    5,
    'PANINI',
    'PANINI-AVANTE-VINGADORES-V5',
    'https://panini.com.br/avante-vingadores-2022-vol-01-19',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Panini')
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

WITH referencias(numero, legado, url_capa) AS (VALUES
    (1, 19, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_h000l1cr51417arg3nhv0tt74c/-S265-FWEBP'),
    (2, 20, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_loa6am0lld1q79mv0gi3c4fk5d/-S265-FWEBP'),
    (3, 21, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_stdg0nrh9l2n90256j4nr30a17/-S265-FWEBP'),
    (4, 22, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8jdasbhchd379cocepqg9ipd37/-S265-FWEBP'),
    (5, 23, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vtg2ikvas54nb3jkc6qfplb64s/-S265-FWEBP'),
    (6, 24, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fb2ps225114v3caokrf81c6a22/-S265-FWEBP'),
    (7, 25, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_518gnq5hmd2m31pbrir2o8g54q/-S265-FWEBP'),
    (8, 26, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1fpbfjdkv968b13t1ht61sda0s/-S265-FWEBP'),
    (9, 27, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e6f3haj3s14m12mla5vtejcc2s/-S265-FWEBP'),
    (10, 28, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_sbrvr6otal6jda0q8lu235ae23/-S265-FWEBP'),
    (11, 29, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_181bkhr9r15ep5b0e7716n6v0s/-S265-FWEBP'),
    (12, 30, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e2q9jqgif90e181c6mhvnvve79/-S265-FWEBP'),
    (13, 31, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_bg6qpgf7st3a9dqb5n05vaft73/-S265-FWEBP'),
    (14, 32, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_k81ed1k97t34bbeiu7qnplc92v/-S265-FWEBP'),
    (15, 33, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8bi8o8seh131pbn15baqgbdo1f/-S265-FWEBP'),
    (16, 34, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8bl9d0mep51lt0ankl86e1ia7v/-S265-FWEBP'),
    (17, 35, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_i90hsovi2l0u7c6feo0ef2917i/-S265-FWEBP'),
    (18, 36, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_4ce1k38fil1h78cjakqk5sm744/-S265-FWEBP'),
    (19, 37, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pdeijlj5493hp2houicm02fv11/-S265-FWEBP'),
    (20, 38, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1poqkvqcgh1334ooe9jhuu920f/-S265-FWEBP'),
    (21, 39, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_njc8f2aftl61tdt1e3dt7jqh6f/-S265-FWEBP'),
    (22, 40, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_q4nagdu5b524fdvm4jfkioaf0m/-S265-FWEBP'),
    (23, 41, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_v70cmu0b2h70v22gr3llnf1u18/-S265-FWEBP'),
    (24, 42, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fspf4v5du10fpbsqe8u0f5fp7r/-S265-FWEBP'),
    (25, 43, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_v7vg3os6ct1474ktg2miun152i/-S265-FWEBP'),
    (26, 44, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nc0rdgep852trcc4jfufomef14/-S265-FWEBP')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Avante, Vingadores!')
      AND coalesce(serie.volume, 0) = 5
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    referencia.numero::text,
    'Avante, Vingadores! (2022) Vol. ' || lpad(referencia.numero::text, 2, '0'),
    referencia.url_capa,
    'PANINI',
    'AAVAN' || lpad(referencia.legado::text, 3, '0'),
    'https://panini.com.br/avante-vingadores-2022-vol-' ||
        lpad(referencia.numero::text, 2, '0') || '-' || lpad(referencia.legado::text, 2, '0'),
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH vinculos(posicao, id_externo) AS (VALUES
    (537, 'AAVAN024'),
    (538, 'AAVAN025'),
    (539, 'AAVAN026'),
    (540, 'AAVAN027')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON edicao.id_externo = vinculo.id_externo
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Avante, Vingadores!')
      AND coalesce(serie.volume, 0) = 5
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
