-- Identifica corretamente o encadernado Pecado Original como parte da Nova Marvel Deluxe
-- e aplica a capa brasileira do catálogo público da Rika.

UPDATE series serie
SET titulo = 'Nova Marvel Deluxe: Pecado Original',
    descricao = 'Pecado Original, encadernado da linha Nova Marvel Deluxe publicado pela Panini em setembro de 2018.',
    fonte_externa = 'PANINI',
    id_externo = 'nova-marvel-deluxe-pecado-original-panini-v1',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Pecado Original'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Pecado Original')
  )
  AND (
      SELECT count(*)
      FROM edicoes edicao_existente
      WHERE edicao_existente.serie_id = serie.id
  ) <= 1;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Pecado Original',
    'Pecado Original, encadernado da linha Nova Marvel Deluxe publicado pela Panini em setembro de 2018.',
    1,
    'PANINI',
    'nova-marvel-deluxe-pecado-original-panini-v1',
    'https://www.rika.com.br/pecado-original-15007044/p',
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

WITH serie_pecado_original AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Pecado Original')
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
    '1',
    'Nova Marvel Deluxe: Pecado Original',
    'Uatu, o Vigia, foi assassinado. Os heróis investigam o crime e os segredos que ele testemunhou.',
    'Pecado Original',
    DATE '2018-09-01',
    'https://rika.vteximg.com.br/arquivos/ids/341214/Pecado-Original.jpg?v=637052724671800000',
    'RIKA',
    'nova-marvel-deluxe-pecado-original-panini-1',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_pecado_original serie
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
