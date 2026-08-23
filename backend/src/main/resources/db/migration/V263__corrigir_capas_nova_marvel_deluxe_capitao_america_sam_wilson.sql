-- Corrige as quatro capas de Capitão América: Sam Wilson na linha Nova Marvel Deluxe.
-- A série mensal homônima, com mais edições, não é alterada.

UPDATE series serie
SET titulo = 'Nova Marvel Deluxe: Capitão América: Sam Wilson',
    descricao = 'Capitão América: Sam Wilson na linha Nova Marvel Deluxe, publicada pela Panini em quatro volumes.',
    fonte_externa = 'PANINI',
    id_externo = 'nova-marvel-deluxe-capitao-america-sam-wilson-panini-v1',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Capitão América: Sam Wilson')
  AND (
      SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id
  ) <= 4;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Capitão América: Sam Wilson',
    'Capitão América: Sam Wilson na linha Nova Marvel Deluxe, publicada pela Panini em quatro volumes.',
    1,
    'PANINI',
    'nova-marvel-deluxe-capitao-america-sam-wilson-panini-v1',
    'https://panini.com.br/capitao-america-sam-wilson-vol-1',
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

WITH capas(numero, subtitulo, data_publicacao, url_capa) AS (VALUES
    ('1', 'A Ascensão da Hidra', DATE '2022-04-01',
     'https://rika.vteximg.com.br/arquivos/ids/451911/capitao-america-sam-wilson-1-a-ascensao-da-hidra-capa-dura.jpg?v=638442995145900000'),
    ('2', 'Não é o Meu Capitão América', DATE '2022-08-01',
     'https://rika.vteximg.com.br/arquivos/ids/423301/https---www.artesequencial.com.br-imagens-2023-04-capitao-america-sam-wilson-2-nao-e-o-meu-capitao-america.jpg?v=638165029072900000'),
    ('3', 'Vertentes', DATE '2022-12-01',
     'https://rika.vteximg.com.br/arquivos/ids/423303/https---www.artesequencial.com.br-imagens-2023-04-capitao-america-sam-wilson-3-vertentes.jpg?v=638165029102130000'),
    ('4', 'Fim da Linha', DATE '2023-05-01',
     'https://rika.vteximg.com.br/arquivos/ids/453097/https---www.artesequencial.com.br-imagens-herois_panini-capitao-america-sam-wilson-4-fim-da-linha-capa-dura.jpg?v=638472599344930000')
), serie_sam_wilson AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Capitão América: Sam Wilson')
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Nova Marvel Deluxe: Capitão América: Sam Wilson #' || capa.numero,
    capa.subtitulo,
    capa.subtitulo,
    capa.data_publicacao,
    capa.url_capa,
    'RIKA',
    'nova-marvel-deluxe-capitao-america-sam-wilson-panini-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_sam_wilson serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
