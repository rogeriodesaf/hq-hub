-- Cadastra O Espetacular Homem-Aranha, 5a serie (Panini, 2022-2025), com 33 capas oficiais.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
                    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao)
SELECT 'O Espetacular Homem-Aranha, 5ª Série',
       'Serie mensal da Panini publicada de dezembro de 2022 a setembro de 2025.',
       2022, 2025, 5, 'PANINI', 'AMVNI045-AMVNI077',
       'https://panini.com.br/marvel/universo-homem-aranha',
       editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 5ª Série')
  )
ORDER BY editora.id LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)) DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 5ª Série')
    ORDER BY serie.id LIMIT 1
), capas(numero, numero_global, data_publicacao, sku, url_capa) AS (
    VALUES
        ('1', 45, DATE '2022-12-01', 'AMVNI045', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ovefhgfshl58b60bbqmkoj2m7j/-S897-f.webp'),
        ('2', 46, DATE '2023-01-01', 'AMVNI046', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_u6f26bou2d2rl4o3ducdunku14/-S897-f.webp'),
        ('3', 47, DATE '2023-02-01', 'AMVNI047', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_o4nkc4lb892ep7s6ncm4s92h54/-S897-f.webp'),
        ('4', 48, DATE '2023-03-01', 'AMVNI048', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2faqj0gdid4b337mq1f8s9066j/-S897-f.webp'),
        ('5', 49, DATE '2023-04-01', 'AMVNI049', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qrn58u8dg55rh1nd3nim0jt41l/-S897-f.webp'),
        ('6', 50, DATE '2023-05-01', 'AMVNI050', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2g28k1e9mh3jnfik4ntfd22q2j/-S897-f.webp'),
        ('7', 51, DATE '2023-06-01', 'AMVNI051', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fh9gk2q2l16t94vinppv2k811i/-S897-f.webp'),
        ('8', 52, DATE '2023-07-01', 'AMVNI052', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_v5rga08qit6hj44qnkhct40j22/-S897-f.webp'),
        ('9', 53, DATE '2023-08-01', 'AMVNI053', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1v3ba47rmp4uj8nke6p0ehm03u/-S897-f.webp'),
        ('10', 54, DATE '2023-09-01', 'AMVNI054', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1dcaiu7o4h6836cdhs38hlj85t/-S897-f.webp'),
        ('11', 55, DATE '2023-10-01', 'AMVNI055', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7tm3bb3l595r75n48t42es013i/-S897-f.webp'),
        ('12', 56, DATE '2023-11-01', 'AMVNI056', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_js437sgu39589c5j0j8iksef6k/-S897-f.webp'),
        ('13', 57, DATE '2023-12-01', 'AMVNI057', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nbsuhtnsj5171eulgrb6qgnb3j/-S897-f.webp'),
        ('14', 58, DATE '2024-01-01', 'AMVNI058', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2deto6c0gh1ehevk98rctja33g/-S897-f.webp'),
        ('15', 59, DATE '2024-03-01', 'AMVNI059', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qsdbutolg55c7aks2d5vl58p1b/-S897-f.webp'),
        ('16', 60, DATE '2024-03-01', 'AMVNI060', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_f75nrfu4r930t1afudgdtqv762/-S897-f.webp'),
        ('17', 61, DATE '2024-04-01', 'AMVNI061', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_26vg3fbkv146n0gvvn4jup6c37/-S897-f.webp'),
        ('18', 62, DATE '2024-05-01', 'AMVNI062', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_p72hq49bed7db4d22kumf6jf6c/-S897-f.webp'),
        ('19', 63, DATE '2024-06-01', 'AMVNI063', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_chhsa1sj0l2nn4m7s7lnvqu557/-S897-f.webp'),
        ('20', 64, DATE '2024-07-01', 'AMVNI064', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rcamaak4b94j32anqg5ts2d423/-S897-f.webp'),
        ('21', 65, DATE '2024-09-01', 'AMVNI065', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7a0h6ofub54t536snft3c58e2j/-S897-f.webp'),
        ('22', 66, DATE '2025-01-01', 'AMVNI066', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pu1tnjp2o177n5e2bfl82ctk5i/-S897-f.webp'),
        ('23', 67, DATE '2025-02-01', 'AMVNI067', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qmslbo0khh7lj0j8fmj4sekq2h/-S897-f.webp'),
        ('24', 68, DATE '2025-03-01', 'AMVNI068', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2r3kqdihbt6hffjddjsh9neq30/-S897-f.webp'),
        ('25', 69, DATE '2025-03-01', 'AMVNI069', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_i03grkf1qt6u7cfd35mbv7b126/-S897-f.webp'),
        ('26', 70, DATE '2025-03-01', 'AMVNI070', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2k3q336ds12pv1o12si2gvm40v/-S897-f.webp'),
        ('27', 71, DATE '2025-04-01', 'AMVNI071', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_i19489dg354n7dm69fhcmn7s6p/-S897-f.webp'),
        ('28', 72, DATE '2025-05-01', 'AMVNI072', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_dgk8eml5rt5n9cbs5shkkp1b39/-S897-f.webp'),
        ('29', 73, DATE '2025-06-01', 'AMVNI073', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gcbkkt449567p0fffr6tgmfc52/-S897-f.webp'),
        ('30', 74, DATE '2025-07-01', 'AMVNI074', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nc4a1rrcel2rp12rvhvf6q7k0k/-S897-f.webp'),
        ('31', 75, DATE '2025-08-01', 'AMVNI075', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2d8l2jf9jh3pj1tfhbqcghhp0m/-S897-f.webp'),
        ('32', 76, DATE '2025-08-01', 'AMVNI076', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_q3ppicpg1p2pvbkafkk9vqmo7v/-S897-f.webp'),
        ('33', 77, DATE '2025-09-01', 'AMVNI077', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b662b0qppd1kffl40a61tdpn18/-S897-f.webp')
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, formato,
                     fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero,
       'O Espetacular Homem-Aranha #' || capa.numero || ' / ' || capa.numero_global,
       'Edicao brasileira da quinta serie de O Espetacular Homem-Aranha publicada pela Panini.',
       capa.data_publicacao, capa.url_capa, '17 x 26 cm, colorido, capa cartao',
       'PANINI', capa.sku,
       'https://panini.com.br/o-espetacular-homem-aranha-vol-' || capa.numero || '-' || capa.numero_global,
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo, descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao, url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato, fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo, url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
