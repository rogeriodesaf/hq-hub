-- Corrige a modelagem de V253: a Panini catalogou Marvel Deluxe em séries separadas
-- por personagem/evento, cada uma com sua própria numeração.

WITH catalogo(titulo, descricao, id_externo) AS (VALUES
    ('Marvel Deluxe: A Era de Ultron', 'Marvel Deluxe: A Era de Ultron, publicada pela Panini.', 'marvel-deluxe-era-de-ultron-panini-v1'),
    ('Marvel Deluxe: A Essência do Medo', 'Marvel Deluxe: A Essência do Medo, publicada pela Panini.', 'marvel-deluxe-essencia-do-medo-panini-v1'),
    ('Marvel Deluxe: Capitão América', 'Marvel Deluxe: Capitão América, publicada pela Panini em 9 edições.', 'marvel-deluxe-capitao-america-panini-v1'),
    ('Marvel Deluxe: Capitão Marvel', 'Marvel Deluxe: Capitão Marvel, publicada pela Panini.', 'marvel-deluxe-capitao-marvel-panini-v1'),
    ('Marvel Deluxe: Demolidor', 'Marvel Deluxe: Demolidor, publicada pela Panini em 6 edições.', 'marvel-deluxe-demolidor-panini-v1'),
    ('Marvel Deluxe: Dinastia M', 'Marvel Deluxe: Dinastia M, publicada pela Panini.', 'marvel-deluxe-dinastia-m-panini-v1'),
    ('Marvel Deluxe: Guerra Civil', 'Marvel Deluxe: Guerra Civil, publicada pela Panini.', 'marvel-deluxe-guerra-civil-panini-v1'),
    ('Marvel Deluxe: Homem de Ferro', 'Marvel Deluxe: Homem de Ferro, publicada pela Panini em 5 edições.', 'marvel-deluxe-homem-de-ferro-panini-v1'),
    ('Marvel Deluxe: Invasão Secreta', 'Marvel Deluxe: Invasão Secreta, publicada pela Panini.', 'marvel-deluxe-invasao-secreta-panini-v1'),
    ('Marvel Deluxe: Justiceiro', 'Marvel Deluxe: Justiceiro, publicada pela Panini em 4 edições.', 'marvel-deluxe-justiceiro-panini-v1'),
    ('Marvel Deluxe: O Incrível Hulk', 'Marvel Deluxe: O Incrível Hulk, publicada pela Panini em 2 edições.', 'marvel-deluxe-incrivel-hulk-panini-v1'),
    ('Marvel Deluxe: Os Novos Vingadores', 'Marvel Deluxe: Os Novos Vingadores, publicada pela Panini em 8 edições.', 'marvel-deluxe-novos-vingadores-panini-v1'),
    ('Marvel Deluxe: Os Poderosos Vingadores', 'Marvel Deluxe: Os Poderosos Vingadores, publicada pela Panini em 2 edições.', 'marvel-deluxe-poderosos-vingadores-panini-v1'),
    ('Marvel Deluxe: Thor', 'Marvel Deluxe: Thor, publicada pela Panini em 4 edições.', 'marvel-deluxe-thor-panini-v1'),
    ('Marvel Deluxe: Thor (2ª Edição)', 'Segunda edição de Marvel Deluxe: Thor, publicada pela Panini em 2 edições.', 'marvel-deluxe-thor-segunda-edicao-panini-v1'),
    ('Marvel Deluxe: Vingadores', 'Marvel Deluxe: Vingadores, publicada pela Panini em 2 edições.', 'marvel-deluxe-vingadores-panini-v1'),
    ('Marvel Deluxe: Vingadores - A Queda', 'Marvel Deluxe: Vingadores - A Queda, publicada pela Panini.', 'marvel-deluxe-vingadores-a-queda-panini-v1'),
    ('Marvel Deluxe: Vingadores & Os Novos Vingadores', 'Marvel Deluxe: Vingadores & Os Novos Vingadores, publicada pela Panini em 2 edições.', 'marvel-deluxe-vingadores-e-novos-vingadores-panini-v1'),
    ('Marvel Deluxe: Vingadores Sombrios', 'Marvel Deluxe: Vingadores Sombrios, publicada pela Panini.', 'marvel-deluxe-vingadores-sombrios-panini-v1'),
    ('Marvel Deluxe: Vingadores Vs. X-Men', 'Marvel Deluxe: Vingadores Vs. X-Men, publicada pela Panini.', 'marvel-deluxe-vingadores-vs-x-men-panini-v1')
)
INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    catalogo.titulo,
    catalogo.descricao,
    1,
    'PANINI',
    catalogo.id_externo,
    'https://www.planetagibiblog.com.br/2016/03/guia-planeta-gibi-marvel-deluxe.html',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM catalogo
