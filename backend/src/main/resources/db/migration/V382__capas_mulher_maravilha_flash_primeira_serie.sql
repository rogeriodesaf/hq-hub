-- Capas regulares de Mulher-Maravilha e Flash 1ª Série (Panini).
WITH capas(numero, url_capa) AS (
    VALUES
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gc5qkn56n91nffigoi6h54l83o/-S265-FWEBP'),
    ('3', 'https://images.tcdn.com.br/img/img_prod/1170935/mulher_maravilha_flash_03_192825_1_931c08cb64f526da986a198605deb475.jpg'),
    ('7', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e75l73hhd5333a2711anrugg06/-S265-FWEBP'),
    ('11', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_au5rjmmnjl3od9jdhtbktqmt1f/-S265-FWEBP'),
    ('12', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9boi47qndp04j1b9b6ssevbo0b/-S265-FWEBP'),
    ('13', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2vj65jbm3h6ev621dinc2m0g3l/-S265-FWEBP')
)
UPDATE edicoes e
SET url_capa = c.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas c, series s, editoras p
WHERE e.serie_id = s.id
  AND s.editora_id = p.id
  AND lower(p.nome) LIKE '%panini%'
  AND lower(regexp_replace(s.titulo, '[^[:alnum:]ª]+', ' ', 'g')) LIKE 'mulher maravilha%flash%'
  AND lower(s.titulo) NOT LIKE '%2025%'
  AND COALESCE(s.volume, 1) = 1
  AND regexp_replace(e.numero, '^0+', '') = c.numero;
