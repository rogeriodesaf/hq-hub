-- Capas de Batman 7a Serie, publicada pela Panini a partir de 2025.
-- As URLs e referencias sao do catalogo oficial da Panini.
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
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND serie.volume = 7
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman'),
          hqhub_normalizar_titulo_serie('Batman 7ª Série')
      )
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'PANINI',
    id_externo = capa.referencia,
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

-- Mantem as capas exibidas nos guias de leitura sincronizadas.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 7
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman'),
      hqhub_normalizar_titulo_serie('Batman 7ª Série')
  )
  AND edicao.url_capa IS NOT NULL;