CROSS JOIN LATERAL (
    SELECT id
    FROM editoras
    WHERE hqhub_normalizar_titulo_serie(nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY id
    LIMIT 1
) editora
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH distribuicao(numero_antigo, titulo_serie, numero_novo) AS (VALUES
    ('49', 'Marvel Deluxe: A Era de Ultron', '1'),
    ('39', 'Marvel Deluxe: A Essência do Medo', '1'),
    ('8', 'Marvel Deluxe: Capitão América', '1'),
    ('13', 'Marvel Deluxe: Capitão América', '2'),
    ('16', 'Marvel Deluxe: Capitão América', '3'),
    ('21', 'Marvel Deluxe: Capitão América', '4'),
    ('24', 'Marvel Deluxe: Capitão América', '5'),
    ('33', 'Marvel Deluxe: Capitão América', '6'),
    ('37', 'Marvel Deluxe: Capitão América', '7'),
    ('41', 'Marvel Deluxe: Capitão América', '8'),
    ('47', 'Marvel Deluxe: Capitão América', '9'),
    ('23', 'Marvel Deluxe: Capitão Marvel', '1'),
    ('1', 'Marvel Deluxe: Demolidor', '1'),
    ('2', 'Marvel Deluxe: Demolidor', '2'),
    ('3', 'Marvel Deluxe: Demolidor', '3'),
    ('4', 'Marvel Deluxe: Demolidor', '4'),
    ('5', 'Marvel Deluxe: Demolidor', '5'),
    ('6', 'Marvel Deluxe: Demolidor', '6'),
    ('11', 'Marvel Deluxe: Dinastia M', '1'),
    ('14', 'Marvel Deluxe: Guerra Civil', '1'),
    ('9', 'Marvel Deluxe: Homem de Ferro', '1'),
    ('28', 'Marvel Deluxe: Homem de Ferro', '2'),
    ('34', 'Marvel Deluxe: Homem de Ferro', '3'),
    ('35', 'Marvel Deluxe: Homem de Ferro', '4'),
    ('43', 'Marvel Deluxe: Homem de Ferro', '5'),
    ('25', 'Marvel Deluxe: Invasão Secreta', '1'),
    ('50', 'Marvel Deluxe: Justiceiro', '1'),
    ('51', 'Marvel Deluxe: Justiceiro', '2'),
    ('52', 'Marvel Deluxe: Justiceiro', '3'),
    ('53', 'Marvel Deluxe: Justiceiro', '4'),
    ('12', 'Marvel Deluxe: O Incrível Hulk', '1'),
    ('19', 'Marvel Deluxe: O Incrível Hulk', '2'),
    ('10', 'Marvel Deluxe: Os Novos Vingadores', '1'),
    ('15', 'Marvel Deluxe: Os Novos Vingadores', '2'),
    ('17', 'Marvel Deluxe: Os Novos Vingadores', '3'),
    ('26', 'Marvel Deluxe: Os Novos Vingadores', '4'),
    ('29', 'Marvel Deluxe: Os Novos Vingadores', '5'),
    ('32', 'Marvel Deluxe: Os Novos Vingadores', '6'),
    ('38', 'Marvel Deluxe: Os Novos Vingadores', '7'),
    ('42', 'Marvel Deluxe: Os Novos Vingadores', '8'),
    ('18', 'Marvel Deluxe: Os Poderosos Vingadores', '1'),
    ('27', 'Marvel Deluxe: Os Poderosos Vingadores', '2'),
    ('20', 'Marvel Deluxe: Thor', '1'),
    ('22', 'Marvel Deluxe: Thor', '2'),
    ('31', 'Marvel Deluxe: Thor', '3'),
    ('20', 'Marvel Deluxe: Thor (2ª Edição)', '1'),
    ('22', 'Marvel Deluxe: Thor (2ª Edição)', '2'),
    ('36', 'Marvel Deluxe: Vingadores', '1'),
    ('40', 'Marvel Deluxe: Vingadores', '2'),
    ('7', 'Marvel Deluxe: Vingadores - A Queda', '1'),
    ('45', 'Marvel Deluxe: Vingadores & Os Novos Vingadores', '1'),
    ('48', 'Marvel Deluxe: Vingadores & Os Novos Vingadores', '2'),
    ('30', 'Marvel Deluxe: Vingadores Sombrios', '1'),
    ('44', 'Marvel Deluxe: Vingadores Vs. X-Men', '1')
), origem AS (
    SELECT edicao.*, distribuicao.titulo_serie, distribuicao.numero_novo
    FROM distribuicao
    JOIN series serie_origem
      ON serie_origem.id_externo = 'marvel-deluxe-panini-capa-preta-volume-1'
    JOIN edicoes edicao
      ON edicao.serie_id = serie_origem.id
     AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(distribuicao.numero_antigo)
), destino AS (
    SELECT serie.id, serie.titulo
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    origem.numero_novo,
    origem.titulo,
    origem.descricao,
    origem.nome_volume,
    origem.data_publicacao,
    origem.url_capa,
    origem.fonte_externa,
    hqhub_normalizar_identidade(destino.titulo) || '-' || origem.numero_novo,
    destino.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM origem
JOIN destino
  ON hqhub_normalizar_titulo_serie(destino.titulo) = hqhub_normalizar_titulo_serie(origem.titulo_serie)
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = coalesce(EXCLUDED.data_publicacao, edicoes.data_publicacao),
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_thor AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'marvel-deluxe-thor-panini-v1'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    '4',
    'Thor - Os Devoradores de Mundos',
    'Marvel Deluxe: Thor, publicada pela Panini.',
    'Os Devoradores de Mundos',
    DATE '2021-07-01',
    'https://venda.panini.com.br/media/catalog/product/a/t/athvi001.jpg',
    'PANINI',
    'marvel-deluxe-thor-panini-4',
    serie_thor.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_thor
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    data_atualizacao = CURRENT_TIMESTAMP;

DELETE FROM edicoes
WHERE serie_id IN (
    SELECT id FROM series WHERE id_externo = 'marvel-deluxe-panini-capa-preta-volume-1'
)
AND id_externo LIKE 'marvel-deluxe-panini-capa-preta-%';

DELETE FROM series
WHERE id_externo = 'marvel-deluxe-panini-capa-preta-volume-1'
  AND NOT EXISTS (SELECT 1 FROM edicoes WHERE edicoes.serie_id = series.id);
