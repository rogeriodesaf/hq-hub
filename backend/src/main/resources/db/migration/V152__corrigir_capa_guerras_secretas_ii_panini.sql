-- Corrige a capa no registro Panini já existente sem alterar a migration V151 aplicada.

UPDATE edicoes
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uqgv6h6nbl6f74vgn4f9ke7960/-S897-f.webp',
    url_origem = 'https://panini.com.br/guerras-secretas-ii',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE upper(trim(fonte_externa)) = 'PANINI'
  AND upper(trim(id_externo)) = 'AGSII001';
