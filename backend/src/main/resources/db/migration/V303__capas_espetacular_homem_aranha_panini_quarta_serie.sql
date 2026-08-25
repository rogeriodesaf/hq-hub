-- Cadastra O Espetacular Homem-Aranha, 4a serie (Panini, 2019-2022), com 44 capas.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
                    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao)
SELECT 'O Espetacular Homem-Aranha, 4ª Série',
       'Serie mensal da Panini publicada de abril de 2019 a novembro de 2022.',
       2019, 2022, 4, 'PANINI', 'AMVNI001-AMVNI044',
       'https://panini.com.br/marvel/universo-homem-aranha',
       editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 4ª Série')
  )
ORDER BY editora.id LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)) DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 4ª Série')
    ORDER BY serie.id LIMIT 1
), capas(numero, data_publicacao, sku, url_capa_alternativa) AS (
    VALUES
        ('1', DATE '2019-04-01', 'AMVNI001', NULL),
        ('2', DATE '2019-05-01', 'AMVNI002', NULL),
        ('3', DATE '2019-06-01', 'AMVNI003', NULL),
        ('4', DATE '2019-07-01', 'AMVNI004', 'https://skoob.s3.amazonaws.com/livros/937394/O_ESPETACULAR_HOMEM_ARANHA_4_1565464994937394SK1565464994B.jpg'),
        ('5', DATE '2019-08-01', 'AMVNI005', NULL),
        ('6', DATE '2019-09-01', 'AMVNI006', NULL),
        ('7', DATE '2019-10-01', 'AMVNI007', NULL),
        ('8', DATE '2019-11-01', 'AMVNI008', NULL),
        ('9', DATE '2019-12-01', 'AMVNI009', NULL),
        ('10', DATE '2020-01-01', 'AMVNI010', NULL),
        ('11', DATE '2020-02-01', 'AMVNI011', NULL),
        ('12', DATE '2020-03-01', 'AMVNI012', NULL),
        ('13', DATE '2020-04-01', 'AMVNI013', NULL),
        ('14', DATE '2020-05-01', 'AMVNI014', NULL),
        ('15', DATE '2020-06-01', 'AMVNI015', NULL),
        ('16', DATE '2020-07-01', 'AMVNI016', NULL),
        ('17', DATE '2020-08-01', 'AMVNI017', NULL),
        ('18', DATE '2020-09-01', 'AMVNI018', NULL),
        ('19', DATE '2020-10-01', 'AMVNI019', NULL),
        ('20', DATE '2020-11-01', 'AMVNI020', NULL),
        ('21', DATE '2020-12-01', 'AMVNI021', NULL),
        ('22', DATE '2021-01-01', 'AMVNI022', NULL),
        ('23', DATE '2021-02-01', 'AMVNI023', NULL),
        ('24', DATE '2021-03-01', 'AMVNI024', NULL),
        ('25', DATE '2021-04-01', 'AMVNI025', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kv4vv7uufp0v327tmbok3oa70n/-S897-f.webp'),
        ('26', DATE '2021-05-01', 'AMVNI026', NULL),
        ('27', DATE '2021-06-01', 'AMVNI027', NULL),
        ('28', DATE '2021-07-01', 'AMVNI028', NULL),
        ('29', DATE '2021-08-01', 'AMVNI029', NULL),
        ('30', DATE '2021-09-01', 'AMVNI030', NULL),
        ('31', DATE '2021-10-01', 'AMVNI031', NULL),
        ('32', DATE '2021-11-01', 'AMVNI032', 'https://images.tcdn.com.br/img/img_prod/1170935/o_espetacular_homem_aranha_vol_32_87883_1_6db646873a93cca3cd6594d9ff9e344f.jpg'),
        ('33', DATE '2021-12-01', 'AMVNI033', NULL),
        ('34', DATE '2022-01-01', 'AMVNI034', NULL),
        ('35', DATE '2022-02-01', 'AMVNI035', NULL),
        ('36', DATE '2022-03-01', 'AMVNI036', NULL),
        ('37', DATE '2022-04-01', 'AMVNI037', NULL),
        ('38', DATE '2022-05-01', 'AMVNI038', NULL),
        ('39', DATE '2022-06-01', 'AMVNI039', NULL),
        ('40', DATE '2022-07-01', 'AMVNI040', NULL),
        ('41', DATE '2022-08-01', 'AMVNI041', NULL),
        ('42', DATE '2022-09-01', 'AMVNI042', NULL),
        ('43', DATE '2022-10-01', 'AMVNI043', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_jse62g1u5h3at61ogikmgkf87c/-S897-f.webp'),
        ('44', DATE '2022-11-01', 'AMVNI044', NULL)
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, formato,
                     fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero,
       'O Espetacular Homem-Aranha #' || capa.numero,
       'Edicao brasileira da quarta serie de O Espetacular Homem-Aranha publicada pela Panini.',
       capa.data_publicacao,
       COALESCE(capa.url_capa_alternativa,
                'https://panini.com.br/media/catalog/product/A/M/' || capa.sku || '.jpg'),
       '17 x 26 cm, colorido',
       'PANINI', capa.sku,
       'https://panini.com.br/marvel/universo-homem-aranha',
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo, descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao, url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato, fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo, url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
