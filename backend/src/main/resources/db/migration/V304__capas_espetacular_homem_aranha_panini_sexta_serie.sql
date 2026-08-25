-- Cadastra O Espetacular Homem-Aranha, 6a serie (Panini, 2025-), com capas oficiais.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (titulo, descricao, ano_inicio, volume, fonte_externa, id_externo,
                    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao)
SELECT 'O Espetacular Homem-Aranha, 6ª Série',
       'Nova serie mensal da Panini iniciada em outubro de 2025.',
       2025, 6, 'PANINI', 'AEHAR001-AEHAR014',
       'https://panini.com.br/marvel/universo-homem-aranha',
       editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 6ª Série')
  )
ORDER BY editora.id LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)) DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 6ª Série')
    ORDER BY serie.id LIMIT 1
), capas(numero, data_publicacao, sku, url_capa) AS (
    VALUES
        ('1', DATE '2025-10-01', 'AEHAR001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uvam8j6leh7lbfupsqrj5llq5p/-S897-f.webp'),
        ('2', DATE '2025-11-01', 'AEHAR002', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_843rhr1nm50q9cuuub6aj2p40n/-S897-f.webp'),
        ('3', DATE '2026-01-01', 'AEHAR003', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_osp8dntkbl2rja9pt43b9g630q/-S897-f.webp'),
        ('4', DATE '2026-02-01', 'AEHAR004', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_48tab9acph58v9qmd90r22ts7o/-S897-f.webp'),
        ('5', DATE '2026-02-01', 'AEHAR005', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9m5m95bfit423a11v2sfcvd53o/-S897-f.webp'),
        ('6', DATE '2026-03-01', 'AEHAR006', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_189867jtq14eb8leuttj028s1m/-S897-f.webp'),
        ('7', DATE '2026-05-01', 'AEHAR007', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ubfi985gld1trb8g45a41dm362/-S897-f.webp'),
        ('8', DATE '2026-06-01', 'AEHAR008', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3ac8bm3pf51j32kp7q7p77og3o/-S897-f.webp'),
        ('9', DATE '2026-07-01', 'AEHAR009', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rfni5rjjfl1hle581t5t21qg6d/-S897-f.webp'),
        ('10', DATE '2026-08-01', 'AEHAR010', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8r1pqvsrml04nanb2gs8odrc6o/-S897-f.webp'),
        ('11', DATE '2026-08-01', 'AEHAR011', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_i7jakp0frp4nrdje1ehavcsj57/-S897-f.webp'),
        ('12', DATE '2026-09-01', 'AEHAR012', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_6kqt8d4vpp09d466l32rfm840b/-S897-f.webp'),
        ('13', DATE '2026-09-01', 'AEHAR013', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_g1kp1sl4jh10589t011ki3r85v/-S897-f.webp'),
        ('14', DATE '2026-10-01', 'AEHAR014', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r7ods54dad40l5fvif7mtbsi3h/-S897-f.webp')
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, formato,
                     fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero,
       'O Espetacular Homem-Aranha #' || capa.numero,
       'Edicao brasileira da sexta serie de O Espetacular Homem-Aranha publicada pela Panini.',
       capa.data_publicacao, capa.url_capa, '17 x 26 cm, colorido, canoa',
       'PANINI', capa.sku,
       'https://panini.com.br/o-espetacular-homem-aranha-2025-' || lpad(capa.numero, 2, '0'),
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo, descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao, url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato, fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo, url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
