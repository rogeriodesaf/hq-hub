-- Corrige a capa do volume único Doutor Estranho: Os Últimos Dias da Magia.
-- Atualiza a edição existente, inclusive quando numerada como UNICA, e só cria se faltar.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Doutor Estranho: Os Últimos Dias da Magia',
    'Fase completa de Doutor Estranho escrita por Jason Aaron, publicada pela Panini na linha Nova Marvel Deluxe.',
    1,
    'PANINI',
    'doutor-estranho-ultimos-dias-da-magia-nova-marvel-deluxe-panini-v1',
    'https://panini.com.br/doutor-estranho-os-ultimos-dias-da-magia',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

UPDATE edicoes edicao
SET titulo = 'Doutor Estranho: Os Últimos Dias da Magia',
    descricao = 'Reúne Doctor Strange (2015) 1-20, Doctor Strange: Last Days of Magic 1 e Doctor Strange Annual 1.',
    nome_volume = 'Os Últimos Dias da Magia',
    data_publicacao = coalesce(edicao.data_publicacao, DATE '2022-02-01'),
    url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_j6u35sqf750fhbtf5063h6v63k/-S897-f.webp',
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Doutor Estranho: Os Últimos Dias da Magia')
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1;

WITH serie_doutor_estranho AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Doutor Estranho: Os Últimos Dias da Magia')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Doutor Estranho: Os Últimos Dias da Magia',
    'Reúne Doctor Strange (2015) 1-20, Doctor Strange: Last Days of Magic 1 e Doctor Strange Annual 1.',
    'Os Últimos Dias da Magia',
    DATE '2022-02-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_j6u35sqf750fhbtf5063h6v63k/-S897-f.webp',
    'PANINI',
    'doutor-estranho-ultimos-dias-da-magia-panini-unica',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_doutor_estranho serie
WHERE NOT EXISTS (
    SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = serie.id
);
