-- Cadastra Batman 6a Serie, publicada pela Panini a partir de 2025,
-- com as capas e referencias do catalogo oficial da editora.
INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini Comics', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

WITH editoras_panini AS (
    SELECT editora.id, editora.nome
    FROM editoras editora
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
), serie_existente AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras_panini editora ON editora.id = serie.editora_id
    WHERE serie.volume = 6
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman'),
          hqhub_normalizar_titulo_serie('Batman 6ª Série')
      )
    LIMIT 1
), editora_alvo AS (
    SELECT editora.id
    FROM editoras_panini editora
    ORDER BY
        EXISTS (
            SELECT 1
            FROM series serie
            WHERE serie.editora_id = editora.id
              AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
                  hqhub_normalizar_titulo_serie('Batman'),
                  hqhub_normalizar_titulo_serie('Batman 5ª Série')
              )
        ) DESC,
        (hqhub_normalizar_titulo_serie(editora.nome) =
         hqhub_normalizar_titulo_serie('Panini')) DESC,
        editora.id
    LIMIT 1
)
INSERT INTO series (
    titulo, descricao, ano_inicio, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Batman',
    'Sexta serie brasileira de Batman publicada pela Panini a partir de 2025.',
    2025,
    6,
    'PANINI',
    'batman-panini-sexta-serie',
    'https://panini.com.br/batman-2025-01',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editora_alvo editora
WHERE NOT EXISTS (SELECT 1 FROM serie_existente)
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = EXCLUDED.tipo_serie,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, referencia, url_capa, url_origem) AS (
    VALUES
        (1,  'ABTMN001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdgdicjd7p7n9aklj79p3fbm59/-S265-FWEBP', 'https://panini.com.br/batman-2025-01'),
        (2,  'ABTMN002', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vt64tlcuvl2mr9cavikhkb2u45/-S265-FWEBP', 'https://panini.com.br/batman-2025-02'),
        (3,  'ABTMN003', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_jroqmjmejl4736j7vd6gvcae0h/-S265-FWEBP', 'https://panini.com.br/batman-2025-03'),
        (4,  'ABTMN004', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lthgd77n6t3u74dv226cgqbv6g/-S265-FWEBP', 'https://panini.com.br/batman-2025-04'),
        (5,  'ABTMN005', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_btbtgfc90d24vcpfm5dravjl5t/-S265-FWEBP', 'https://panini.com.br/batman-2025-05'),
        (6,  'ABTMN006', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c963kdfbe95q9chfpp17ju9p07/-S265-FWEBP', 'https://panini.com.br/batman-2025-06'),
        (7,  'ABTMN007', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_6smr45338p7i7bv2anh73vd02m/-S265-FWEBP', 'https://panini.com.br/batman-2025-07'),
        (8,  'ABTMN008', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_g6lo1ksiih2adf2omvl848h06f/-S265-FWEBP', 'https://panini.com.br/batman-2025-08'),
        (9,  'ABTMN009', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_a8s7efl27l0ifaej28fbrmlc4n/-S265-FWEBP', 'https://panini.com.br/batman-2025-09'),
        (10, 'ABTMN010', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7bj7j8jqlt3v9br8q61ufbju0d/-S265-FWEBP', 'https://panini.com.br/batman-2025-10'),
        (11, 'ABTMN011', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_60n45l42dh3ob0h49e3n4hcr40/-S265-FWEBP', 'https://panini.com.br/batman-2025-11'),
        (12, 'ABTMN012', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rqgvlui1jl5nnbimfs545jqi7j/-S265-FWEBP', 'https://panini.com.br/batman-2025-12'),
        (13, 'ABTMN013', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_psotga2sk12phd2e90af09i57t/-S265-FWEBP', 'https://panini.com.br/batman-2025-13'),
        (14, 'ABTMN014', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1614sdgdch58rc4ioke9mvpi7f/-S265-FWEBP', 'https://panini.com.br/batman-2025-14')
), serie_batman AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND serie.volume = 6
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman'),
          hqhub_normalizar_titulo_serie('Batman 6ª Série')
      )
    ORDER BY
        (hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman')) DESC,
        serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero::text,
    'Batman ' || capa.numero,
    'Edicao ' || capa.numero || ' da sexta serie de Batman publicada pela Panini.',
    'Edicao ' || capa.numero,
    capa.url_capa,
    'PANINI',
    capa.referencia,
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_batman serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 6
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman'),
      hqhub_normalizar_titulo_serie('Batman 6ª Série')
  )
  AND edicao.url_capa IS NOT NULL;
