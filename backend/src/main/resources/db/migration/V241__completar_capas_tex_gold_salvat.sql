-- Completa as sete capas de Tex Gold que nao estavam disponiveis no catalogo da Rika.
-- Fonte: paginas publicas dos produtos na loja oficial da Salvat.

WITH capas(numero, url_capa) AS (VALUES
    ('32', 'https://img.assinaja.com/assets/tZ/041/img/153860_900x900.png'),
    ('41', 'https://img.assinaja.com/assets/tZ/041/img/208852_900x900.jpg'),
    ('44', 'https://img.assinaja.com/assets/tZ/041/img/208864_900x900.jpg'),
    ('48', 'https://img.assinaja.com/assets/tZ/041/img/222468_900x900.jpg'),
    ('49', 'https://img.assinaja.com/assets/tZ/041/img/224289_900x900.jpg'),
    ('53', 'https://img.assinaja.com/assets/tZ/041/img/232769_900x900.jpg'),
    ('56', 'https://img.assinaja.com/assets/tZ/041/img/239627_900x900.jpg')
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
