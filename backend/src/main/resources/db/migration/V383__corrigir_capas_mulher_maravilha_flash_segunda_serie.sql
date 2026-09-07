-- Capas oficiais da coleção Mulher-Maravilha/Flash (2025), correspondente à 2ª série Panini.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9pahdkdji54rnb5rm7o8udhh12/-S265-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_m7fgijp30h7r9c5gghqrsfls77/-S265-FWEBP'),
    ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8tvjng2r354gdca0qc09h6nd7f/-S265-FWEBP'),
    ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_s7pi57cra11tbb00l2e61avo7s/-S265-FWEBP'),
    ('5', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5k91o7jqt1679600snj6qe2g1p/-S265-FWEBP'),
    ('6', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_alo1qhpned6alcfb8tpl4v9a58/-S265-FWEBP'),
    ('7', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_hestvd1mal5uf2ij5ibaj5qd45/-S265-FWEBP'),
    ('8', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r0peo4esbt52n1559k549vh10l/-S265-FWEBP'),
    ('9', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c65md1m5od4n1c9m1kj6697162/-S265-FWEBP'),
    ('10', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_l3cpiicc0t6r59a50ellbq435k/-S265-FWEBP'),
    ('11', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_epbskea0p519f319q1lfj21318/-S265-FWEBP'),
    ('12', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_clatm1880l0ir9csi0tepdgh0c/-S265-FWEBP'),
    ('13', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uors4ji5h1603atjas3qbvko1u/-S265-FWEBP'),
    ('14', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7l6jvddsad65952esugs7b9h2p/-S265-FWEBP'),
    ('15', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_tc7hh71ort0f32en6qcuton87s/-S265-FWEBP')
)
UPDATE edicoes e
SET url_capa = c.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas c, series s, editoras p
WHERE e.serie_id = s.id
  AND s.editora_id = p.id
  AND lower(p.nome) LIKE '%panini%'
  AND lower(regexp_replace(s.titulo, '[^[:alnum:]ª]+', ' ', 'g')) LIKE 'mulher maravilha%flash 2ª série%'
  AND regexp_replace(e.numero, '^0+', '') = c.numero;
