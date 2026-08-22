-- Substitui as capas 7 a 20 de Tex Gold que apontavam para a imagem indisponivel da Rika.
-- Fonte: arquivos originais das paginas dos produtos na loja oficial da Salvat.

WITH capas(numero, url_capa) AS (VALUES
    ('7', 'https://img.assinaja.com/assets/tZ/041/img/88906_900x900.jpg'),
    ('8', 'https://img.assinaja.com/assets/tZ/041/img/88910_900x900.jpg'),
    ('9', 'https://img.assinaja.com/assets/tZ/041/img/90135_900x900.jpg'),
    ('10', 'https://img.assinaja.com/assets/tZ/041/img/90139_900x900.jpg'),
    ('11', 'https://img.assinaja.com/assets/tZ/041/img/90143_900x900.jpg'),
    ('12', 'https://img.assinaja.com/assets/tZ/041/img/90147_900x900.jpg'),
    ('13', 'https://img.assinaja.com/assets/tZ/041/img/97148_900x900.jpg'),
    ('14', 'https://img.assinaja.com/assets/tZ/041/img/97152_900x900.jpg'),
    ('15', 'https://img.assinaja.com/assets/tZ/041/img/97156_900x900.jpg'),
    ('16', 'https://img.assinaja.com/assets/tZ/041/img/97160_900x900.jpg'),
    ('17', 'https://img.assinaja.com/assets/tZ/041/img/101544_900x900.jpg'),
    ('18', 'https://img.assinaja.com/assets/tZ/041/img/101548_900x900.jpg'),
    ('19', 'https://img.assinaja.com/assets/tZ/041/img/101552_900x900.jpg'),
    ('20', 'https://img.assinaja.com/assets/tZ/041/img/101556_900x900.jpg')
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
