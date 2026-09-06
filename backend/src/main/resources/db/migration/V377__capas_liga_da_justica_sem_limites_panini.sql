-- Capas oficiais Panini de Liga da Justiça Sem Limites, edições #1 a #11.
WITH capas(numero, url_capa) AS (VALUES
  ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5mi2la4trh7af98681ao18s075/-S265-FWEBP'),
  ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_q0fgnvqap16bnd0jjkjq48nb42/-S265-FWEBP'),
  ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r5tan2e5k52k7amvp18hvn5k7m/-S265-FWEBP'),
  ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3j0odqktdl5cf88hj1erdckp30/-S265-FWEBP'),
  ('5', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_f1qt6urocp56nargf1c3gei97n/-S265-FWEBP'),
  ('6', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b3aipgapq15ar2gkuk8rm6921i/-S265-FWEBP'),
  ('7', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1vf16tmatt26vcgtbr89euln0f/-S265-FWEBP'),
  ('8', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_bgee9reegt1l305dl18mfb3a3b/-S265-FWEBP'),
  ('9', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nb9h92oqtt3mr1oveti2nusq2r/-S265-FWEBP'),
  ('10', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_234vn9922h66n4jc3ugmkl0u4v/-S265-FWEBP'),
  ('11', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nc52g446a90q3datron7q7j04v/-S265-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa
FROM capas capa
WHERE hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero)
  AND EXISTS (
    SELECT 1
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id = edicao.serie_id
      AND hqhub_normalizar_identidade(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_identidade(serie.titulo)
            = hqhub_normalizar_identidade('Liga da Justiça Sem Limites')
  );
