-- Capas conferidas pelo titulo e numero do produto. Nao inclui variantes.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1','https://rika.vteximg.com.br/arquivos/ids/303115/Mulher-Maravilha-Panini-1.jpg?v=636649924967970000'),
    ('2','https://rika.vteximg.com.br/arquivos/ids/303116/Mulher-Maravilha-Panini-2.jpg?v=636649925003200000'),
    ('3','https://rika.vteximg.com.br/arquivos/ids/303118/Mulher-Maravilha-Panini-3.jpg?v=636649925100830000'),
    ('4','https://rika.vteximg.com.br/arquivos/ids/321216/Mulher-Maravilha-4.jpg?v=636911280820600000'),
    ('6','https://rika.vteximg.com.br/arquivos/ids/303121/Mulher-Maravilha-Panini-6.jpg?v=636649925175970000'),
    ('7','https://rika.vteximg.com.br/arquivos/ids/321217/Mulher-Maravilha-7.jpg?v=636911281248170000'),
    ('9','https://rika.vteximg.com.br/arquivos/ids/303125/Mulher-Maravilha-Panini-9.jpg?v=636649925244830000'),
    ('10','https://rika.vteximg.com.br/arquivos/ids/321221/Mulher-Maravilha-10.jpg?v=636911283130530000'),
    ('11','https://rika.vteximg.com.br/arquivos/ids/321222/Mulher-Maravilha-11.jpg?v=636911284643870000'),
    ('14','https://rika.vteximg.com.br/arquivos/ids/321225/Mulher-Maravilha-14.jpg?v=636911983526070000'),
    ('15','https://rika.vteximg.com.br/arquivos/ids/321226/Mulher-Maravilha-15.jpg?v=636911984306370000'),
    ('16','https://rika.vteximg.com.br/arquivos/ids/320861/Mulher-Maravilha-16.jpg?v=636907846726070000'),
    ('17','https://rika.vteximg.com.br/arquivos/ids/320862/Mulher-Maravilha-17.jpg?v=636907846747430000'),
    ('18','https://rika.vteximg.com.br/arquivos/ids/320863/Mulher-Maravilha-18.jpg?v=636907846766300000'),
    ('19','https://rika.vteximg.com.br/arquivos/ids/320864/Mulher-Maravilha-19.jpg?v=636907846786300000'),
    ('20','https://rika.vteximg.com.br/arquivos/ids/320865/Mulher-Maravilha-20.jpg?v=636907846804800000'),
    ('22','https://rika.vteximg.com.br/arquivos/ids/320867/Mulher-Maravilha-22.jpg?v=636907846833770000'),
    ('23','https://rika.vteximg.com.br/arquivos/ids/443892/mulher-maravilha-23.jpg?v=638265808665400000'),
    ('24','https://rika.vteximg.com.br/arquivos/ids/443223/mulher-maravilha-24.jpg?v=638219312744630000'),
    ('25','https://rika.vteximg.com.br/arquivos/ids/418589/https---www.artesequencial.com.br-imagens-bruno-mulher-maravilha-25.jpg?v=638006651503030000'),
    ('26','https://rika.vteximg.com.br/arquivos/ids/341123/Mulher-Maravilha-26.jpg?v=637051970770300000'),
    ('27','https://rika.vteximg.com.br/arquivos/ids/341124/Mulher-Maravilha-27.jpg?v=637051971329130000'),
    ('29','https://rika.vteximg.com.br/arquivos/ids/443224/mulher-maravilha-29.jpg?v=638219313219300000'),
    ('30','https://rika.vteximg.com.br/arquivos/ids/345665/Mulher-Maravilha-30.jpg?v=637235311977400000'),
    ('33','https://rika.vteximg.com.br/arquivos/ids/345668/Mulher-Maravilha-33.jpg?v=637235312002570000'),
    ('35','https://rika.vteximg.com.br/arquivos/ids/443227/mulher-maravilha-35.jpg?v=638219314519670000'),
    ('38','https://rika.vteximg.com.br/arquivos/ids/406397/Mulher-Maravilha-38.jpg?v=637598293715670000'),
    ('40','https://rika.vteximg.com.br/arquivos/ids/406399/Mulher-Maravilha-40.jpg?v=637598293738030000'),
    ('43','https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b9893mdn2h4q9828d5gv4u8m7p/-S265-FWEBP'),
    ('45','https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9urno9mdp111rba60tfqhuu93f/-S265-FWEBP'),
    ('47','https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_a4rstu2c6l415cmhcrd1nv8l1g/-S265-FWEBP'),
    ('48','https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vb5ftsuqq13jv67canjvhds36o/-S265-FWEBP'),
    ('49','https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ms8i2jf75d68jb72dr4i0gl45a/-S265-FWEBP')
), serie_alvo AS (
    SELECT s.id
    FROM series s
    JOIN editoras p ON p.id = s.editora_id
    WHERE lower(s.titulo) IN ('mulher-maravilha 1ª série', 'mulher-maravilha 1a série')
      AND lower(p.nome) LIKE '%panini%'
      AND COALESCE(s.volume, 1) = 1
)
UPDATE edicoes e
SET url_capa = c.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas c
WHERE e.serie_id IN (SELECT id FROM serie_alvo)
  AND regexp_replace(e.numero, '^0+', '') = c.numero;
