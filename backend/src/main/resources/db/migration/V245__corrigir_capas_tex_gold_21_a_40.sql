-- Substitui as capas 21 a 40 de Tex Gold que apontavam para a imagem indisponivel da Rika.
-- Fonte: arquivos originais das paginas dos produtos na loja oficial da Salvat.

WITH capas(numero, url_capa) AS (VALUES
    ('21', 'https://img.assinaja.com/assets/tZ/041/img/101569_900x900.jpg'),
    ('22', 'https://img.assinaja.com/assets/tZ/041/img/101574_900x900.jpg'),
    ('23', 'https://img.assinaja.com/assets/tZ/041/img/102589_900x900.jpg'),
    ('24', 'https://img.assinaja.com/assets/tZ/041/img/102593_900x900.jpg'),
    ('25', 'https://img.assinaja.com/assets/tZ/041/img/130043_900x900.jpg'),
    ('26', 'https://img.assinaja.com/assets/tZ/041/img/130169_900x900.jpg'),
    ('27', 'https://img.assinaja.com/assets/tZ/041/img/130173_900x900.jpg'),
    ('28', 'https://img.assinaja.com/assets/tZ/041/img/130178_900x900.jpg'),
    ('29', 'https://img.assinaja.com/assets/tZ/041/img/132425_900x900.png'),
    ('30', 'https://img.assinaja.com/assets/tZ/041/img/153836_900x900.png'),
    ('31', 'https://img.assinaja.com/assets/tZ/041/img/153850_900x900.png'),
    ('32', 'https://img.assinaja.com/assets/tZ/041/img/153860_900x900.png'),
    ('33', 'https://img.assinaja.com/assets/tZ/041/img/155404_900x900.jpg'),
    ('34', 'https://img.assinaja.com/assets/tZ/041/img/155427_900x900.jpg'),
    ('35', 'https://img.assinaja.com/assets/tZ/041/img/155431_900x900.jpg'),
    ('36', 'https://img.assinaja.com/assets/tZ/041/img/155435_900x900.jpg'),
    ('37', 'https://img.assinaja.com/assets/tZ/041/img/156724_900x900.jpg'),
    ('38', 'https://img.assinaja.com/assets/tZ/041/img/156728_900x900.jpg'),
    ('39', 'https://img.assinaja.com/assets/tZ/041/img/208844_900x900.jpg'),
    ('40', 'https://img.assinaja.com/assets/tZ/041/img/208848_900x900.jpg')
), serie_tex_gold AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Gold')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Salvat')
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'SALVAT',
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_gold serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero);
